module DockerRegistry
	class Client

		attr_accessor :host,
									:port,
									:auth,
									:token_auth,
									:token_endpoint,
									:online

		# auth = {username: 'username', password: 'password'}
		def initialize(host, port, auth = {})
			self.host = (host.nil? || host.strip == '') ? "registry.hub.docker.com" : host.strip
			self.port = port.to_i == 0 ? 443 : port.to_i
			self.auth = auth
			self.token_auth = nil
			self.token_endpoint = nil
			self.online = true
		end

		def exec!(http_method, path, data = {})
			# TODO: Gracefully fail if !online.
			rsp = case http_method
			when 'get'
				if token_auth
					HTTParty.get(uri_full(path), timeout: 30, headers: { 'Authorization' => "Bearer #{self.token_auth}", 'Accept' => 'application/json', 'Content-Type' => 'application/json' }, verify: false)
				else
					HTTParty.get(uri_full(path), basic_auth: auth, timeout: 30, headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }, verify: false)
				end
			when 'head'
				if token_auth
					HTTParty.head(uri_full(path), timeout: 30, headers: { 'Authorization' => "Bearer #{self.token_auth}", 'Accept' => 'application/json', 'Content-Type' => 'application/json' }, verify: false)
				else
					HTTParty.head(uri_full(path), basic_auth: auth, timeout: 30, headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }, verify: false)
				end
			when 'delete'
				if token_auth
					HTTParty.delete(uri_full(path), timeout: 30, headers: { 'Authorization' => "Bearer #{self.token_auth}", 'Content-Type' => 'application/json', 'Accept' => 'application/json' }, verify: false)
				else
					HTTParty.delete(uri_full(path), basic_auth: auth, timeout: 30, headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }, verify: false)
				end
			else
				self.token_auth = nil
				return nil
			end
			if self.online && (rsp.code == 401 && rsp.headers['www-authenticate']) && !token_auth
				authenticate!(rsp.headers['www-authenticate'])
				exec!(http_method, path, data)
			else
				self.token_auth = nil
				rsp
			end
		end

		def version
			1
		end

		def is_docker_hub?
			self.host == "registry.hub.docker.com"
		end

		private

		def uri
			port == 443 ? "https://#{host}/v2" : "https://#{host}:#{port}/v2"
		end

		def uri_full(path = nil)
			path.nil? || path.strip == '' ? uri : "#{uri}/#{path}"
		end

		# helper to authenticate from auth header
		def authenticate!(headers = [])
			query_params = []
			headers.gsub('Bearer ', '').split(',').each do |el|
				k,v = el.split('=')
				if k == 'realm'
					self.token_endpoint = v.strip.gsub('"','')
				else
					query_params << el.strip.gsub('"','')
				end
			end
			self.online = req_auth_token!(query_params)
		end

		def req_auth_token!(params)
			return nil if self.token_endpoint.nil? || self.token_endpoint.strip == ''
			rsp = if auth.empty?
				HTTParty.get("#{self.token_endpoint}?#{params.join('&')}", verify: false)
			else
				HTTParty.get("#{self.token_endpoint}?#{params.join('&')}", basic_auth: auth, verify: false)
			end
			if rsp.code < 300
				data = JSON.parse(rsp.body)
				self.token_auth = data['token']
				!data['token'].nil? && data['token'] != ''
			end
			false
		end

	end
end
