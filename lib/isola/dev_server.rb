require "webrick"

module Isola
  class DevServer
    def initialize(root_dir, host, port)
      @root_dir = File.expand_path(root_dir)
      @host = host
      @port = port
    end

    def start
      @server = WEBrick::HTTPServer.new(BindAddress: @host, Port: @port)
      @server.mount("/", WEBrick::HTTPServlet::FileHandler, @root_dir)
      trap("INT") { @server.shutdown }
      @server.start
    end

    def shutdown
      @server&.shutdown
    end
  end
end
