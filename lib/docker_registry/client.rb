module DockerRegistry
  class Client

    attr_accessor :host,
                  :port,
                  :auth

    #auth = {username: 'username', password: 'password'}
    def initialize(host, port, auth)
      self.host = host
      self.port = port
      self.auth = auth
    end

    def exec!(http_method, path, data = {})
      case http_method
        when 'get'
          HTTParty.get("https://#{host}:#{port}/#{path}", :basic_auth => auth, :timeout => 30, :headers => { 'Content-Type' => 'application/json' }, verify: false)
        when 'delete'
          HTTParty.delete("https://#{host}:#{port}/#{path}", :basic_auth => auth, :timeout => 30, :headers => { 'Content-Type' => 'application/json' }, verify: false)
      end
    end

  end
end
