# frozen_string_literal: true

require 'test_helper'

module ActiveRecord
  class EmbeddedTest < ActiveSupport::TestCase
    test 'is a mixin module' do
      assert_kind_of Module, ActiveRecord::Embedded
      assert_kind_of ActiveSupport::Concern, ActiveRecord::Embedded
    end

    test 'initialize!' do
      ActiveRecord::Embedded.initialize!('sqlserver')

      assert ActiveRecord::Embedded.config.serialize_data
    end
  end
end
