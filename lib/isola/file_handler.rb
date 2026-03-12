def remove_ext(filepath)
  filepath.sub(%r{\.[^/]*\z}, "")
end

module Isola
  class FileHandler
    attr_reader :pages, :layouts, :root_dir

    def initialize(root_dir)
      @rejects = %r{(?:^|/)[._~]}
      @root_dir = root_dir
      @pages = Dir.glob("**/*", base: @root_dir).reject { @rejects.match it }.to_h { [remove_ext(it), it] }
      @layouts = Dir.glob("**/*", base: File.join(@root_dir, "_layouts"))
        .reject { @rejects.match it }
        .to_h do
          [remove_ext(it),
            File.join("_layouts", it)]
      end
    end
  end
end
