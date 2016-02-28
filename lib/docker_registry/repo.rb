module DockerRegistry
  class Repo

    attr_accessor :host,
                  :port,
                  :username,
                  :password

    def initialize(host, port, user, pw)
      self.host = host
      self.port = port
      self.username = user
      self.password = pw
    end

    def images
      repos = client.exec!('get', 'v2/_catalog')
      if repos && repos['repositories'].empty?
        return []
      else
        result = []
        repos['repositories'].each do |i|
          result << DockerRegistry::Image.new(host, port, {username: username, password: password}, i)
        end
        return result
      end
    end

    def client
      DockerRegistry::Client.new(host, port, {username: username, password: password})
    end

  end
end