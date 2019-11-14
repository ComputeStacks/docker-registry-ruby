require 'test_helper'

describe DockerRegistry::Repo do

	it 'can list all images in a registry' do

		client = DockerRegistry::Client.new('cr.demo.cmptstks.net', 25000, {username: 'admin', password: 'WI68kZHw9A'})

		VCR.use_cassette('repo.cs.list') do
			assert !DockerRegistry::Repo.new(client).images.empty?
		end

	end

end
