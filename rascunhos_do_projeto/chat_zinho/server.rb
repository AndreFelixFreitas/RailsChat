require 'rubygems'
require 'eventmachine'

class Server < EM::Connect
  def receive_data(data)
    handle_input(data)
    send_data(data)
  end
end

EM.run do
  EM.start_server("0.0.0.0", 10000, Server)
end