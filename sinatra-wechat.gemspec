# coding: utf-8
version = File.read(File.expand_path('../VERSION', __FILE__)).strip

Gem::Specification.new do |spec|
  spec.name              = "sinatra-wechat"
  spec.version           = version
  spec.authors           = ["Lu, Jun"]
  spec.email             = "luj1985@gmail.com"
  spec.summary           = "Sinatra extension for Tencent Wechat"
  spec.description       = "Provide Extensible Sinatra API to support Wechat development mode"
  spec.homepage          = "https://github.com/luj1985/sinatra-wechat"
  spec.license           = "MIT"

  spec.files             = `git ls-files`.split("\n") - %w[.gitignore .travis.yml, .rspec]
  spec.test_files        = spec.files.select { |p| p =~ /^spec\/.*_spec.rb/ }
  spec.extra_rdoc_files  = spec.files.select { |p| p =~ /^README/ } << 'LICENSE'
  spec.require_paths     = ["lib"]

  spec.add_dependency "bundler", "~> 1.3"
  spec.add_dependency "sinatra", "~> 1.4"
  spec.add_dependency "nokogiri"
  spec.add_dependency "blankslate"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rack-test"
end