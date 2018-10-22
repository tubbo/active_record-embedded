# frozen_string_literal: true

module ActiveRecord
  module Embedded
    # Configures the library based on data in the Rails app.
    class Engine < ::Rails::Engine
      initializer 'active_record.embedded' do
        db_config = Rails.configuration.database_configuration[Rails.env]
        adapter = db_config['adapter']

        if ActiveRecord::Embedded.supports?(adapter)
          ActiveRecord::Embedded.config.adapter = adapter.to_sym
        else
          ActiveRecord::Embedded.config.serialize_data = true
        end
      end
    end
  end
end
