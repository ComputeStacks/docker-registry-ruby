module DockerRegistry
  class Client

    attr_accessor :host,
                  :port,
                  :auth_username,
                  :auth_password,
                  :token_auth,
                  :token_endpoint,
                  :online,
                  :insecure_ssl

    # @param [Hash] auth `{username: 'username', password: 'password'}`
    def initialize(host, port, auth = {})
      self.host = (host.nil? || host.strip == '') ? "registry-1.docker.io" : host&.strip
      self.port = port.to_i == 0 ? 443 : port.to_i
      self.auth_username = auth[:username]
      self.auth_password = auth[:password]
      self.token_auth = nil
      self.token_endpoint = nil
      self.online = true
      self.insecure_ssl = false
    end

    def exec!(http_method, path, enable_basic_auth = true)
      req = if token_auth
              HTTP.headers(remote_req_headers).auth "Bearer #{token_auth}"
            elsif has_basic_auth? && enable_basic_auth
              HTTP.headers(remote_req_headers).basic_auth user: auth_username, pass: auth_password
            else
              HTTP.headers remote_req_headers
            end
      # Allow insecure for local tests.
      if insecure_ssl
        ctx = OpenSSL::SSL::SSLContext.new
        ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      rsp = case http_method
            when 'get'
              insecure_ssl ? req.get(uri_full(path), ssl_context: ctx) : req.get(uri_full(path))
            when 'head'
              insecure_ssl ? req.head(uri_full(path), ssl_context: ctx) : req.head(uri_full(path))
            when 'delete'
              insecure_ssl ? req.delete(uri_full(path), ssl_context: ctx) : req.delete(uri_full(path))
            else
              nil
            end
      return nil if rsp.nil?
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
      host == "registry-1.docker.io"
    end

    private

    def has_basic_auth?
      !(auth_username.nil? || auth_username == '') && !(auth_password.nil? || auth_password == '')
    end

    def uri
      port == 443 ? "https://#{host}" : "https://#{host}:#{port}"
    end

    def uri_full(path = nil)
      path.nil? || path.strip == '' ? "#{uri}/v2" : "#{uri}/v2/#{path}"
    end

    # helper to authenticate from auth header
    def authenticate!(auth_header)
      query_params = []
      unless auth_header =~ /Bearer/
        self.online = false
        return false
      end
      auth_header.gsub('Bearer ', '').split(',').each do |el|
        k, v = el.split('=')
        if k == 'realm'
          self.token_endpoint = v.strip.gsub('"', '')
        else
          query_params << el.strip.gsub('"', '')
        end
      end
      self.online = req_auth_token!(query_params)
    end

    def req_auth_token!(params)
      if token_endpoint.nil? || token_endpoint.strip == ''
        self.online = false
        return nil
      end
      req = if has_basic_auth?
              HTTP.headers(remote_req_headers).basic_auth user: auth_username, pass: auth_password
            else
              HTTP.headers remote_req_headers
            end
      rsp = if insecure_ssl
              ctx = OpenSSL::SSL::SSLContext.new
              ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
              req.get "#{token_endpoint}?#{params.join('&')}", ssl_context: ctx
            else
              req.get "#{token_endpoint}?#{params.join('&')}"
            end
      if rsp.status.success?
        data = Oj.load rsp.body.to_s
        self.token_auth = data['token']
        return !data['token'].nil? && data['token'] != ''
      end
      false
    end

    def remote_req_headers
      {
        'Accept' => 'application/vnd.docker.distribution.manifest.v2+json',
        'Content-Type' => 'application/json',
        'User-Agent' => 'docker/20.10.14'
      }
    end

  end
end
