require 'test_helper'

class ActiveRecord::Embedded::Test < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, ActiveRecord::Embedded
  end
end
