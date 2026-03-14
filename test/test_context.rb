# frozen_string_literal: true

require "test_helper"

class TestContext < Minitest::Test
  def test_render_on_simple_dir
    root_dir = File.join(FIXTURES_DIR, "simple_dir")
    site = Isola::Site.new("root_dir: #{root_dir}")
    site.collect_files
    p = site.instance_eval { @file_handler.pages["index"] }
    page = Isola::Source.new(p, File.read(File.join(root_dir, p)))
    context = Isola::Context.new(page, site)
    content, path = context.render
    assert_equal "<html>\n  <head>\n    <title>the main page</title>\n  </head>\n  <body>\n    <p>this is the main page.</p>\n\n  </body>\n</html>\n", content
    assert_equal "index.html", path
  end
end
