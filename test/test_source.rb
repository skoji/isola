# frozen_string_literal: true

require "test_helper"

class TestSource < Minitest::Test
  def test_with_simple_md
    text = <<~EOF
      ---
      layout: awesome_layout
      title: this is it!
      ---
      This is the awesome content
    EOF
    source = ::Isola::Source.new("page.md", text, lang: :ja)
    filepath, meta, content = source.filepath, source.meta, source.content
    assert_equal("page.md", filepath, filepath)
    assert_equal({layout: "awesome_layout", title: "this is it!", lang: :ja, translations: {}}, meta)
    assert_equal("This is the awesome content", content.strip)
    assert_equal("awesome_layout", source[:layout])
    assert_equal("this is it!", source[:title])
    assert_nil(source["title"])
  end

  def test_render_as_page
    text = <<~EOF
      ---
      layout: awesome_layout
      title: The title
      something_to_say: it is a beautiful day.
      ---
      This is the awesome content.
      I'd like to say. <%= page[:something_to_say] %>
    EOF
    source = ::Isola::Source.new("page.md.erb", text, lang: :en)
    site = Isola::Site.new("")
    context = Isola::Context.new(source, site)
    rendered, result_path = source.render(context, site)
    assert_equal "<p>This is the awesome content.\nI'd like to say. it is a beautiful day.</p>\n", rendered
    assert_equal "page.html", result_path
  end
end
