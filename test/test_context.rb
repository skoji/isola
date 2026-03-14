# frozen_string_literal: true

require "test_helper"

class TestContext < Minitest::Test
  def test_render_content
    page = ::Isola::Source.new("page.md.erb", <<~EOF
      ---
      layout: awesome_layout
      title: The title
      something_to_say: it is a beautiful day.
      ---
      This is the awesome content.
      I'd like to say; <%= page.something_to_say %>
    EOF
    )
    context = Isola::Context.new(page, Isola::Site.new(""))
    rendered, result_path = context.render_single_content(page.filepath.dup, page.content)
    assert_equal "<p>This is the awesome content.\nI'd like to say; it is a beautiful day.</p>\n", rendered
    assert_equal "page.html", result_path
  end
end
