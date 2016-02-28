module DockerRegistry
  class Image

    attr_accessor :host,
                  :port,
                  :auth,
                  :image

    def initialize(host, port, auth, image)
      self.host = host
      self.port = port
      self.auth = auth
      self.image = image
    end

    def tags
      client.exec!('get', "v2/#{image}/tags/list")
    end

    def find(tag = 'latest')
      JSON.parse(client.exec!('get', "v2/#{image}/manifests/#{tag}"), :quirks_mode => true, :allow_nan => true)
    end

    def delete_tag(tag)
      false if tag == 'latest' # For now, prevent latest tag from being deleted.
      digest = client.exec!('get', "v2/#{image}/manifests/#{tag}").headers['docker-content-digest']
      client.exec!('delete', "v2/#{image}/manifests/#{digest}")
    end

    # Not implemented due to docker distribution API issues.
    def destroy
      false
    end

    def client
      DockerRegistry::Client.new(host, port, auth)
    end

  end
end