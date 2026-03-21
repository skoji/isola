require "test_helper"

class TestLanguagePathRouter < Minitest::Test
  def test_without_languages
    r = Isola::LanguagePathRouter.new(default_language: :ja, languages: [:ja])
    assert_equal "index.html", r.canonical_path("index.html")
    assert_equal "en/index.html", r.canonical_path("en/index.html")
    assert_equal "en/index.html", r.localized_path("en/index.html", :ja)
    assert_equal({ja: "index.html"}, r.candidate_paths("index.html"))
    assert_equal :ja, r.language_for("index.html")
    assert_equal :ja, r.language_for("en/index.html")
  end

  def test_with_languages
    r = Isola::LanguagePathRouter.new(default_language: :ja, languages: [:ja, :en])
    assert_equal "index.html", r.canonical_path("index.html")
    assert_equal "index.html", r.canonical_path("en/index.html")
    assert_equal "en/index.html", r.localized_path("index.html", :en)
    assert_equal "index.html", r.localized_path("en/index.html", :ja)
    assert_equal "de/index.html", r.localized_path("de/index.html", :ja)
    assert_equal({ja: "index.html", en: "en/index.html"}, r.candidate_paths("index.html"))
    assert_equal :ja, r.language_for("index.html")
    assert_equal :en, r.language_for("en/index.html")
  end
end
