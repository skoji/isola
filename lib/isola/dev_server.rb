require "webrick"

module Isola
  class ReloadStream
    def initialize
      @queue = Queue.new
    end

    def readpartial(maxlen, buf = +"")
      if !@data
        @data = @queue.pop.dup
        @data.force_encoding(Encoding::ASCII_8BIT)
      end

      if @data.bytesize <= maxlen
        buf.replace(@data)
        @data = nil
      else
        buf.replace(@data.byteslice(0, maxlen))
        @data = @data.byteslice(maxlen..-1) || ""
      end

      buf
    rescue
      raise EOFError
    end

    def notify
      @queue.push("data: reload\n\n")
    end

    def close
      @queue.close
    end

    def closed?
      @queue.closed?
    end
  end

  class DevServer
    def initialize(root_dir, host, port)
      @root_dir = File.expand_path(root_dir)
      @host = host
      @port = port
      @streams = []
      @mutex = Mutex.new
    end

    def start
      @server = WEBrick::HTTPServer.new(BindAddress: @host, Port: @port)
      @server.mount("/", LiveFileHandler, @root_dir)
      @server.mount_proc("/_reload") do |req, res|
        stream = ReloadStream.new
        @mutex.synchronize { @streams << stream }
        res["Content-Type"] = "text/event-stream"
        res["Cache-Control"] = "no-cache"
        res["Connection"] = "keep-alive"
        res.chunked = true
        res.body = stream
      end

      trap("INT") do
        @streams.each(&:close)
        @server.shutdown
      end

      @server.start
    end

    def remove_stream stream
      @mutex.synchronize { @streams.delete(stream) }
    end

    def notify_reload
      @mutex.synchronize {
        @streams.reject!(&:closed?)
        @streams.each(&:notify)
      }
    end

    def shutdown
      @mutex.synchronize {
        @streams.each(&:close)
      }
      @server&.shutdown
    end
  end

  # for live reload
  class LiveFileHandler < WEBrick::HTTPServlet::FileHandler
    RELOAD_SCRIPT = <<~HTML
      <script>new EventSource("/_reload").onmessage=()=>location.reload()</script>
    HTML
    def do_GET(req, res)
      super
      if res["Content-Type"]&.include?("text/html")
        if res.body.is_a?(IO)
          io = res.body
          html = io.read
          io.close
        else
          html = res.body
        end
        res.body = html.sub(%r{</body>}i, "#{RELOAD_SCRIPT}</body>")
        res["Content-Length"] = res.body.bytesize
      end
    end
  end
end
