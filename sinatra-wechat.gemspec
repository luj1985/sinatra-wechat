# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sinatra/version'

Gem::Specification.new do |spec|
  spec.name               = "sinatra-wechat"
  spec.version            = Sinatra::Wechat::VERSION
  spec.authors            = ["Lu, Jun"]
  spec.email              = ["luj1985@gmail.com"]
  spec.summary            = "Sinatra extension for Tencent Wechat"
  spec.description        = "Provide Extensible Sinatra API to support Wechat development mode"
  spec.homepage           = "https://github.com/luj1985/sinatra-wechat"
  spec.license            = "MIT"

  spec.files              = `git ls-files -z`.split("\x0") - %w[.gitignore .travis.yml]
  spec.executables        = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files         = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths      = ["lib"]

  spec.add_dependency "bundler", "~> 1.6"
  spec.add_dependency "sinatra", "~> 1.4"
  spec.add_dependency "nokogiri"
  spec.add_dependency "blankslate"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "coveralls"
end