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

    def layout name
      if !@parsed_layouts[name]
        p = @file_handler.layouts[name]
        return nil if !p
        @parsed_layouts[name] = Source.new(p, read_in_site(p))
      end
      @parsed_layouts[name]
    end

    def read_in_site(p)
      File.read(File.join(root_dir, p))
    end
  end
end
