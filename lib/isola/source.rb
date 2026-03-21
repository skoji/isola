require "yaml"

module Isola
  class Source
    attr_reader :filepath, :meta, :content
    def initialize filepath, text, lang
      @filepath = filepath
      @meta, @content = if (m = text.match(/\A---\s*\n(.+?)^---\s*\n(.*)\z/m))
        [YAML.safe_load(m[1], symbolize_names: true) || {}, m[2]]
      else
        [{}, text]
      end
      @meta[:lang] = lang
    end

    def [] key
      @meta[key]
    end

    def render(context, site, params = {})
      rendered = @content.dup
      output_path = site.process_extensions(@filepath) do |current_path, _ext|
        rendered = Tilt.new(current_path) { rendered }.render(context, params)
      end
      [rendered, output_path]
    end
  end
end
