# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "t_t"
  spec.version       = "1.2.2"
  spec.authors       = ["Sergey Pchelintsev"]
  spec.email         = ["mail@sergeyp.me"]
  spec.summary       = %q{An opinioned I18n helper}
  spec.description   = %q{An opinioned I18n helper}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "i18n", ">= 0.6.0"
  spec.add_dependency "activesupport", ">= 3.0.0"

  spec.add_development_dependency "rails", ">= 3.0.0"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "minitest", ">= 4.7"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rake", "~> 10.0"
end
