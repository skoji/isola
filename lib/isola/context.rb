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

    def include name, params = {}
      i = @site.include name
      raise "include #{name} not found in #{@current.filepath}" unless i
      i.render(self, @site, params)[0]
    end

    def render
      @content, path = @page_source.render(self, @site)
      @current = @page_source
      while @current.meta[:layout]
        @current = site.layout(@current.meta[:layout])
        if !@current
          raise "#{@current.meta[:layout]} not found for #{@current.filepath}"
        end
        @content, _ = @current.render(self, @site)
      end
      [@content, path]
    end
  end
end
