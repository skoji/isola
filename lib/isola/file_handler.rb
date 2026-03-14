def remove_exts(filepath)
  filepath.sub(%r{\.[^/]*\z}, "")
end

module Isola
  class FileHandler
    attr_reader :pages, :layouts, :includes, :root_dir

    def initialize(root_dir)
      @rejects = Regexp.union(%r{(?:^|/)[._]}, %r{~$})
      @root_dir = root_dir
      @pages = Dir.glob("**/*", base: @root_dir).reject { @rejects.match it }.to_h { [remove_exts(it), it] }
      @layouts = Dir.glob("**/*", base: File.join(@root_dir, "_layouts"))
        .reject { @rejects.match it }
        .to_h do
          [remove_exts(it),
            File.join("_layouts", it)]
      end
      @includes = Dir.glob("**/*", base: File.join(@root_dir, "_includes"))
        .reject { @rejects.match it }
        .to_h do
          [remove_exts(it),
            File.join("_includes", it)]
      end
    end
  end
end
