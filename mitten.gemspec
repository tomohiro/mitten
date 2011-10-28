# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'mitten/version'

Gem::Specification.new do |s|
  s.name        = 'mitten'
  s.version     = Mitten::VERSION
  s.authors     = ['Tomohiro, TAIRA']
  s.email       = ['tomohiro.t@gmail.com']
  s.homepage    = 'http://github.com/Tomohiro/mittenn'
  s.summary     = %q{Mitten}
  s.description = %q{Mitten is A Ruby IRC Bot Pluggable Framework}

  s.rubyforge_project = 'mitten'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'rake'
  s.add_runtime_dependency 'net-irc'
end
