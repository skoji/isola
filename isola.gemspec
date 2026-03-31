# frozen_string_literal: true

require_relative "lib/isola/version"

Gem::Specification.new do |spec|
  spec.name = "isola"
  spec.version = Isola::VERSION
  spec.authors = ["Satoshi Kojima"]
  spec.email = ["skoji@skoji.jp"]

  spec.summary = "simple static site generator using eRuby templates."
  spec.description = ""
  spec.homepage = "https://github.com/skoji/isola"
  spec.required_ruby_version = ">= 3.4.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/skoji/isola"
  spec.license = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/ .github/ .standard.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "tilt", ">=2.7"
  spec.add_runtime_dependency "kramdown", "~> 2.5"
  spec.add_runtime_dependency "thor", "~> 1.5"
  spec.add_runtime_dependency "webrick", "~> 1.9"
  spec.add_runtime_dependency "listen", "~> 3.10"
end
