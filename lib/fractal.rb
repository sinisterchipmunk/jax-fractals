require File.expand_path('core_ext/math', File.dirname(__FILE__))

module Fractal
  require File.expand_path("fractal/engine", File.dirname(__FILE__))

  autoload :Map,       File.expand_path("fractal/map",       File.dirname(__FILE__))
  autoload :Generator, File.expand_path("fractal/generator", File.dirname(__FILE__))
  autoload :Version,   File.expand_path("fractal/version",   File.dirname(__FILE__))
end
