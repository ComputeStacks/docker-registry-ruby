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

		def tag_available?(tag = 'latest')
			client.exec!('get', tag_uri(tag)).code == 200
		rescue
			false
		end

		def find_tag(tag = 'latest')
			return nil unless tag_available?(tag)
      JSON.parse(client.exec!('get', tag_uri(tag)), quirks_mode: true, allow_nan: true)
    end

		def delete_tag(tag)
			return false unless tag_available?(tag)
      false if tag == 'latest' # For now, prevent latest tag from being deleted.
      digest = client.exec!('get', tag_uri(tag)).headers['docker-content-digest']
      client.exec!('delete', layer_uri(digest))
		end

    # Not implemented due to docker distribution API lack of support for deleting images.
    def destroy
      false
		end

		private

		def tag_uri(tag = 'latest')
			"#{self.image_name}/manifests/#{tag}"
		end

		def layer_uri(digest)
			"#{self.image_name}/manifests/#{digest}"
		end

  end
end
