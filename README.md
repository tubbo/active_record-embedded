# ActiveRecord::Embedded

[![Build Status](https://travis-ci.org/tubbo/active_record-embedded.svg?branch=master)](https://travis-ci.org/tubbo/active_record-embedded)
[![Maintainability](https://api.codeclimate.com/v1/badges/b0ff9f3ab10969a1e4c2/maintainability)](https://codeclimate.com/github/tubbo/active_record-embedded/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/b0ff9f3ab10969a1e4c2/test_coverage)](https://codeclimate.com/github/tubbo/active_record-embedded/test_coverage)

Embed data in your ActiveRecord models.

For more information, check out the [API Documentation][]

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_record-embedded'
```

Then, run the following command:

```bash
$ bundle
```

## Usage

Create a new model in **app/models/item.rb**:

```ruby
class Item
  include ActiveRecord::Embedded::Model

  embedded_in :order

  field :sku
  field :quantity, type: Integer
  field :customizations, type: Hash
  field :price, type: Float
  field :discounts, type: Array
end
```

Embed it in an existing model with a field `:items`:

```ruby
class Order < ApplicationRecord
  embeds_many :items
end
```

Make sure to generate a migration for storing this data. Use the best
data type that your database provides for storing schema-less data. In
PostgreSQL, that's most likely [jsonb][]:

```bash
$ rails generate migration AddItemsToOrder items:jsonb
$ rails db:migrate
```

If your database doesn't support storing schema-less data, you can
store data in a regular String datatype and `serialize` it with
ActiveRecord:

```bash
$ rails generate migration AddItemsToOrder items
$ rails db:migrate
```

Then, in your model:

```ruby
class Order < ApplicationRecord
  serialize :items, Hash

  embeds_many :items
end
```

Note the usage of `Hash` in this serialization. All embedded data, even
one-to-many relationships, are stored in Hash format for quick retrieval
by ID.

### Querying

Embedded relations can be queried like any other model.

```ruby
# Find an embedded model by its ID
@order.items.find('b05845e7-cb6b-4bc2-aa45-0361189929d0') # => <Item ...>

# Find a model by one of its attributes
@order.items.find_by(sku: 'SKU123') # => <Item ...>

# Find all items with a quantity of 1
@order.items.where(quantity: 1) # => <ActiveRecord::Embedded::Relation ...>

# Sort items by their SKU
@order.items.order(sku: :desc) # => <ActiveRecord::Embedded::Relation ...>
```

Data is lazy-loaded, meaning the query on the original model is not
run until data is requested. It is thereby casted into the model
class you defined for it, and returned:

```ruby
items = @order.items.where(sku: 'SKU123') # => <ActiveRecord::Embedded::Relation ...>
items = items.order(created_at: :desc) # => <ActiveRecord::Embedded::Relation ...>
items.map { |item| item } # => <Array<Item>>
```

#### Aggregation Queries

Aggregations are queries performed on an entire table of records, rather
than just the embedded data within a single record. Aggregations can be
accessed using the familiar ActiveRecord querying API:

```ruby
# Filter by key/value pairs
Item.where(sku: 'SKU1')

# Sort by fields with a given direction
items = Item.order(quantity: :asc)

# Return a maximum of 10 items
items.limit(10)

# Start at the 2nd item
items.offset(2)
```

These methods are actually just syntax sugar for the `.aggregate`
method, which can be used to construct custom queries without needing to
chain method calls:

```ruby
Item.aggregate(start: 2, limit: 8)
```

Aggregation queries are aided by your ActiveRecord adapter's driver, if
one exists. Otherwise, the "native" adapter is used which uses Ruby to
iterate through all records. The following databases are supported:

- [PostgreSQL][postgres-driver] (requires [PostgreSQL 9.3][postgres])
- [MySQL (planned)][mysql-driver] (requires [MySQL 5.7.8][mysql])
- Microsoft SQL Server (planned)

The goal is to support all databases with ActiveRecord adapters that
support JSON as a native data type.

### Assignment

Embedded relations are assigned in a similar way to ActiveRecord's API:

```ruby
# The preferred way to create embedded relations is off their parent
@order.items.create(quantity: 1, sku: 'SKU123') # => <Item...>

# You can also create them in the constructor...
item = Item.new(quantity: 1, sku: 'SKU456') # => <Item...>

# However, this won't save until attached to an Order:
item.save # => false
item.order = @order
item.save # => true

# Assign your parent model in the constructor, using the name given in `embedded_in`...
Item.new(quantity: 1, sku: 'SKU456', order: @order) # => <Item...>

# ...or, the global `:parent` attribute:
Item.new(quantity: 1, sku: 'SKU456', parent: @order) # => <Item...>
```

Methods such as `create_#{assocation}` and `destroy_#{assocation}` are
provided for singular relationships, just like in ActiveRecord's
`has_one` association.

Consider a `User` which embeds address data:

```ruby
# app/models/user.rb
class User < ApplicationRecord
  embeds_one :address
end
```

And an `Address` for modeling the embedded data:

```ruby
# app/models/address.rb
class Address
  include ActiveRecord::Embedded::Model

  embedded_in :user

  field :name
  field :street_1
  field :street_2
  field :city
  field :region
  field :country

  validates :name, presence: true
  validates :street_1, presence: true
  validates :city, presence: true
  validates :region, presence: true
  validates :country, presence: true
end
```

One can create the address like so, since `@user.address.create` will
throw an error.

```ruby
@user.address # => nil
address = @user.create_address(
  name: 'Lester Tester',
  street_1: '123 Fake street',
  city: 'Fakeadelphia',
  region: 'FA',
  country: 'US'
)
address # => <Address ...>
```

### Field Types

Fields must correspond to the standard JSON types, as defined by
[RFC 7159][], the most recent standard specification as of this writing.

These types are:

- `object`, in Ruby represented as [Hash][]
- `array`, represented in Ruby as an [Array][]
- `number`, which can either be represented as an [Integer][] or [Float][]
- `string`, represented in Ruby as a regular [String][] class
- `boolean`, represented by the [true][] and [false][] literals in Ruby and...
- `null`, which is represented in Ruby as [nil][]

The above list represents a total catalog of all types that can be
eventually stored into the database, but additional objects are
represented by custom types...

#### Custom Types

Custom types are supported by subclassing
`ActiveRecord::Embedded::Field`. This is an interface that requires the
implementation of a `#cast` method in order to provide typecasting
functionality for a complex type. Custom types "boil down" a complex
type defined in Ruby into something that can be serialized to a
primitive JSON type, typically a Hash.

Here's an example of a custom type for the [Money][] object, defined in
**lib/active_record/embedded/field/money.rb** in your Rails application:

```ruby
module ActiveRecord
  module Embedded
    class Field
      class Money < self
        # This method is called to prepare the field for insertion into
        # the database. It must return one of the standard JSON types.
        # In this example, a Hash is returned.
        def cast(value)
          {
            '$cents' => value.cents,
            '$currency' => value.currency
          }
        end

        # When a value is being pulled out of the database, this is the
        # method called to convert its value back into that of the
        # higher-level field type. Since the #cast method converts this
        # type into a Hash, access is granted to the currency and cents
        # of the given object.
        def coerce(value = nil)
          return if value.blank?
          Money.new(value['$cents'], value['$currency'])
        end
      end
    end
  end
end
```

You can require this file in your **config/application.rb**:

```ruby
require 'active_record/embedded/field/money'
```

By doing so, the `Money` type will be available to your embedded models:

```ruby
class Item
  include ActiveRecord::Embedded::Model

  embedded_in :order

  field :price, type: Money
end
```

### Indexing

Indexes on known queries help to speed up reading embedded data from the
database, especially when dealing with a large amount of records.

To define an index on an embedded model, use the `index` macro:

```ruby
class Item
  include ActiveRecord::Embedded::Model

  embedded_in :order

  field :sku, type: String

  index :sku, unique: true
end
```

This macro is based off of Mongoid's, but doesn't include the esoteric
syntax of MongoDB. Instead, you provide the attributes you wish to index
(an Array can be specified if it's a compound index), then the options
for said index. The options for indexes are as follows:

- `:direction` can be `:asc` (default) or `:desc`
- `:unique` if set to `true` will throw an error when a non-unique value
  is added to the index

### Rails Integration

Although Rails isn't required to use this library, some out-of-box
functionality is included into the model in case it is within a Rails
app. You'll find that the generated `*_path`, `*_url` and of course the
`url_for` helpers will generate predictable path names for your embedded
models, and `#cache_key` has been modified to include the parent model's
cache key for easy manual expiration.

## Contributing

All contributions to this library are welcome and encouraged. Please submit
a [pull request][] for changes to documentation or source, and if you see an
issue, please [report it][]! Please make sure you're familiar with the
[code of conduct][] when contributing.

### Running Tests

To run tests, make sure you have a database set up (you only have to do
this once):

```bash
$ rails app:db:setup
```

Run all tests and RuboCop lint checks with the following command:

```bash
$ rails lint test
```

## License

The gem is available as open source under the terms of the [MIT License][].

[pull request]: https://github.com/tubbo/active-record_embedded/pulls
[report it]: https://github.com/tubbo/active-record_embedded/issues/new
[MIT License]: https://opensource.org/licenses/MIT
[code of conduct]: https://www.contributor-covenant.org/version/1/4/code-of-conduct
[API Documentation]: https://www.rubydoc.info/github/tubbo/active-record_embedded/latest
[jsonb]: https://www.postgresql.org/docs/9.4/static/datatype-json.html
[RFC 7159]: https://tools.ietf.org/html/rfc7159.html#section-3
[Hash]: https://ruby-doc.org/core-2.5.1/Hash.html
[Array]: http://ruby-doc.org/core-2.5.1/Array.html
[Integer]: http://ruby-doc.org/core-2.5.1/Integer.html
[Float]: http://ruby-doc.org/core-2.5.1/Float.html
[String]: http://ruby-doc.org/core-2.5.1/String.html
[true]: http://ruby-doc.org/core-2.5.1/TrueClass.html
[false]: http://ruby-doc.org/core-2.5.1/FalseClass`.html
[nil]: http://ruby-doc.org/core-2.5.1/NilClass.html
[Money]: http://rubymoney.github.io/money/
[postgres-driver]: https://www.rubydoc.info/github/tubbo/active_record-embedded/ActiveRecord/Embedded/Aggregation/Postgresql
[mysql-driver]: https://github.com/tubbo/active_record-embedded/tree/mysql-driver
[postgres]: https://www.postgresql.org/docs/9.3/static/functions-json.html
[mysql]: https://dev.mysql.com/doc/relnotes/mysql/5.7/en/news-5-7-8.html#mysqld-5-7-8-json
