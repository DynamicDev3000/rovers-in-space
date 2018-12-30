require_relative "../lib/rovers"
require 'simplecov'

SimpleCov.start

RSpec.configure do |config|
    config.mock_framework = :rspec
end