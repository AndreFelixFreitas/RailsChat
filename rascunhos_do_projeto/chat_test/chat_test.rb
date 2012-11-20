# encoding: utf-8
require 'rubygems'
require 'eventmachine'

class Server < EM::Connection
  def receive_data(data)
    send_data(data)
  end
end

EventMachine.run do
  # press CTRL + C to stop server
  Signal.trap("INT") { EventMachine.stop }
  Signal.trap("TERM") { EventMachine.stop }

  EventMachine.start_server("0.0.0.0", 10000, Server)
end