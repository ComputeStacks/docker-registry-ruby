require 'test_helper'

describe DockerRegistry::Image do

  before do
    @hub_registry_client = DockerRegistry::Client.new(nil, 443, {})
    @cs_registry_client = DockerRegistry::Client.new(
      ENV['REGISTRY_URL'],
      ENV['REGISTRY_PORT'],
      { username: ENV['REGISTRY_USERNAME'], password: ENV['REGISTRY_PASSWORD'] }
    )

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
    refute_empty @cs_image.find_tag()
  end

  it 'can load hub image tag' do
    refute_empty @hub_image.find_tag('php7.4-litespeed')
  end

  it 'can list all tags in a bearer registry' do

    client = DockerRegistry::Client.new(
      ENV['GL_REGISTRY_URL'],
      ENV['GL_REGISTRY_PORT'],
      { username: ENV['GL_REGISTRY_USERNAME'], password: ENV['GL_REGISTRY_TOKEN'] }
    )

    image = DockerRegistry::Image.new(client, ENV['GL_REGISTRY_IMAGE'])

    refute_empty image.tags['tags']

  end

##
# TODO: Automate creating a tag first, so we can then delete it in our tests.
#   it 'can delete a tag' do
#
#     image = DockerRegistry::Image.new(@cs_registry_client, 'deleteme')
#     assert image.delete_tag!('stable')
#
#   end

end
