require 'test_helper'

describe DockerRegistry::Client do

	it 'can authenticate with DockerHub' do

		client = DockerRegistry::Client.new(nil, 443, {})
		assert client.is_docker_hub?
		assert_kind_of DockerRegistry::Client, client

		# Check if we can access the mysql image
		VCR.use_cassette('client.docker_hub_auth') do
			response = client.exec!('head', 'library/mysql/manifests/latest')
			assert_equal 200, response.status
		end

	end

	it 'can authenticate with a basic auth registry' do

		client = DockerRegistry::Client.new('cr.demo.cmptstks.net', 25000, {username: 'admin', password: '5I34EM1iIw'})
		assert_kind_of DockerRegistry::Client, client

		# Check if we can access the mysql image
		VCR.use_cassette('client.basic.auth') do
			response = client.exec!('head', 'nginx/manifests/latest')
			assert_equal 200, response.status
		end

	end

end
