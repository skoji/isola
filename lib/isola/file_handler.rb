module Isola
  class FileHandler
    attr_reader :pages, :layouts, :includes, :root_dir
    DEFAULT_EXCLUDES = [
      ".sass-cache", "gemfiles",
      "Gemfile", "Gemfile.lock", "node_modules",
      "vendor/bundle/", "vendor/cache/",
      "vendor/gems/", "vendor/ruby/"
    ]
    def initialize(root_dir, excludes: [])
      @excludes = DEFAULT_EXCLUDES.union(excludes)
      @rejects = Regexp.union(%r{(?:^|/)[._]}, %r{~$})
      @root_dir = File.absolute_path(root_dir)
      @pages = {}
      @layouts = {}
      @includes = {}
      collect(@root_dir)
    end

    def ignore?(absolute_path)
      !process_path?(absolute_path.delete_prefix("#{@root_dir}/"))
    end

    private

    def collect dir
      Dir.each_child(dir) do |entry|
        absolute_path = File.absolute_path(File.join(dir, entry))
        path = absolute_path.delete_prefix("#{@root_dir}/")
        path += "/" if File.directory? absolute_path
        if process_path? path
          if File.directory? absolute_path
            collect(absolute_path)
          elsif path.start_with?("_layouts/")
            @layouts[remove_exts(path).delete_prefix("_layouts/")] = path
          elsif path.start_with?("_includes/")
            @includes[remove_exts(path).delete_prefix("_includes/")] = path
          else
            @pages[remove_exts(path)] = path
          end
        end
      end
    end

    def process_path? path
      p =
        if /^(_includes|_layouts)\//.match?(path)
          path.sub(/^(_includes|_layouts)\//, "")
        else
          path
        end
      !@rejects.match?(p) &&
        !excluded?(path)
    end

    def excluded? relative_path
      is_directory = File.directory?(File.join(@root_dir, relative_path))
      @excludes.any? do |exclude|
        case exclude
        when String
          File.fnmatch?(exclude, relative_path) ||
            relative_path.start_with?(exclude) ||
            (exclude == "#{relative_path}/" if is_directory)
        when Regexp
          exclude.match?(relative_path)
        end
      end
    end

    def remove_exts(filepath)
      filepath.sub(%r{\.[^/]*\z}, "")
    end
  end
end
