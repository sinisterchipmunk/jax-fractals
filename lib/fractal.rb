begin
  require 'rmagick'
rescue LoadError
  raise "RMagick not found! Make sure `gem 'rmagick', '~> 2.13.1'` is in your Gemfile"
end

require File.expand_path('core_ext/math', File.dirname(__FILE__))

module Fractal
  require File.expand_path("fractal/engine", File.dirname(__FILE__))

  autoload :Map,       File.expand_path("fractal/map",       File.dirname(__FILE__))
  autoload :Generator, File.expand_path("fractal/generator", File.dirname(__FILE__))
  autoload :Version,   File.expand_path("fractal/version",   File.dirname(__FILE__))
  autoload :IslandGenerator, File.expand_path('fractal/island_generator', File.dirname(__FILE__))
  
  class << self
    attr_accessor :max_size
  end
  
  self.max_size = 1024
end
