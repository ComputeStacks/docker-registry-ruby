module DockerRegistry
  class Image

    attr_accessor :client,
                  :image_name

    def initialize(client, image_name)
			self.client = client
			self.image_name = image_name # cmptstks/woocommerce
    end

    def tags
      client.exec!('get', "#{self.image_name}/tags/list")
    end

    def find(tag = 'latest')
      JSON.parse(client.exec!('get', "#{self.image_name}/manifests/#{tag}"), quirks_mode: true, allow_nan: true)
    end

    def delete_tag(tag)
      false if tag == 'latest' # For now, prevent latest tag from being deleted.
      digest = client.exec!('get', "#{self.image_name}/manifests/#{tag}").headers['docker-content-digest']
      client.exec!('delete', "#{self.image_name}/manifests/#{digest}")
    end

    # Not implemented due to docker distribution API lack of support for deleting images.
    def destroy
      false
    end

  end
end
