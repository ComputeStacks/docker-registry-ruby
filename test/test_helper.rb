require "minitest/autorun"
require "minitest/spec"
require "minitest/reporters"
require "docker_registry"

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
