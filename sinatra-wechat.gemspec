# coding: utf-8
version = File.read(File.expand_path('../VERSION', __FILE__)).strip

Gem::Specification.new do |spec|
  spec.name          = "sinatra-wechat"
  spec.version       = version
  spec.authors       = "Lu, Jun"
  spec.email         = "luj1985@gmail.com"
  spec.summary       = "Sinatra extension for Tencent Wechat"
  spec.description   = "Provide Sinatra API to response Wechat event push"
  spec.homepage      = "https://github.com/luj1985/sinatra-wechat"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "bundler", "~> 1.3"
  spec.add_dependency "nokogiri"
  spec.add_dependency "blankslate"
  spec.add_dependency "sinatra"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rack-test"
end