# frozen_string_literal: true

FIXTURES_DIR = File.join(__dir__, "fixtures")

def assert_file_eq(expected, actual)
  assert_equal File.read(expected), File.read(actual)
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "isola"

require "minitest/autorun"
require "minitest/mock"
