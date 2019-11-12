module DockerRegistry
	class Client

		attr_accessor :host,
									:port,
									:auth,
									:token_auth,
									:online

		# auth = {username: 'username', password: 'password'}
		def initialize(host, port, auth = {})
			self.host = host
			self.port = port
			self.auth = auth
			self.token_auth = nil
			self.online = online? # test auth and load token auth
		end

		def exec!(http_method, path, data = {})
			# TODO: Gracefully fail if !online.
			case http_method
			when 'get'
				if token_auth
					HTTParty.get("#{uri}/#{path}", timeout: 30, headers: { 'Authorization' => "Bearer #{self.token_auth}", 'Content-Type' => 'application/json' }, verify: false)
				else
					HTTParty.get("#{uri}/#{path}", basic_auth: auth, timeout: 30, headers: { 'Content-Type' => 'application/json' }, verify: false)
				end
			when 'delete'
				if token_auth
					HTTParty.delete("#{uri}/#{path}", timeout: 30, headers: { 'Authorization' => "Bearer #{self.token_auth}", 'Content-Type' => 'application/json' }, verify: false)
				else
					HTTParty.delete("#{uri}/#{path}", basic_auth: auth, timeout: 30, headers: { 'Content-Type' => 'application/json' }, verify: false)
				end
			end
		end

		def version
			1
		end

		def online?
			response = exec!('get', 'v2/')
			return true if response.code < 300
			# Token auth
			if response.headers['www-authenticate']
				auth_host = ""
				query_params = []
				response.headers['www-authenticate'].gsub('Bearer ', '').split(',').each do |el|
					k,v = el.split('=')
					if k == 'realm'
						auth_host = v.strip.gsub('"','')
					else
						query_params << el.strip.gsub('"','')
					end
				end
				auth_token(auth_host, query_params)
			end
			response = exec!('get', 'v2/')
			response.code < 300
		rescue
			false
		end

		private

		def uri
			"https://#{host}:#{port}"
		end

		def auth_token(host, params)
			rsp = HTTParty.get("#{host}?#{params.join('&')}", basic_auth: auth, verify: false)
			if rsp.code < 300
				data = JSON.parse(rsp.body)
				self.token_auth = data['token']
				data['token']
			end
			nil
		end

	end
end
