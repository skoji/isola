# frozen_string_literal: true

require "test_helper"

class TestSite < Minitest::Test
  def test_initialize_site_with_empty_config
    site = ::Isola::Site.new("")
    assert_equal site.config, ::Isola::Site::DEFAULT_CONFIG
    assert_equal site.title, ::Isola::Site::DEFAULT_CONFIG[:title]
    assert_equal site.url, ::Isola::Site::DEFAULT_CONFIG[:url]
    assert_equal site.lang, ::Isola::Site::DEFAULT_CONFIG[:default_language]
  end

  def test_initialize_site_with_config
    site = ::Isola::Site.new(<<~EOF
      url: https://skoji.jp
      title: skoji.jp web site
      destination: dest
      default_language: ja
    EOF
                            )
    assert_equal site.config, {url: "https://skoji.jp", title: "skoji.jp web site", destination: "dest", default_language: "ja"}
    assert_equal site.title, "skoji.jp web site"
    assert_equal site.url, "https://skoji.jp"
    assert_equal site.lang, "ja"
  end
end
