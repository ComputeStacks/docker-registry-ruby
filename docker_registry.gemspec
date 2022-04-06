lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'docker_registry/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'docker_registry'
  s.version     = DockerRegistry::VERSION
  s.authors     = ['Kris Watson']
  s.email       = ['kris@computestacks.com']
  s.homepage    = 'https://git.cmptstks.com/cs/docker-registry-rb'
  s.summary     = 'Docker Distribution v2 API'
  s.description = 'Docker Distribution v2 API'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 2.5.0'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if s.respond_to?(:metadata)
    s.metadata["allowed_push_host"] = "https://rubygems.pkg.github.com"
    s.metadata['github_repo'] = "ssh://github.com/ComputeStacks/docker-registry-ruby.git"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  s.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  s.require_paths = ['lib']

  s.add_runtime_dependency 'faraday', '~> 2'

  s.add_development_dependency "minitest", "~> 5"
  s.add_development_dependency "minitest-reporters", "> 1"
  s.add_development_dependency "rake", "~> 13"
end
