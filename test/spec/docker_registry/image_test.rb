require 'test_helper'

describe DockerRegistry::Image do

  before do
    @hub_registry_client = DockerRegistry::Client.new(nil, 443, {})
    @cs_registry_client = DockerRegistry::Client.new(
      ENV['REGISTRY_URL'],
      ENV['REGISTRY_PORT'],
      { username: ENV['REGISTRY_USERNAME'], password: ENV['REGISTRY_PASSWORD'] }
    )
    @cs_registry_client.insecure_ssl = true

    @hub_image = DockerRegistry::Image.new(@hub_registry_client, 'cmptstks/wordpress')
    @cs_image = DockerRegistry::Image.new(@cs_registry_client, 'nginx')
  end

  it 'can access cs image tags' do
    tags = @cs_image.tags
    assert_equal 'nginx', tags['name']
    assert_includes tags['tags'], 'latest'
  end

  it 'can access docker hub image tags' do

    tags = @hub_image.tags
    assert_equal 'cmptstks/wordpress', tags['name']
    refute_empty tags['tags']

  end

  it 'can load cs image tag' do
    refute_empty @cs_image.find_tag
  end

  it 'can load hub image tag' do
    refute_empty @hub_image.find_tag('php7.4-litespeed')
  end

  it 'can access github image tags anonymously' do

    client = DockerRegistry::Client.new("ghcr.io", 443)

    image = DockerRegistry::Image.new(client, "computestacks/cs-docker-php")

    refute_empty image.tags['tags']

  end

end
