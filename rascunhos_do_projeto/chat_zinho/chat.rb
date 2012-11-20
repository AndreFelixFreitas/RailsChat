require "socket"


class ServerChat
  #inicializador
  def initialize ( port )
    @descriptors=[]
    @serverSocket= TCPServer.new( "0.0.0.0", port )
    @serverSocket.setsockopt( Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1 )
    puts "Servidor de chat porta: "+ port.to_s
    @descriptors.push( @serverSocket )
  end

def run
    while 1
      res = select( @descriptors,nil,nil,nil )
      if res != nil
        #interagindo com o descritor
        for sock in res[ 0 ]
          #tratamento do recebimento de conexao
          if sock == @serverSocket
            accept_new_connection
          elseif sock.eof?
            str = sprintf("Usuario %s:%s\n", sock.peeraddr[ 2 ], sock.peeraddr[ 1 ])
            broadcast_string( str, sock )
            sock.close
            @descriptors.delete(sock)
          else
            str = sprintf( "[%s|%s] : %s", sock.peeraddr[ 2 ], sock.peeraddr[ 1 ], sock.gets())
            broadcast_string( str, sock )
          end
        end
      end
    end
  #end
end # end run


  private

  def accept_new_connection
    newsock = @serverSocket.accept
    @descriptors.push( newsock )

    newsock.write(" Vc esta no servidor de chat\n")

    str = sprintf(" [%s:%s] acabou de entrar\n", newsock.peeraddr[ 2 ], newsock.peeraddr[ 1 ])
    broadcast_string( str, newsock )
  end

  def broadcast_string( str, omit_sock )
    @descriptors.each do |clisock|
        if clisock != @serverSocket && clisock != omit_sock
          clisock.write(str)
        end
      end
    puts str
  end


end

meuServerChat = ServerChat.new(2300)
meuServerChat.run

