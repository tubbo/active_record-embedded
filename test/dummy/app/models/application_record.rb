class ApplicationRecord < ActiveRecord::Base
  include ActiveRecord::Embedded

  self.abstract_class = true
end
