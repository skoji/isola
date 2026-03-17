require "test_helper"
require "net/http"
require "tmpdir"

class TestReloadStream < Minitest::Test
  def setup
    @stream = ::Isola::ReloadStream.new
  end

  def teardown
    @stream.close unless @stream.closed?
  end

  def test_notify_and_readpartial
    @stream.notify
    buf = @stream.readpartial(1024)
    assert_equal "data: reload\n\n", buf
  end

  def test_readpartial_with_small_buffer
    @stream.notify
    buf1 = @stream.readpartial(5)
    assert_equal "data:", buf1
    buf2 = @stream.readpartial(1024)
    assert_equal " reload\n\n", buf2
  end

  def test_readpartial_with_provided_buffer
    @stream.notify
    buf = +""
    result = @stream.readpartial(1024, buf)
    assert_equal "data: reload\n\n", buf
    assert_same buf, result
  end

  def test_close_and_closed
    refute @stream.closed?
    @stream.close
    assert @stream.closed?
  end

  def test_readpartial_after_close_raises_eof
    @stream.close
    assert_raises(EOFError) { @stream.readpartial(1024) }
  end

  def test_multiple_notifications
    @stream.notify
    @stream.notify
    buf1 = @stream.readpartial(1024)
    buf2 = @stream.readpartial(1024)
    assert_equal "data: reload\n\n", buf1
    assert_equal "data: reload\n\n", buf2
  end
end

class TestDevServer < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir
    File.write(File.join(@tmpdir, "index.html"), "<html><body><p>hello</p></body></html>")
    File.write(File.join(@tmpdir, "style.css"), "body { color: red; }")
    @server = ::Isola::DevServer.new(@tmpdir, "127.0.0.1", 0)
  end

  def teardown
    @server.shutdown
    @server_thread&.join(5)
    FileUtils.remove_entry @tmpdir
  end

  def start_server
    @server_thread = Thread.new { @server.start }
    sleep 0.3
  end

  def server_port
    @server.instance_variable_get(:@server).config[:Port]
  end

  def test_serves_html_file
    start_server
    res = Net::HTTP.get_response("127.0.0.1", "/index.html", server_port)
    assert_equal "200", res.code
    assert_includes res.body, "<p>hello</p>"
  end

  def test_injects_reload_script_into_html
    start_server
    res = Net::HTTP.get_response("127.0.0.1", "/index.html", server_port)
    assert_includes res.body, 'EventSource("/_reload")'
    assert_includes res.body, "location.reload()"
  end

  def test_does_not_inject_script_into_non_html
    start_server
    res = Net::HTTP.get_response("127.0.0.1", "/style.css", server_port)
    refute_includes res.body, "EventSource"
  end

  def test_notify_reload_without_streams
    @server.notify_reload
  end

  def test_notify_reload_with_stream
    stream = ::Isola::ReloadStream.new
    @server.instance_variable_get(:@streams) << stream
    @server.notify_reload
    buf = stream.readpartial(1024)
    assert_equal "data: reload\n\n", buf
    stream.close
  end

  def test_notify_reload_removes_closed_streams
    stream = ::Isola::ReloadStream.new
    stream.close
    streams = @server.instance_variable_get(:@streams)
    streams << stream
    @server.notify_reload
    assert_empty streams
  end

  def test_remove_stream
    stream = ::Isola::ReloadStream.new
    streams = @server.instance_variable_get(:@streams)
    streams << stream
    @server.remove_stream(stream)
    assert_empty streams
    stream.close
  end

  def test_shutdown_closes_streams
    stream = ::Isola::ReloadStream.new
    @server.instance_variable_get(:@streams) << stream
    start_server
    @server.shutdown
    assert stream.closed?
  end

  def test_reload_endpoint_returns_event_stream
    start_server
    uri = URI("http://127.0.0.1:#{server_port}/_reload")
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 2
    http.read_timeout = 2
    req = Net::HTTP::Get.new(uri)
    response_headers = nil
    http.request(req) do |res|
      response_headers = {
        "content-type" => res["Content-Type"],
        "cache-control" => res["Cache-Control"]
      }
      break
    end
    assert_equal "text/event-stream", response_headers["content-type"]
    assert_equal "no-cache", response_headers["cache-control"]
  end
end
