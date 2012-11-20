require 'rubygems'
require 'eventmachine'

class Client < EM::Connect
  def receive_data(data)
    puts data
  end
end

EM.run do
  EM.connect_server("0.0.0.0", 10000, Client)
end