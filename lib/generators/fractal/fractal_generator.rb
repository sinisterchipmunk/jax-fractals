begin
  require 'rmagick'
rescue LoadError
  raise "RMagick not found! Make sure `gem 'rmagick', '~> 2.13.1'` is in your Gemfile"
end

require 'fractal'

class FractalGenerator < Rails::Generators::NamedBase
  class_option :seed, :default => nil, :desc => "Random seed for the fractal", :type => :numeric
  class_option :width, :default => 128, :desc => "Width of the fractal image in pixels", :type => :numeric
  class_option :height, :default => 128, :desc => "Height of the fractal image in pixels", :type => :numeric
  class_option :smoothness, :default => 2, :desc => "Smoothness factor (higher is smoother)", :type => :numeric
  class_option :dest, :default => "app/assets", :desc => "Where to place generated fractal", :type => :string
  
  def generate_fractal
    fractal = Fractal::Generator.new options[:width], options[:height],
                                     :seed => options[:seed],
                                     :smoothness => options[:smoothness]
    
    say "Random Seed: #{fractal.seed}"
    image = Magick::Image.new(fractal.width, fractal.height) { self.depth = 8 }
    image.import_pixels 0, 0, fractal.width, fractal.height, 'I', fractal.bytes.pack('C*')
    create_file File.join(options[:dest], 'images/fractals', "#{name}.png"), image.to_blob { self.format = 'PNG' }
  end
end
