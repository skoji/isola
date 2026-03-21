require "tilt"

module Isola
  class Context
    attr_reader :content, :layout
    def initialize(source, site, languages: {})
      @source = source
      @meta = source.meta.freeze
      @site = site
      @content = ""
      @layout = {}

      site_config = @site.config.merge(languages[@source[:lang]] || {})
      @site_proxy = SimpleDelegator.new(@site).tap do
        it.define_singleton_method(:[]) do |key|
          site_config[key]
        end
      end
    end

    def page
      @meta
    end

    def site
      @site_proxy
    end

    def lang_path path
      @site_proxy.url_path_for_lang(path, @source[:lang])
    end

    def include name, params = {}
      i = @site.include name, lang: @source[:lang]
      raise "include #{name} not found in #{@current.filepath}" unless i
      i.render(self, @site, params)[0]
    end

    def render
      @current = @source
      @content, path = @source.render(self, @site)
      while @current.meta[:layout]
        layout = site.layout(@current.meta[:layout], lang: @source[:lang])
        raise "#{@current.meta[:layout]} not found for #{@current.filepath}" unless layout
        @current = layout
        @content, _ = @current.render(self, @site)
      end
      [@content, path]
    end
  end
end
