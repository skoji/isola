# frozen_string_literal: true

require "test_helper"

class TestSite < Minitest::Test
  def test_initialize_site_with_empty_config
    site = ::Isola::Site.new("")
    assert_equal ::Isola::Site::DEFAULT_CONFIG.merge({root_dir: Dir.pwd, excludes: []}), site.config
    assert_equal ::Isola::Site::DEFAULT_CONFIG[:title], site.title
    assert_equal ::Isola::Site::DEFAULT_CONFIG[:url], site.url
    assert_equal ::Isola::Site::DEFAULT_CONFIG[:default_language], site.lang
    assert_equal Dir.pwd, site.root_dir
  end

  def test_initialize_site_with_config
    site = ::Isola::Site.new(<<~EOF
      url: https://skoji.jp
      title: skoji.jp web site
      destination: dest
      default_language: ja
      root_dir: /tmp
      excludes: [ "README.md", "CLAUDE.md" ]
    EOF
                            )
    assert_equal({excludes: ["README.md", "CLAUDE.md"],
                  root_dir: "/tmp",
                  url: "https://skoji.jp",
                  title: "skoji.jp web site",
                  destination: "dest",
                  default_language: "ja"}, site.config)
    assert_equal "skoji.jp web site", site.title
    assert_equal "https://skoji.jp", site.url
    assert_equal "ja", site.lang
    assert_equal "/tmp", site.root_dir
  end

  def test_layout
    root_dir = File.join(FIXTURES_DIR, "simple_dir")
    site = ::Isola::Site.new("root_dir: #{root_dir}")
    l = site.layout("default")
    assert_equal "_layouts/default.html.erb", l.filepath
    expected = <<~EOF
      <html>
        <head>
          <title><%= page.title %></title>
        </head>
        <body>
          <%= content %>
        </body>
      </html>
    EOF
    assert_equal expected, l.content
  end

  def test_include
    root_dir = File.join(FIXTURES_DIR, "dir_with_include")
    site = ::Isola::Site.new("root_dir: #{root_dir}")
    i = site.include("head")
    assert_equal "_includes/head.html.erb", i.filepath
    expected = <<~EOF
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <meta title="<%= page.title %>" >
      <% if og_type %>
      <meta og:type="<%= og_type %>" >
      <% end %>
    EOF
    assert_equal expected, i.content
  end

  def test_build
    f = File.join(FIXTURES_DIR, "dir_with_css")
    site = ::Isola::Site.new("root_dir: #{f}")
    site.build
    dest = File.join(f, "_site")
    generated = Dir.glob("**/*", base: dest).sort
    assert_equal ["another_page.html", "css", "css/main.css", "index.html"], generated
    assert File.directory? File.join(dest, "css")
    assert_file_eq File.join(f, "css", "main.css"), File.join(dest, "css", "main.css")
    expected_index = <<~EOF
      <html>
        <head>
          <title>the main page</title>
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <link href="/css/main.css" rel="stylesheet">
      
        </head>
        <body>
          <p>this is the main page.</p>
      
        </body>
      </html>
    EOF
    assert_equal expected_index, File.read(File.join(dest, "index.html"))
    expected_another = <<~EOF
      <html>
        <head>
          <title>page_with_erb</title>
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <link href="/css/main.css" rel="stylesheet">
      
        </head>
        <body>
          <p>the data is foobar</p>
      
        </body>
      </html>
    EOF
    assert_equal expected_another, File.read(File.join(dest, "another_page.html"))
  end

  def test_build_clear_destination
    f = File.join(FIXTURES_DIR, "simple_dir")
    dest = File.join(f, "_site")
    File.write(File.join(dest, "unrelated_file.txt"), "some text")
    site = ::Isola::Site.new("root_dir: #{f}")
    site.build
    generated = Dir.glob("**/*", base: dest).sort
    assert_equal ["another_page.html", "index.html"], generated
  end
end
