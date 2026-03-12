module Isola
  class FileHandler
    REJECTS = [/^_.*$/, /^~.*$/, /^\..*$/]
    attr_reader :pages, :layouts, :root_dir
    def initialize root_dir
      @rejects = Regexp.union(*REJECTS)
      @root_dir = root_dir
      @pages = Dir.glob("**/*", base: @root_dir).reject { @rejects.match it }
      @layouts = Dir.glob("**/*", base: File.join(@root_dir, "_layouts")).reject { @rejects.match it }
    end
  end
end
