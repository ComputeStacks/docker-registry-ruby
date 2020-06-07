module DockerRegistry
	class Repo

		attr_accessor :client

		def initialize(client)
			self.client = client
		end

		def images
			rsp = client.exec!('get', '_catalog')
			return [] if rsp.status > 205
			# repos = JSON.parse(rsp.body, quirks_mode: true, allow_nan: true)
			repos = Oj.load(rsp.body)
			if repos.nil? || repos['repositories'].nil? || repos['repositories'].empty?
				return []
			else
				result = []
				repos['repositories'].each do |i|
					result << DockerRegistry::Image.new(client, i)
				end
				return result
			end
		end

	end
end
