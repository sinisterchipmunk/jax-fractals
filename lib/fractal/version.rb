module Fractal
  module Version
    MAJOR = 1
    MINOR = 0
    TINY = 0
    STRING = [MAJOR, MINOR, TINY].join('.')
  end
  
  VERSION = Version::STRING
end
