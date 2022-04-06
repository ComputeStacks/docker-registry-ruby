# Docker Container Registry

## Environmental Variables

We use [direnv](https://direnv.net/) to manage our env file, alternatively you can manually export the variables. See `envrc.sample` for details.

Using _direnv_, you can:

* `mv envrc.sample .envrc` and adjust accordingly
* run `direnv allow .`

### Token Auth Tests

Please note that the environmental variables starting with `GL_` should be set to a registry that is using token authentication, such as Gitlab's container registry. The other should be basic auth. Additionally, the `GL_REGISTRY_IMAGE` variable should be the image, with the tag omitted. The test will automatically add the `latest` tag.
