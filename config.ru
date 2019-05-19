require './server'

run Rack::URLMap.new({
	"/" => Public,
  "/digest_auth" => Protected
})
