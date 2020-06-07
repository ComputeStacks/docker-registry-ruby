require 'test_helper'

describe DockerRegistry::Client do

  it 'can authenticate with DockerHub' do

    client = DockerRegistry::Client.new(nil, 443, {})
    assert client.is_docker_hub?
    assert_kind_of DockerRegistry::Client, client

    # Check if we can access the mysql image
    VCR.use_cassette('client.docker_hub_auth') do
      response = client.exec!('head', 'library/mysql/manifests/latest')
      assert response.success?
    end

  end

  it 'can authenticate with a basic auth registry' do

    client = DockerRegistry::Client.new(
      ENV['REGISTRY_URL'],
      ENV['REGISTRY_PORT'],
      { username: ENV['REGISTRY_USERNAME'], password: ENV['REGISTRY_PASSWORD'] }
    )
    assert_kind_of DockerRegistry::Client, client

    # Check if we can access the mysql image
    VCR.use_cassette('client.basic.auth') do
      response = client.exec!('head', 'nginx/manifests/latest')
      assert response.success?
    end

  end

end
