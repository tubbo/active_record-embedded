require "active_support/all"
require "active_record/embedded/engine"
require "active_record/embedded/field"
require "active_record/embedded/field/not_defined_error"
require "active_record/embedded/field/type_error"
require "active_record/embedded/association"
require "active_record/embedded/association/many"
require "active_record/embedded/association/one"
require "active_record/embedded/association/parent"
require "active_record/embedded/relation"
require "active_record/embedded/model"

module ActiveRecord
  module Embedded
    extend ActiveSupport::Concern

    included do
      class_attribute :embeds
      self.embeds = {}
    end

    class_methods do
      def embeds_many(name, **options)
        embeds[name] = assoc = Association::Many.new(name: name, **options)
        define_method(name) { assoc.find(self) }
        define_method("#{name}=") { |value| assoc.update(self, value) }
      end

      def embeds_one(name, **options)
        embeds[name] = assoc = Association::One.new(name: name, **options)
        define_method(name) { assoc.find(self) }
        define_method("#{name}=") { |value| assoc.update(self, value) }
        define_method("create_#{name}") { |value| assoc.create(self, value) }
        define_method("destroy_#{name}") { assoc.destroy(self) }
      end
    end
  end
end
