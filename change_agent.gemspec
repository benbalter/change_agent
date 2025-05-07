lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'change_agent/version'

Gem::Specification.new do |spec|
  spec.name          = 'change_agent'
  spec.version       = ChangeAgent::VERSION
  spec.authors       = ['Ben Balter']
  spec.email         = ['ben.balter@github.com']
  spec.summary       = 'A Git-backed key-value store, for tracking changes to documents and other files over time.'
  spec.homepage      = 'https://github.com/benbalter/change-agent'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'dotenv', '>= 3.1', '< 4.0'
  spec.add_dependency 'rugged', '>= 1.9', '< 2.0'
  spec.add_development_dependency 'bundler', '>= 2.0', '< 3.0'
  spec.add_development_dependency 'pry', '>= 0.15', '< 1.0'
  spec.add_development_dependency 'rake', '>= 13.0', '< 14.0'
  spec.add_development_dependency 'rubocop', '>= 1.0', '< 2.0'
  spec.add_development_dependency 'shoulda', '>= 4.0', '< 5.0'
end
