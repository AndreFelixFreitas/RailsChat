# encoding: utf-8
require 'rubygems'
require 'eventmachine'

class Client < EM::Connection
  @message = ""
  def post_init
    # send_data("user")
  end

  def unbind
    send_data("exit")
  end

  def receive_data(data)
    puts (data)
  end
end

EventMachine.run do
  # press CTRL + C to stop connection
  Signal.trap("INT") { EventMachine.stop }
  Signal.trap("TERM") { EventMachine.stop }

  EventMachine.connect("0.0.0.0", 10000, Client)
end
