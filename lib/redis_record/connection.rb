require "kgio"

module RedisRecord
  class Connection < Object
    def authenticated?
      @authenticated ||= false
    end

    def connected?
      @connected ||= false
    end

    def initialize(host = 'localhost', port = 5005)
      @host = host
      @port = port
    end

    def open
      begin
        # Connect or restore the connection
        # from the cache
        @connected = true
        @connection ||= TCPSocket.open(@host, @port)
        self
      rescue Exception
        # Avoid unpredictable state
        # if the connection died
        @connection = nil
        @connected = false
        # Re-raise the exception
        # TODO: add custom exception class
        raise Exception.new('Could not connect to server!')
      end
    end

    def close
      @connection.close if connected?
      @connected = false
      @authenticated =  false
    end

    def send(request)
      if @connection.nil? || @connection.closed?
        # Open new connection
        @connection = Kgio::TCPSocket.open(@host, @port)

        # Authenticate against new connection
        @connection.puts("AUTHME: 1376bf359b92657f29d2446da42d27e9")
        @connection.gets
      end

      begin
        @connection.puts(request)
        return ActiveSupport::JSON.decode(@connection.gets)  
      rescue Errno::EPIPE
        @connection.close
        @connection = nil
        return send(request)
      end
      

      # open unless connected?
      # authenticate! unless authenticated?

      # begin
      #   @connection.puts(request)
      #   ActiveSupport::JSON.decode(@connection.gets)
      # rescue
      #   @connection.close unless @connection.closed?
      #   @connection = TCPSocket.open(@host, @port)
      # end
    end

    # TODO: store authentication token in model
    def authenticate!(token = "1376bf359b92657f29d2446da42d27e9")
      unless authenticated?
        @connection.puts("AUTHME: #{token}")
        @connection.gets
        @authenticated = true
      end
    end
  end
end