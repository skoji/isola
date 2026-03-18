require "tilt"

module Isola
  class Context
    attr_reader :site, :content, :layout
    def initialize(page, site)
      @page_source = page
      @meta = {lang: site[:lang]}.merge(page.meta).freeze
      @site = site
      @content = ""
      @layout = {}
    end

    def page
      @meta
    end

    def include name, params = {}
      i = @site.include name
      raise "include #{name} not found in #{@current.filepath}" unless i
      i.render(self, @site, params)[0]
    end

    def render
      @current = @page_source
      @content, path = @page_source.render(self, @site)
      while @current.meta[:layout]
        layout = site.layout(@current.meta[:layout])
        raise "#{@current.meta[:layout]} not found for #{@current.filepath}" unless layout
        @current = layout
        @content, _ = @current.render(self, @site)
      end
      [@content, path]
    end
  end
end
