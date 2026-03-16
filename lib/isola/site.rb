require "yaml"
require "fileutils"
module Isola
  class Site
    attr_accessor :config
    DEFAULT_CONFIG = {url: "http://example.com",
                      title: "my awesome site",
                      destination: "_site",
                      default_language: "en",
                      host: "127.0.0.1",
                      port: 4444}.freeze
    SUPPORTED_TILT_EXT = [".erb", ".md", ".markdown", ".mkd"]
    EXT_MAP = {".md" => ".html", ".mkd" => ".html", ".markdown" => ".html", "" => ".html"}
    def initialize(config)
      @config = DEFAULT_CONFIG.merge(YAML.safe_load(config, symbolize_names: true) || {})
      @config[:root_dir] ||= Dir.pwd
      @config[:excludes] ||= []
      collect_files
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

    def supported_ext? ext
      SUPPORTED_TILT_EXT.include? ext
    end

    def result_ext_for ext
      EXT_MAP[ext]
    end

    def build
      dest_dir = File.join(@file_handler.root_dir, @config[:destination])
      FileUtils.rm_rf(dest_dir)
      @file_handler.pages.each do |name, path|
        page = Source.new(path, read_in_site(path))
        puts "building #{path}..."
        rendered, path = Context.new(page, self).render
        dest_path = File.join(dest_dir, path)
        FileUtils.mkdir_p(File.dirname(dest_path))
        File.write(dest_path, rendered)
      end
      puts "done."
    end

    def rebuild
      collect_files
      build
    end

    def ignore?(path)
      @file_handler.ignore?(path)
    end

    def layout name
      find_source(name, @parsed_layouts, @file_handler.layouts)
    end

    def include name
      find_source(name, @parsed_includes, @file_handler.includes)
    end

    private

    def collect_files
      @file_handler = FileHandler.new(root_dir, excludes: @config[:excludes])
      @parsed_layouts = {}
      @parsed_includes = {}
    end

    def find_source(name, cache, store)
      cache[name] ||=
        begin
          p = store[name]
          return nil unless p
          Source.new(p, read_in_site(p))
        end
    end

    def read_in_site(p)
      File.read(File.join(root_dir, p))
    end
  end
end
