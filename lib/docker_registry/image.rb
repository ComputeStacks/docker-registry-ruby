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
      client.exec!('get', "#{uri}/tags/list")
    end

    def find(tag = 'latest')
      JSON.parse(client.exec!('get', "v2/#{uri}/manifests/#{tag}"), :quirks_mode => true, :allow_nan => true)
    end

    def delete_tag(tag)
      false if tag == 'latest' # For now, prevent latest tag from being deleted.
      digest = client.exec!('get', "#{uri}/manifests/#{tag}").headers['docker-content-digest']
      client.exec!('delete', "#{uri}/manifests/#{digest}")
    end

    # Not implemented due to docker distribution API lack of support for deleting images.
    def destroy
      false
    end

    def client
      DockerRegistry::Client.new(host, port, auth)
		end

		private

		def uri
			"v2/#{image}"
		end

  end
end
