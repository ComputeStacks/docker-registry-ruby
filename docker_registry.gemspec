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

	s.files  = `git ls-files`.split('\n')
	s.require_paths = ['lib']

	s.add_runtime_dependency 'faraday', '~> 1'
  s.add_runtime_dependency 'oj', '~> 3.0'

	s.add_development_dependency "minitest", "~> 5.13"
	s.add_development_dependency "minitest-reporters", "> 1"
	s.add_development_dependency "rake", "~> 12.3"
	s.add_development_dependency "vcr", "~> 5.0"
end
