require "faraday"

require 'docker_registry/client'
require 'docker_registry/repo'
require 'docker_registry/image'

if RUBY_ENGINE == 'ruby' and not ENV['DISABLE_OJ']
  require 'oj'
  Oj.mimic_JSON
end

module DockerRegistry; end
