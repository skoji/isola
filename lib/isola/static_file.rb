module Isola
  class StaticFile
    attr_reader :path
    def initialize(path)
      @path = path
    end
  end
end
