class Address
  include ActiveRecord::Embedded::Model

  embedded_in :order

  field :name
  field :street_1
  field :street_2
  field :city
  field :region
  field :country
  field :postal_code
end
