module DockerRegistry
	class Client

		attr_accessor :host,
									:port,
									:auth_username,
									:auth_password,
									:token_auth,
									:token_endpoint,
									:online

		# auth = {username: 'username', password: 'password'}
		def initialize(host, port, auth = {})
			self.host = (host.nil? || host.strip == '') ? "registry.hub.docker.com" : host.strip
			self.port = port.to_i == 0 ? 443 : port.to_i
			self.auth_username = auth[:username]
			self.auth_password = auth[:password]
			self.token_auth = nil
			self.token_endpoint = nil
			self.online = true
		end

		def exec!(http_method, path, enable_basic_auth = true)
			conn = Faraday.new(url: uri_full(path), headers: {
				'Accept' => 'application/vnd.docker.distribution.manifest.v2+json',
				'Content-Type' => 'application/json',
        'User-Agent' => 'docker/20.10.14'
			})
			if token_auth
        conn.request :authorization, 'Bearer', -> { token_auth }
			elsif has_basic_auth? && enable_basic_auth
        conn.request :basic_auth, auth_username, auth_password
			end

			rsp = case http_method
			when 'get'
				conn.get uri_full(path)
			when 'head'
				conn.head uri_full(path)
			when 'delete'
				conn.delete uri_full(path)
			else
				return nil
			end
			if online && (rsp.status == 401 && rsp.headers['www-authenticate']) && !token_auth
				authenticate!(rsp.headers['www-authenticate'])
				exec!(http_method, path)
      elsif enable_basic_auth && online && rsp.status == 401 && !token_auth
        # GitHub will not return an auth header if basic auth is passed, unlike other registries.
        # If we encounter that, try once more without basic auth to see if we can get a valid header.
        exec!(http_method, path, false)
			else
				rsp
			end
		end

		def version
			1
		end

		def is_docker_hub?
			host == "registry.hub.docker.com"
		end

		private

		def has_basic_auth?
			!(auth_username.nil? || auth_username == '') && !(auth_password.nil? || auth_password == '')
		end

		def uri
			port == 443 ? "https://#{host}/v2" : "https://#{host}:#{port}/v2"
		end

		def uri_full(path = nil)
			path.nil? || path.strip == '' ? uri : "#{uri}/#{path}"
		end

		# helper to authenticate from auth header
		def authenticate!(auth_header)
			query_params = []
			auth_header.gsub('Bearer ', '').split(',').each do |el|
				k,v = el.split('=')
				if k == 'realm'
					token_endpoint = v.strip.gsub('"','')
				else
					query_params << el.strip.gsub('"','')
				end
			end
			online = req_auth_token!(query_params)
		end

		def req_auth_token!(params)
			return nil if token_endpoint.nil? || token_endpoint.strip == ''
			conn = Faraday.new(url: token_endpoint, headers: {
				'Accept' => 'application/json',
				'Content-Type' => 'application/json'
			})
      if has_basic_auth?
        conn.request :basic_auth, auth_username, auth_password
      end
			rsp = conn.get("?#{params.join('&')}")
			if rsp.success?
				data = Oj.load(rsp.body)
				token_auth = data['token']
				!data['token'].nil? && data['token'] != ''
			end
			false
		end

	end
end
