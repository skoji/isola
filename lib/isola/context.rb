require "tilt"

module Isola
  class Context
    attr_reader :site, :content, :layout
    def initialize(source, site)
      @source = source
      @meta = {lang: site[:lang]}.merge(source.meta).freeze
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
      @current = @source
      @content, path = @source.render(self, @site)
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
