lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'docker_registry/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'docker-registry'
  s.version     = DockerRegistry::VERSION
  s.authors     = ['Kris Watson']
  s.email       = ['kris@computestacks.com']
  s.homepage    = 'https://git.cmptstks.com/cs/docker-registry-rb'
  s.summary     = 'Docker Distribution v2 API'
  s.description = 'Docker Distribution v2 API'
  s.license     = 'closed-source'
  s.required_ruby_version = '>= 2.5.0'
  s.add_dependency 'json', '~> 2.2'
  s.add_dependency 'httparty', '~> 0.17'
  s.files  = `git ls-files`.split('\n')
  s.require_paths = ['lib']
end
