# frozen_string_literal: true

module ActiveRecord
  module Embedded
    class Engine < ::Rails::Engine
      initializer 'active_record.embedded' do
        db_config = Rails.configuration.database_configuration[Rails.env]
        adapter = db_config['adapter']

        ActiveRecord::Embedded.config.adapter = adapter.to_sym
      end
    end
  end
end
