# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fractal/version"

Gem::Specification.new do |s|
  s.name        = "jax-fractals"
  s.version     = Fractal::VERSION
  s.authors     = ["Colin MacKenzie IV"]
  s.email       = ["sinisterchipmunk@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Adds a fractal generator, and corresponding controller for Jax projects}
  s.description = %q{Adds a fractal generator, and corresponding controller for Jax projects. Also adds a Heightmap model for Jax.}

  s.rubyforge_project = "jax-fractals"
  
  s.add_dependency 'jax', '~> 2.0.6'
  s.add_dependency 'rmagick', '~> 2.13.1'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
