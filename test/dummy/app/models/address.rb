# frozen_string_literal: true

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
  field :postal_code_validator, type: Regexp
  field :kind, type: Symbol, default: :billing

  validates :kind, inclusion: %i[billing shipping]

  index %i[city region country]
end
