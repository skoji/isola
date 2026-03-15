require "yaml"

module Isola
  class Source
    attr_reader :filepath, :meta, :content
    def initialize filepath, text
      @filepath = filepath
      @meta, @content = if (m = text.match(/\A---\s*\n(.+?)^---\s*\n(.*)\z/m))
        [YAML.safe_load(m[1], symbolize_names: true), m[2]]
      else
        [{}, text]
      end
    end

    def render(context, site, params = {})
      path = @filepath.dup
      rendered = @content.dup
      while !(ext = File.extname(path)).empty? && site.supported_ext?(ext)
        rendered = Tilt.new(path) { rendered }.render(context, params)
        path.delete_suffix! ext
        last_ext = ext
      end

      if !ext.empty?
        [rendered, path]
      else
        [rendered, path + site.result_ext_for(last_ext)]
      end
    end
  end
end
