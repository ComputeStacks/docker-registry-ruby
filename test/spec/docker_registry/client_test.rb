require 'test_helper'

describe DockerRegistry::Client do

  it 'can authenticate with DockerHub' do

    client = DockerRegistry::Client.new(nil, 443, {})
    assert client.is_docker_hub?
    assert_kind_of DockerRegistry::Client, client

    response = client.exec!('get', 'library/mysql/manifests/latest')
    assert response&.status&.success?

  end

  it 'can authenticate with a basic auth registry' do

    client = DockerRegistry::Client.new(
      ENV['REGISTRY_URL'],
      ENV['REGISTRY_PORT'],
      { username: ENV['REGISTRY_USERNAME'], password: ENV['REGISTRY_PASSWORD'] }
    )
    client.insecure_ssl = true
    assert_kind_of DockerRegistry::Client, client

    response = client.exec!('head', 'nginx/manifests/latest')
    assert response&.status&.success?

  end

  it 'can authenticate with github anonymously' do

    client = DockerRegistry::Client.new("ghcr.io", 443)
    assert_kind_of DockerRegistry::Client, client

    image_path = "computestacks/cs-docker-php/manifests/latest"
    response = client.exec!('head', image_path)
    assert response&.status&.success?

  end

  it 'can authenticate with a bearer auth registry' do

    client = DockerRegistry::Client.new("ghcr.io", 443)
    assert_kind_of DockerRegistry::Client, client

    image_path = "computestacks/cs-docker-php/manifests/latest"
    response = client.exec!('head', image_path)
    assert response&.status&.success?

  end

end
