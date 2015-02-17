require 'celluloid'
require 'celluloid/io'
require 'celluloid/websocket'
require 'celluloid/io/rack_socket'
require 'rack/request'
require 'forwardable'

module Celluloid
	class WebSocket
		def self.rack(config={})
			lambda do |env|
				# We need to create the pool in the first request
				# because we might've been forked before.
				@pool ||= pool(config)

				if env['HTTP_UPGRADE'].nil? || env['HTTP_UPGRADE'].downcase != 'websocket'
					return [400, {}, "No Upgrade header or Upgrade not for websocket."]
				end

				env['rack.hijack'].call
				socket = Celluloid::IO::RackSocket.new(env['rack.hijack_io'].to_io)
				
				@pool.async.initialize_websocket(env, socket)
				[200,{},""]
			end
		end
	end
end
