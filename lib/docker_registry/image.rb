module DockerRegistry
	class Image

		attr_accessor :client,
									:image_name

		def initialize(client, image_name)
			self.client = client
			self.image_name = image_name # cmptstks/woocommerce
		end

		def tags
			data = client.exec!('get', "#{self.image_name}/tags/list")
			if data.status < 300
				JSON.parse(data.body)
			else
				[]
			end
		end

		def tag_available?(tag = 'latest')
			client.exec!('head', tag_uri(tag)).status == 200
		rescue
			false
		end

		def find_tag(tag = 'latest')
			return nil unless tag_available?(tag)
			data = client.exec!('get', tag_uri(tag))
			if data.status < 300
				JSON.parse(data.body, quirks_mode: true, allow_nan: true)
			else
				{}
			end
		end

		# WARNING! This will delete this tag, and any other tags that share the same reference.
		#
		# For example, if the tag 'latest' and 'v1' are the same on-disk image, deleting one will delete the other too.
		#
		# Additionally, deleting the tag WILL NOT delete the files on disk.
		#
		def delete_tag!(tag)
			return false if tag.nil? || tag == ''
			return false unless tag_available?(tag)
			digest = client.exec!('get', tag_uri(tag)).headers['docker-content-digest']
			client.exec!('delete', layer_uri(digest)).status == 202
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
