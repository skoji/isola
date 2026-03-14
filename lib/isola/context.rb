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
      @content, path = @page.render(self)
      # 2. get layout from site
      # 3. do process layout
      # 4. if there's more layout, back to 2.
      [@content, path]
    end
  end
end
