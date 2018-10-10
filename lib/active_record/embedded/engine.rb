module ActiveRecord
  module Embedded
    class Engine < ::Rails::Engine
      config.active_record_embedded = ActiveSupport::OrderedOptions.new
      config.active_record_embedded.adapter = :native
    end
  end
end
