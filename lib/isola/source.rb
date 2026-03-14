require "yaml"

module Isola
  class Source
    attr_reader :filepath, :meta, :content
    def initialize filepath, text
      @filepath = filepath
      @meta, @content = if text =~ /\A---\s*\n(.+?)^---\s*\n(.*)\z/m
        [YAML.safe_load($1, symbolize_names: true), $2]
      else
        [{}, text]
      end
    end

    def render(context, site)
      path = @filepath.dup
      rendered = @content.dup
      while !(ext = File.extname(path)).empty?
        && site.is_supported_ext(ext)
        rendered = Tilt.new(path) { rendered }.render(context)
        path.delete_suffix! ext
      end

      if !ext.empty?
        [rendered, path]
      else
        [rendered, path.delete_suffix(ext) + site.result_ext_for(ext)]
      end
    end
  end
end
