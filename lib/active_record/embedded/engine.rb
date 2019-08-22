# frozen_string_literal: true

module ActiveRecord
  module Embedded
    # Configures the library based on data in the Rails app.
    class Engine < ::Rails::Engine
      initializer 'active_record.embedded' do
        db_config = Rails.configuration.database_configuration[Rails.env]
        adapter = db_config['adapter']

        ActiveRecord::Embedded.initialize!(adapter)
      end
    end
  end
end
