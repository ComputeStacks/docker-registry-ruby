require 'test_helper'

describe DockerRegistry::Repo do

  it 'can list all images in a registry' do

    client = DockerRegistry::Client.new(
      ENV['REGISTRY_URL'],
      ENV['REGISTRY_PORT'],
      { username: ENV['REGISTRY_USERNAME'], password: ENV['REGISTRY_PASSWORD'] }
    )

    assert !DockerRegistry::Repo.new(client).images.empty?

  end

end
