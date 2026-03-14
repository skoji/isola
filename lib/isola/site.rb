require "yaml"

module Isola
  class Site
    attr_accessor :config
    DEFAULT_CONFIG = {url: "http://example.com", title: "my awesome site", destination: "_site", default_language: "en"}.freeze
    SUPPORTED_TILT_EXT = [".erb", ".md", ".markdown", ".mkd"]
    EXT_MAP = {".md" => ".html", ".mkd" => ".html", ".markdown" => ".html", "" => ".html"}
    def initialize(config)
      @config = DEFAULT_CONFIG.merge(YAML.safe_load(config, symbolize_names: true) || {})
      @config[:root_dir] ||= Dir.getwd
      @parsed_layouts = {}
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

    def is_supported_ext ext
      SUPPORTED_TILT_EXT.include? ext
    end

    def result_ext_for ext
      EXT_MAP[ext]
    end

    def collect_files
      @file_handler = FileHandler.new(root_dir)
    end
  end
end
