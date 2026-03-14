# frozen_string_literal: true

require "test_helper"

class TestSite < Minitest::Test
  def test_initialize_site_with_empty_config
    site = ::Isola::Site.new("")
    assert_equal ::Isola::Site::DEFAULT_CONFIG.merge({root_dir: Dir.getwd}), site.config
    assert_equal ::Isola::Site::DEFAULT_CONFIG[:title], site.title
    assert_equal ::Isola::Site::DEFAULT_CONFIG[:url], site.url
    assert_equal ::Isola::Site::DEFAULT_CONFIG[:default_language], site.lang
    assert_equal Dir.getwd, site.root_dir
  end

  def test_initialize_site_with_config
    site = ::Isola::Site.new(<<~EOF
      url: https://skoji.jp
      title: skoji.jp web site
      destination: dest
      default_language: ja
      root_dir: /tmp
    EOF
                            )
    assert_equal({root_dir: "/tmp", url: "https://skoji.jp", title: "skoji.jp web site", destination: "dest", default_language: "ja"}, site.config)
    assert_equal "skoji.jp web site", site.title
    assert_equal "https://skoji.jp", site.url
    assert_equal "ja", site.lang
    assert_equal "/tmp", site.root_dir
  end

  def test_collect_files
    mock = Minitest::Mock.new
    mock.expect(:call, "new FileHandler Object", ["/the/root/dir"])
    ::Isola::FileHandler.stub(:new, mock) do
      site = ::Isola::Site.new("root_dir: /the/root/dir")
      site.collect_files
    end
    mock.verify
  end

  def test_layout
    root_dir = File.join(FIXTURES_DIR, "simple_dir")
    site = ::Isola::Site.new("root_dir: #{root_dir}")
    site.collect_files
    l = site.layout("default")
    assert_equal "_layouts/default.html.erb", l.filepath
    assert_equal "<html>\n  <head>\n    <title><%= page.title %></title>\n  </head>\n  <body>\n    <%= content %>\n  </body>\n</html>\n", l.content
  end

  def test_include
    root_dir = File.join(FIXTURES_DIR, "dir_with_include")
    site = ::Isola::Site.new("root_dir: #{root_dir}")
    site.collect_files
    i = site.include("head")
    assert_equal "_includes/head.html.erb", i.filepath
    assert_equal "<meta charset=\"utf-8\">\n<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\" />\n<meta title=\"<%= page.title %>\" >\n\n", i.content
  end
end
