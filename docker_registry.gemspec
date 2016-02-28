$:.push File.expand_path("../lib", __FILE__)

require 'docker_registry/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "docker-registry"
  s.version     = DockerRegistry::VERSION
  s.authors     = ["Kris Watson"]
  s.email       = ["kris@computestacks.com"]
  s.homepage    = "https://git.computestacks.com"
  s.summary     = "Docker Distribution v2 API"
  s.description = "Docker Distribution v2 API"
  s.license     = "closed-source"
  s.required_ruby_version = '>= 1.9.3'
  s.add_dependency 'json', "~> 1.8"
  s.add_dependency 'httparty', '>= 0.13.5'
  s.files  = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
end
