# frozen_string_literal: true

require "test_helper"

class TestSite < Minitest::Test
  def test_initialize_site_with_empty_config
    site = ::Isola::Site.new("")
    assert_equal site.config, ::Isola::Site::DEFAULT_CONFIG
  end

  def test_initialize_site_with_config
    site = ::Isola::Site.new(<<~EOF
      url: https://skoji.jp
      title: Satoshi Kojima
      destination: dest
      default_language: ja
    EOF
                            )
    assert_equal site.config, {url: "https://skoji.jp", title: "Satoshi Kojima", destination: "dest", default_language: "ja"}
  end
end
