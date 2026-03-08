# frozen_string_literal: true

FIXTURES_DIR = File.join(__dir__, "fixtures")

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "isola"

require "minitest/autorun"
