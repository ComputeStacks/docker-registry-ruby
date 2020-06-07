require "minitest/autorun"
require "minitest/spec"
require "minitest/reporters"
require "vcr"
require "docker_registry"

VCR.configure do |config|
  config.cassette_library_dir = "test/fixtures/vcr"
  config.hook_into :faraday
end

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
