# -*- encoding: utf-8 -*-
# frozen_string_literal: true
$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require "rate-limiting/version"

Gem::Specification.new do |s|
  s.name        = "rate-limiting"
  s.version     = Rate::Limiting::VERSION
  s.authors     = ["alepaez, pnegri"]
  s.email       = ["alexandre@iugu.com.br"]
  s.homepage    = "https://github.com/iugu/rate-limiting"
  s.summary     = "Rack Rate-Limit Gem"
  s.description = "Easy way to Rate Limit your Rack app"

  s.rubyforge_project = "rate-limiting"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"

  s.add_development_dependency "rspec"
  s.add_development_dependency "rack-test"
  s.add_dependency "json"
end
