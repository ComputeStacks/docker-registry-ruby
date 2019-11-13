module DockerRegistry
	class Repo

		attr_accessor :client

		def initialize(client)
			self.client = client
		end

		def images
			repos = client.exec!('get', '_catalog')
			if repos.nil? || repos['repositories'].nil? || repos['repositories'].empty?
				return []
			else
				result = []
				repos['repositories'].each do |i|
					result << DockerRegistry::Image.new(host, port, {username: username, password: password}, i)
				end
				return result
			end
		end

	end
end
