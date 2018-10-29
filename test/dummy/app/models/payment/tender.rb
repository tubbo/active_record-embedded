class Payment::Tender
  include ActiveRecord::Embedded::Model

  embedded_in :payment

  field :token
  field :expiration_month, type: Integer
  field :expiration_year, type: Integer
  field :cvv, type: Integer

  validates :token, presence: true, uniqueness: true
end
