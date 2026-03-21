require "yaml"
require "fileutils"
require "delegate"

module Isola
  class Site
    attr_accessor :config
    DEFAULT_CONFIG = {url: "http://example.com",
                      title: "my awesome site",
                      destination: "_site",
                      default_language: :en,
                      host: "127.0.0.1",
                      languages: {},
                      port: 4444}.freeze
    SUPPORTED_TILT_EXT = [".erb", ".md", ".markdown", ".mkd", ".html"]
    EXT_MAP = {".md" => ".html", ".mkd" => ".html", ".markdown" => ".html", ".html" => ".html", "" => ".html"}
    def initialize(config)
      @config = DEFAULT_CONFIG.merge(YAML.safe_load(config, symbolize_names: true) || {})
      @config[:default_language] = @config[:default_language].to_sym
      @config[:root_dir] ||= Dir.pwd
      @config[:excludes] ||= []
      @lang_router = LanguagePathRouter.new(
        default_language: default_language,
        languages: languages.keys
      )
      collect_files
    end

    def [] key
      @config[key]
    end

    def default_language
      @config[:default_language]
    end

    def languages
      @config[:languages]
    end

    def language_label(lang)
      @config[:languages][lang].to_h[:label]
    end

    def ext_to_process_with_tilt? ext
      SUPPORTED_TILT_EXT.include? ext
    end

    def process_extensions(path)
      path = path.dup
      last_ext = nil
      while ext_to_process_with_tilt?(ext = File.extname(path))
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
      FileUtils.rm_rf(dest_dir)
      entries.each do |name, entry|
        puts "building #{name}..."
        render_to_dest entry
      end
      puts "done."
    end

    def rebuild
      collect_files
      build
    end

    def url_path_for(path)
      # will support base_url for the future.
      File.join("/", path)
    end

    def url_path_for_lang(path, lang)
      url_path_for(@lang_router.localized_path(path, lang))
    end

    def ignore?(path)
      @file_handler.ignore?(path)
    end

    def layout name, lang: nil
      find_entry(name, @parsed_layouts, @file_handler.layouts, lang: lang)
    end

    def include name, lang: nil
      find_entry(name, @parsed_includes, @file_handler.includes, lang: lang)
    end

    def entry name
      find_entry(name, @parsed_entries, @file_handler.entries)
    end

    def entries
      Enumerator.new do |yielder|
        @file_handler.entries.each_key do |name|
          yielder.yield name, entry(name)
        end
      end
    end

    private

    def dest_dir
      File.join(@file_handler.root_dir, @config[:destination])
    end

    def render_to_dest entry
      if entry.instance_of? Source
        rendered, path = Context.new(entry, self, languages: languages).render
        dest_path = File.join(dest_dir, path)
        FileUtils.mkdir_p(File.dirname(dest_path))
        File.write(dest_path, rendered)
      elsif entry.instance_of? StaticFile
        path = entry.path
        src_path = File.join(config[:root_dir], path)
        dest_path = File.join(dest_dir, path)
        FileUtils.mkdir_p(File.dirname(dest_path))
        FileUtils.copy(src_path, dest_path)
      else
        raise "can't render class #{entry.class}"
      end
    end

    def result_ext_for ext
      return "" if ext.nil?
      EXT_MAP[ext]
    end

    def collect_files
      @file_handler = FileHandler.new(config[:root_dir], output_path_func: method(:output_path_for), excludes: @config[:excludes])
      @parsed_layouts = {}
      @parsed_includes = {}
      @parsed_entries = {}
    end

    def find_entry(name, cache, store, lang: nil)
      resolved = resolve_localized(name, store, lang)
      lang = @lang_router.language_for(resolved)
      cache[resolved] ||=
        begin
          p = store[resolved]
          return nil unless p
          if ext_to_process_with_tilt?(File.extname(p))
            translations = translations_for(resolved, store)
            Source.new(p, read_in_site(p), lang: lang, translations: translations)
          else
            StaticFile.new(p)
          end
        end
    end

    def resolve_localized(name, store, lang)
      return name unless lang && @lang_router.language_for(name) != lang
      localized = @lang_router.localized_path(name, lang)
      store[localized] ? localized : name
    end

    def translations_for(path, store)
      @lang_router.candidate_paths(path).select do |_, candidate|
        store.key?(candidate)
      end.transform_values do |candidate|
        url_path_for(candidate)
      end
    end

    def read_in_site(p)
      File.read(File.join(config[:root_dir], p))
    end
  end
end
