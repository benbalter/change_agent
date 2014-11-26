# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'change_agent/version'

Gem::Specification.new do |spec|
  spec.name          = "change_agent"
  spec.version       = ChangeAgent::VERSION
  spec.authors       = ["Ben Balter"]
  spec.email         = ["ben.balter@github.com"]
  spec.summary       = %q{A Git-backed key-value store, for tracking changes to documents and other files over time.}
  spec.homepage      = "https://github.com/benbalter/change-agent"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "git"
  spec.add_dependency "rugged"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
  spec.add_development_dependency('shoulda', '~> 3.5')
end
