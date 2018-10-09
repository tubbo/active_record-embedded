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
provided for singular relationships.

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
eventually stored into the database. Due to this library's rich
typecasting system, however, custom types 

#### Custom Types

To create a custom type, define a subclass of
`ActiveRecord::Embedded::Field` like so:

```ruby
module ActiveRecord
  module Embedded
    class Field
      class Money < self
        # This method is called to prepare the field for insertion into
        # the database. It must return one of the standard JSON types.
        def cast(value)
          value.to_h
        end

        # When a value is being pulled out of the database, this is the
        # method called to convert its value back into that of the
        # higher-level field type.
        def coerce(value = nil)
          value.to_m
        end
      end
    end
  end
end
```

(you may need to explicitly require it)

By doing so, the `Money` type will be available in your models:

```ruby
class Item
  include ActiveRecord::Embedded::Model

  embedded_in :order

  field :price, type: Money
end
```

This causes 

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

Run all tests with the following command:

```bash
$ rails test
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
