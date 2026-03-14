require "tilt"

module Isola
  class Context
    attr_reader :site, :content, :layout
    def initialize(page, site)
      @page_source = page
      @page_meta = Data.define(*page.meta.keys).new(**page.meta)
      @site = site
      @content = ""
      @layout = {}
    end

    def page
      @page_meta
    end

    def render
      # 1. do process page content with tilt and set to content
      # 2. get layout from site
      # 3. do process layout
      # 4. if there's more layout, back to 2.
    end

    def render_single_content(path, source)
      rendered = source
      while !(ext = File.extname(path)).empty?
        && @site.is_supported_ext(ext)
        rendered = Tilt.new(path) { rendered }.render(self)
        path.delete_suffix! ext
      end

      if !ext.empty?
        [rendered, path]
      else
        [rendered, path.delete_suffix(ext) + @site.result_ext_for(ext)]
      end
    end
  end
end
