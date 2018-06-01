# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/test/"
  add_filter "/vendor/"
  minimum_coverage 100
end

require "codecov"

PROJECT_ROOT ||= File.expand_path("..", __dir__)
STUB_PATH ||= File.expand_path(File.join(__FILE__, "..", "stub"))
$LOAD_PATH.unshift(STUB_PATH)

Dir.glob("#{PROJECT_ROOT}/lib/**/*.rb").each { |f| require f }

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
]
SimpleCov.formatters << SimpleCov::Formatter::Codecov if ENV["CI"]

require "bundle"
require "bundler"
require "rspec/support/object_formatter"

RSpec.configure do |config|
  config.filter_run_when_matching :focus

  # TODO: when https://github.com/rspec/rspec-expectations/pull/1056
  #       makes it into a stable release:
  # config.expect_with :rspec do |c|
  #   c.max_formatted_output_length = 200
  # end

  # Never truncate output objects.
  RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = nil

  config.around(:each) do |example|
    Bundler.with_clean_env { example.run }
  end
end

require "unindent"

# Stub out the inclusion of Homebrew's code.
LIBS_TO_SKIP = ["formula", "tap", "utils/formatter"].freeze

module Kernel
  alias old_require require
  def require(path)
    old_require(path) unless LIBS_TO_SKIP.include?(path)
  end
end

HOMEBREW_PREFIX = Pathname.new("/usr/local")
HOMEBREW_REPOSITORY = Pathname.new("/usr/local/Homebrew")

module Formatter
  module_function

  def columns(*); end

  def success(*args)
    args
  end

  def error(*args)
    args
  end
end

class Formula
  def self.installed
    []
  end
end

class Tap
  def self.map
    []
  end
end
