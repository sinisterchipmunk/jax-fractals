$:.unshift File.expand_path('../lib', File.dirname(__FILE__))
require 'jax-fractals'

module Fixtures
  def fractal(name)
    File.read(File.expand_path(File.join("fixtures/fractals", name), File.dirname(__FILE__))).force_encoding('BINARY')
  end
end

RSpec.configure do |c|
  c.include Fixtures
end
