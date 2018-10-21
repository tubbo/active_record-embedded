module ActiveRecord
  module Embedded
    class Engine < ::Rails::Engine
      # initializer 'active_record.embedded.adapter' do
      #   db_config = Rails.configuration.database_configuration[Rails.env]
      #   adapter = db_config['adapter']

      #   Embedded.config.adapter = adapter.to_sym
      # end
    end
  end
end
