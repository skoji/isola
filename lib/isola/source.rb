require "yaml"

module Isola
  class Source
    attr_reader :filepath, :meta, :content
    def initialize filepath, text
      @filepath = filepath
      @meta, @content = if text =~ /\A---\s*\n(.+?)^---\s*\n(.*)\z/m
        [YAML.safe_load($1, symbolize_names: true), $2]
      else
        [nil, text]
      end
    end
  end
end
