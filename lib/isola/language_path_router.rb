module Isola
  class LanguagePathRouter
    def initialize(default_language:, languages:)
      @default_language = default_language.to_s
      @languages = languages.map(&:to_s)
    end

    def language_for(path)
      p = Pathname(path).each_filename.to_a
      if p.length > 1 && @languages.include?(p[0])
        p[0].to_sym
      else
        @default_language.to_sym
      end
    end

    def canonical_path(path)
      p = Pathname(path).each_filename.to_a
      if p.length > 1 && @languages.include?(p[0])
        File.join(p[1..])
      else
        path
      end
    end

    def localized_path(path, language)
      canonical = canonical_path(path)
      if language.to_s == @default_language
        canonical
      else
        File.join(language.to_s, canonical)
      end
    end

    def candidate_paths(path)
      @languages.to_h { |lang| [lang.to_sym, localized_path(path, lang)] }
    end
  end
end
