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

    def [] key
      if key == :lang
        key = :default_language
      end
      @config[key]
    end

    def supported_ext? ext
      SUPPORTED_TILT_EXT.include? ext
    end

    def process_extensions(path)
      path = path.dup
      last_ext = nil
      while supported_ext?(ext = File.extname(path))
        yield(path, ext) if block_given?
        path.delete_suffix!(ext)
        last_ext = ext
      end
      ext.empty? ? path + result_ext_for(last_ext) : path
    end

    def output_path_for path
      process_extensions path
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

    def page name
      find_source(name, @parsed_pages, @file_handler.pages)
    end

    def pages
      Enumerator.new do |yielder|
        @file_handler.pages.each_key do |name|
          yielder.yield name, page(name)
        end
      end
    end

    private

    def result_ext_for ext
      return "" if ext.nil?
      EXT_MAP[ext]
    end

    def collect_files
      @file_handler = FileHandler.new(config[:root_dir], output_path_func: method(:output_path_for), excludes: @config[:excludes])
      @parsed_layouts = {}
      @parsed_includes = {}
      @parsed_pages = {}
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
      File.read(File.join(config[:root_dir], p))
    end
  end
end
