# frozen_string_literal: true

require 'active_record'
require 'active_support/all'

require 'active_record/embedded/engine' if defined? Rails
require 'active_record/embedded/error'
require 'active_record/embedded/type_error'
require 'active_record/embedded/interface'
require 'active_record/embedded/query'
require 'active_record/embedded/query/no_solutions_error'
require 'active_record/embedded/field'
require 'active_record/embedded/field/string'
require 'active_record/embedded/field/integer'
require 'active_record/embedded/field/float'
require 'active_record/embedded/field/hash'
require 'active_record/embedded/field/array'
require 'active_record/embedded/field/boolean'
require 'active_record/embedded/field/regexp'
require 'active_record/embedded/field/time'
require 'active_record/embedded/field/symbol'
require 'active_record/embedded/field/not_defined_error'

require 'active_record/embedded/index'
require 'active_record/embedded/index/collection'

require 'active_record/embedded/association'
require 'active_record/embedded/association/many'
require 'active_record/embedded/association/one'
require 'active_record/embedded/association/parent'

require 'active_record/embedded/relation'

require 'active_record/embedded/aggregation'
require 'active_record/embedded/aggregation/native'
require 'active_record/embedded/aggregation/postgresql'
require 'active_record/embedded/aggregation/mysql'

require 'active_record/embedded/model/attributes'
require 'active_record/embedded/model/persistence'
require 'active_record/embedded/model/fields'
require 'active_record/embedded/model/indexing'
require 'active_record/embedded/model/querying'
require 'active_record/embedded/model/storage'
require 'active_record/embedded/model'

require 'active_record/embedded/dynamic_attributes'

# :nodoc:
Boolean = ActiveRecord::Embedded::Field::Boolean

module ActiveRecord
  # A library for storing schema-less data in a relational database,
  # using +ActiveRecord+ models and corresponding to a SQL-like API.
  # Mixing in this module to your model will allow data to be stored as
  # serialized hashes in your SQL tables, while being rendered as models
  # in the application just like the rest of your data.
  #
  # This also serves as the root module for the rest of the library. For
  # more information on how this library works, see the other classes in
  # this documentation.
  module Embedded
    extend ActiveSupport::Concern
    extend ActiveSupport::Configurable::ClassMethods

    included do
      class_attribute :embeds
      self.embeds = {}
    end

    def self.config
      @config ||= ActiveSupport::Configurable::Configuration.new.tap do |cfg|
        cfg.scan_tables = true
        cfg.adapter = :native
        cfg.serialize_data = false
      end
    end

    def self.supports?(adapter)
      Aggregation.find(adapter.to_sym) && true
    rescue TypeError
      false
    end

    class_methods do
      # @!method embeds_many(name, class_name: nil)
      #   Create a one-to-many relationship with an embedded model.
      #
      #   @param [Symbol] name - Name of the relation
      #   @param [String] class_name - (optional) Class name of the model.
      def embeds_many(name, **options)
        embeds[name] = assoc = Association::Many.new(name: name, **options)
        serialize name, Hash if Embedded.config.serialize_data
        define_method(name) { assoc.query(self) }
        define_method("#{name}=") { |value| assoc.assign(self, value) }
        define_method("reindex_#{name}") { assoc.index(self) }
      end

      # @!method embeds_one(name, class_name: nil)
      #   Create a one-to-one relationship with an embedded model.
      #
      #   @param [Symbol] name - Name of the relation
      #   @param [String] class_name - (optional) Class name of the model.
      def embeds_one(name, **options)
        embeds[name] = assoc = Association::One.new(name: name, **options)
        serialize name, Hash if Embedded.config.serialize_data
        define_method(name) { assoc.query(self) }
        define_method("#{name}=") { |value| assoc.assign(self, value) }
        define_method("create_#{name}") { |value| assoc.create(self, value) }
        define_method("build_#{name}") { |value| assoc.build(self, value) }
        define_method("destroy_#{name}") { assoc.destroy(self) }
      end
    end
  end
end
