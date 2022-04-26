# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'moltrio/config/version'

Gem::Specification.new do |spec|
  spec.name          = "moltrio-config"
  spec.version       = Moltrio::Config::VERSION
  spec.authors       = ["Renato Zannon"]
  spec.email         = ["zannon@tn.com.br"]

  spec.summary       = %q{Multi-source, multi-tenant, thread-safe configuration library}
  spec.homepage      = "https://github.com/tecnologiaenegocios/moltrio-config"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "hamster", "~> 1.0"
  spec.add_dependency "thread_attr_accessor", "~> 0.4.0"
  spec.add_dependency "activesupport"

  spec.metadata["yard.run"] = "yri" # use "yard" to build full HTML docs

  spec.add_development_dependency "redis", "~> 3.2.1"
  spec.add_development_dependency "bundler", ">= 2.3.12"
  spec.add_development_dependency "rake", ">= 12.3.3"
end
