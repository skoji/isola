require "yaml"

module Isola
  class Site
    attr_accessor :config
    DEFAULT_CONFIG = {url: "http://example.com", title: "my awesome site", destination: "_site", default_language: "en"}.freeze
    def initialize(config)
      @config = DEFAULT_CONFIG.merge(YAML.safe_load(config, symbolize_names: true) || {})
      @config[:root_dir] ||= Dir.getwd
    end

    def title
      @config[:title]
    end

    def url
      @config[:url]
    end

    def lang
      @config[:default_language]
    end

    def root_dir
      @config[:root_dir]
    end
  end
end
