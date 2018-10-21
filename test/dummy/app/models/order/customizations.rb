# frozen_string_literal: true

class Order::Customizations
  include ActiveRecord::Embedded::Model
  include ActiveRecord::Embedded::DynamicAttributes

  embedded_in :order

  field :foo
end
