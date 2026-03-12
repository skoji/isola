require "yaml"

module Isola
  class Source
    attr_reader :filename, :meta, :content
    def initialize filename, text
      @filename = filename
      @meta, @content = if text =~ /\A---\s*\n(.+?)^---\s*\n(.*)\z/m
        [YAML.safe_load($1, symbolize_names: true), $2]
      else
        [nil, text]
      end
    end
  end
end
