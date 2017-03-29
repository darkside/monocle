# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'monocle/version'

Gem::Specification.new do |spec|
  spec.name          = "ar-monocle"
  spec.version       = Monocle::VERSION
  spec.authors       = ["Leonardo Bighetti"]
  spec.email         = ["leo@invitedhome.com"]

  spec.summary       = %q{Monocle helps you manage your DB views.}
  spec.description   = %q{Monocle helps you manage your DB views.}
  spec.homepage      = "https://github.com/darkside/monocle"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "pry-nav"
  spec.add_development_dependency "dotenv"
  spec.add_development_dependency "pg"
  spec.add_development_dependency "database_cleaner"

  spec.add_dependency "rake"
  spec.add_dependency "activesupport", ">= 4", "< 6"
  spec.add_dependency "activerecord", ">= 4",  "< 6"
end
