require "yaml"

module Isola
  class Site
    attr_accessor :config
    DEFAULT_CONFIG = {url: "http://example.com", title: "my awesome site", destination: "public", default_language: "en"}.freeze
    def initialize(config)
      @config = DEFAULT_CONFIG.merge(YAML.safe_load(config, symbolize_names: true) || {})
    end
  end
end
