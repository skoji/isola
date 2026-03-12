# frozen_string_literal: true

require "test_helper"

class TestSource < Minitest::Test
  def test_with_simple_md
    source = ::Isola::Source.new("page.md", <<~EOF
      ---
      layout: awesome_layout
      title: this is it!
      ---
      This is the awesome content
    EOF
    )
    filepath, meta, content = source.filepath, source.meta, source.content
    assert_equal("page.md", filepath, filepath)
    assert_equal({layout: "awesome_layout", title: "this is it!"}, meta)
    assert_equal("This is the awesome content", content.strip)
  end
end
