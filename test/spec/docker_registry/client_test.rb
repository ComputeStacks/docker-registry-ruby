require 'test_helper'

describe DockerRegistry::Client do

  it 'can authenticate with DockerHub' do

    client = DockerRegistry::Client.new(nil, 443, {})
    assert client.is_docker_hub?
    assert_kind_of DockerRegistry::Client, client

    # Check if we can access the mysql image
    response = client.exec!('head', 'library/mysql/manifests/latest')
    assert response.success?

  end

  it 'can authenticate with a basic auth registry' do

    client = DockerRegistry::Client.new(
      ENV['REGISTRY_URL'],
      ENV['REGISTRY_PORT'],
      { username: ENV['REGISTRY_USERNAME'], password: ENV['REGISTRY_PASSWORD'] }
    )
    assert_kind_of DockerRegistry::Client, client

    # Check if we can access the nginx image
    response = client.exec!('head', 'nginx/manifests/latest')
    assert response.success?

  end

  it 'can authenticate with a bearer auth registry' do

    client = DockerRegistry::Client.new(
      ENV['GL_REGISTRY_URL'],
      ENV['GL_REGISTRY_PORT'],
      { username: ENV['GL_REGISTRY_USERNAME'], password: ENV['GL_REGISTRY_TOKEN'] }
    )
    assert_kind_of DockerRegistry::Client, client

    # Check if we can access the image
    image_path = "#{ENV['GL_REGISTRY_IMAGE']}/manifests/latest"
    response = client.exec!('head', image_path)
    assert response.success?

  end

end
