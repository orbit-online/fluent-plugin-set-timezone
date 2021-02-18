# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name        = "fluent-plugin-set-timezone"
  spec.description = "Fluentd filter plugin to shift the timezone of an event using the value of a field on that event."
  spec.homepage    = "https://github.com/orbit-online/fluent-plugin-set-timezone"
  spec.summary     = spec.description
  spec.version     = File.read("VERSION").strip
  spec.authors     = ["Anders Ingemann"]
  spec.email       = "aim@orbit.online"
  spec.license     = 'MIT'
  spec.files       = Dir['**/*']
  spec.require_paths = ['lib']

  spec.add_runtime_dependency "fluentd", ">= 0.14.0", "< 2"
  spec.add_dependency "tzinfo-data", [">= 0.3.6"]
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "test-unit"
end
