# frozen_string_literal: true

require_relative "isola/version"
require_relative "isola/site"
require_relative "isola/file_handler"
require_relative "isola/source"
require_relative "isola/context"

module Isola
  class Error < StandardError; end
end
