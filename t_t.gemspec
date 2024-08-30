# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = 't_t'
  spec.version       = '1.4.0'
  spec.authors       = ['Sergii Pchelintsev']
  spec.email         = %w[sergii.pchelintsev@gmail.com]
  spec.summary       = 'An opinioned I18n helper'
  spec.description   = 'An opinioned I18n helper'
  spec.homepage      = ''
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.7'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w[lib]

  spec.add_dependency 'i18n', '>= 0.6'
  spec.add_dependency 'activesupport', '>= 5.2'

  spec.add_development_dependency 'rails', '>= 5.2'
  spec.add_development_dependency 'bundler', '>= 2.3'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'rake'
end
