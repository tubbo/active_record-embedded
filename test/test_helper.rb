# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require 'simplecov'

SimpleCov.start do
  load_profile 'test_frameworks'
  load_profile 'bundler_filter'

  track_files '{lib}/**/*.rb'

  add_filter '/config/'
  add_filter 'lib/active_record/embedded/version.rb'
  add_filter 'lib/active_record/embedded/field/not_defined_error.rb'
  add_filter 'lib/active_record/embedded/field/type_error.rb'
end

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]
require "rails/test_help"
require "pry"
require 'minitest/autorun'

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("fixtures", __dir__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.file_fixture_path = ActiveSupport::TestCase.fixture_path + "/files"
  ActiveSupport::TestCase.fixtures :all
end

class Foo
  attr_reader :parent, :association, :foo

  def initialize(_parent: nil, _association: nil, foo: )
    @parent = _parent
    @association = _association
    @foo = foo
  end
end
