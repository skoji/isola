module Isola
  class Watcher
    def initialize(site, &on_rebuild)
      @site = site
      @on_rebuild = on_rebuild
    end

    def handle_changes(modified, added, removed)
      paths = [*modified, *added, *removed]
      return if paths.all? { |path| @site.ignore?(path) }
      @site.rebuild
      @on_rebuild&.call
    end
  end
end
