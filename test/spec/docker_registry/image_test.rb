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

    VCR.use_cassette('image.cs.tag_list') do
      tags = @cs_image.tags
      assert_equal 'nginx', tags['name']
      assert_includes tags['tags'], 'latest'
    end
  end

  it 'can access docker hub image tags' do

    VCR.use_cassette('image.hub.tag_list') do
      tags = @hub_image.tags
      assert_equal 'cmptstks/wordpress', tags['name']
      assert !tags['tags'].empty?
    end

  end

  it 'can load cs image tag' do

    VCR.use_cassette('image.cs.tag') do
      assert !@cs_image.find_tag().empty?
    end

  end

  it 'can load hub image tag' do

    VCR.use_cassette('image.hub.tag') do
      assert !@hub_image.find_tag('php7.3-litespeed').empty?
    end

  end

  it 'can delete a tag' do

    image = DockerRegistry::Image.new(@cs_registry_client, 'deleteme')

    VCR.use_cassette('image.cs.delete') do
      assert image.delete_tag!('stable')
    end

  end

end
