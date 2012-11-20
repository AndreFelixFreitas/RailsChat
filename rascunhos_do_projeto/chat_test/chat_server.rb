# encoding: utf-8
require 'rubygems'
require 'eventmachine'

class ChatServer < EM::Connection

  @@connected_clients = Array.new
  DM_REGEXP           = /^@([a-zA-Z0-9]+)\s*:?\s+(.+)/.freeze

  attr_reader :username

  # manipulação EventMachine
  def connection_completed
    # usuário conectado?
    mesg = "Voce conectou com sucesso!"
    send_data(mesg)
  end

  def receive_data(data)
    if entered_username?
      handle_chat_message(data.strip)
    else
      handle_username(data.strip)
    end
  end

  def post_init
    @username = nil
    puts "A client has connected..."
    ask_username
  end

  def unbind
    if entered_username?
      puts "[info] #{@username} has left..."
      self.announce("has left...", "#{@username}")
    end
    @@connected_clients.delete(self)
  end

  # manipulação de usernames
  def entered_username?
    !@username.nil? && !@username.empty?
  end

  def handle_username(input)
    if input.empty?
      send_line("Blank usernames are not allowed. Try again")
      ask_username
    else
      if repeat_username?(input)
        send_line("Username already exists. Try again")
        ask_username
      else
        @username = input
        @@connected_clients.push(self)
        self.other_peers.each { |c| c.send_data("#{@username} has joined the room\n") }
        self.send_line("[info] Ohai, #{@username}")
        puts "[info] #{@username} has joined"
      end
    end
  end

  def ask_username
    self.send_line("[info] Enter your username: ")
  end

  def repeat_username?(username)
    @@connected_clients.find { |c| c.username == username } ? true : false
  end

  # manipulação de mensagens
  def handle_chat_message(msg)
    if command?(msg)
      handle_command(msg)
    else
      if direct_message?(msg)
        self.handle_direct_message(msg)
      else
        self.announce(msg, "#{@username}")
      end
    end
  end

  def direct_message?(input)
    input =~ DM_REGEXP
  end

  def handle_direct_message(input)
    username, message = parse_direct_message(input)

    if connection = @@connected_clients.find { |c| c.username == username }
      puts "[dm] @#{@username} => @#{username}"
      connection.send_line("[dm] @#{@username}: #{message}")
    else
      send_line("@#{username} is not in the room.")
    end
  end

  def parse_direct_message(input)
    return [$1, $2] if input =~ DM_REGEXP
  end

  # manipul os comandos
  def command?(input)
    input =~ /(exit|status)$/i
  end

  def handle_command(cmd)
    case cmd
    when /exit$/i then self.close_connection
    when /status$/i then self.send_line("[chat server] It's #{Time.now.strftime('%H:%M')}")
    end
  end

  # helpers
  def announce(msg = nil, prefix = "[chat server]")
    @@connected_clients.each { |c| c.send_line("#{prefix}: #{msg}")} unless msg.empty?
  end

  def other_peers
    @@connected_clients.reject { |c| c == self}
  end

  def send_line(line)
    self.send_data("#{line}\n")
  end
end

EventMachine.run do
  # press CTRL + C to stop server
  Signal.trap("INT") { EventMachine.stop }
  Signal.trap("TERM") { EventMachine.stop }

  EventMachine.start_server("0.0.0.0", 10000, ChatServer)
end
