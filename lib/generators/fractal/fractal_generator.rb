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
  class_option :high_color, :default => 'ffffff', :desc => "Color to use for high intensity values", :type => :string
  class_option :low_color, :default => '000000', :desc => "Color to use for low intensity values", :type => :string
  class_option :alpha, :default => false, :desc => "Whether to save transparency data", :type => :boolean
  
  def generate_fractal
    create_file File.join(options[:dest], 'images/fractals', "#{name}.png"),
                Fractal::Generator.image(options).to_blob { self.format = 'PNG' }
  end
end
