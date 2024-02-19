# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

use Rack::ReverseProxy do
  reverse_proxy /^\/blog(\/.*)$/, 'https://blog.grouvly.com$1', timeout: 500, preserve_host: true
end

run Rails.application
