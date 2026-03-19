# frozen_string_literal: true

require "test_helper"

class TestContext < Minitest::Test
  def test_render_on_simple_dir
    root_dir = File.join(FIXTURES_DIR, "simple_dir")
    site = Isola::Site.new("root_dir: #{root_dir}")
    p = site.instance_eval { @file_handler.pages["index.html"] }
    page = Isola::Source.new(p, File.read(File.join(root_dir, p)))
    context = Isola::Context.new(page, site)
    content, path = context.render
    assert_equal "<html>\n  <head>\n    <title>the main page</title>\n  </head>\n  <body>\n    <p>this is the main page.</p>\n\n  </body>\n</html>\n", content
    assert_equal "index.html", path
  end

  def test_render_with_include
    root_dir = File.join(FIXTURES_DIR, "dir_with_include")
    site = Isola::Site.new("root_dir: #{root_dir}")
    p = site.instance_eval { @file_handler.pages["main.html"] }
    page = Isola::Source.new(p, File.read(File.join(root_dir, p)))
    context = Isola::Context.new(page, site)
    cont, path = context.render
    expected_cont = <<~EOF
      <html lang="en">
        <head>
          <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <meta title="main page" >
      <meta og:type="website" >
      
        </head>
        <body>
          <section id="content">
        <p>main page.</p>
      
      </section>
      
        </body>
      </html>
    EOF
    assert_equal expected_cont, cont
    assert_equal "main.html", path
  end
end
