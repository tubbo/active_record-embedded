class Order::Customizations < ActiveRecord::Embedded::Model
  embedded_in :order

  include ActiveRecord::Embedded::DynamicAttributes

  field :foo
end
