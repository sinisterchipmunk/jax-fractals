class Fractal::Generator
  class << self
    def image(options = {})
      options.reverse_merge! default_image_options
      klass = options[:island] ? Fractal::IslandGenerator : self
      
      fractal = klass.new options
                    
      if options[:alpha]
        image = Magick::Image.new(fractal.width, fractal.height) { self.background_color = 'transparent' }
        image.import_pixels 0, 0, fractal.width, fractal.height, 'IA', fractal.bytes.collect { |b| [b,b] }.flatten.pack('C*')
      else
        image = Magick::Image.new(fractal.width, fractal.height)
        image.import_pixels 0, 0, fractal.width, fractal.height, 'I', fractal.bytes.pack('C*')
      end
      
      options[:low_color] = '000000' if options[:low_color].blank?
      options[:high_color] = 'ffffff' if options[:high_color].blank?
      image = image.level_colors("##{options[:low_color]}", "##{options[:high_color]}", true)
      image
    end
    
    def default_image_options
      { :alpha => false, :island => false, :high_color => 'ffffff', :low_color => '000000' }
    end
  end
  
  INITIAL_RANGE = 400
  include Math
  attr_reader :map, :random, :smoothness, :seed
  
  def width;  map.width;  end
  def height; map.height; end
  def bytes;  map.bytes;  end
  
  def initialize(options = {})
    options.reverse_merge! default_options
    width, height = options[:width], options[:height]
    @map = Fractal::Map.new(pot(max(width, height)) + 1)
    @random = options[:seed] ? Random.new(options[:seed]) : Random.new
    @seed = @random.seed
    @smoothness = options[:smoothness] || 2
    generate
    @map.truncate(width, height)
  end
  
  def to_s
    "".tap do |result|
      for x in 0...width
        for y in 0...height
          result.concat map[x, y].to_s[0..6].rjust(7)
          result.concat " "
        end
        result.concat "\n"
      end
    end
  end

  protected
  def default_options
    {
      :width => 128,
      :height => 128,
      :smoothness => 2
    }
  end
  
  # Seed initial values, then return [step, range]
  def sow_seeds
    map[      0,        0] ||= 128
    map[      0, height-1] ||= 128
    map[width-1,        0] ||= 128
    map[width-1, height-1] ||= 128

    [width - 1, INITIAL_RANGE]
  end
  
  def compute(x, y, points, range)
    c = map[x, y] || 0
    4.times do |i|
      if points[i][0] < 0 then points[i][0] += (width - 1)
      elsif points[i][0] > width then points[i][0] -= (width - 1)
      elsif points[i][1] < 0 then points[i][1] += (height - 1)
      elsif points[i][1] > height then points[i][1] -= (height - 1)
      end
      c += map[points[i][0], points[i][1]] * 0.25
    end
    
    c += random.rand() * range - range / 2.0
    if c < 0 then c = 0
    elsif c > 255 then c = 255
    end
    
    c = c.to_i
    map[x, y] = c
    if x == 0 then map[width-1, y] = c
    elsif x == width-1 then map[0, y] = c
    elsif y == 0 then map[x, height-1] = c
    elsif y == height-1 then map[x, 0] = c
    end
  end

  private
  def half(step)
    step >> 1
  end
  
  def diamond(step, range)
    halfstep = half step
    (0...(width-1)).step step do |x|
      (0...(height-1)).step step do |y|
        sx = x + halfstep
        sy = y + halfstep
        points = [ [x, y], [x+step, y], [x, y+step], [x+step, y+step] ]
        compute sx, sy, points, range
      end
    end
  end
  
  def square(step, range)
    halfstep = half step
    (0...(width-1)).step step do |x|
      (0...(height-1)).step step do |y|
        x1 = x + halfstep
        y1 = y
        x2 = x
        y2 = y + halfstep
        points1 = [ [x1 - halfstep, y1], [x1, y1 - halfstep], [x1 + halfstep, y1], [x1, y1 + halfstep] ]
        points2 = [ [x2 - halfstep, y2], [x2, y2 - halfstep], [x2 + halfstep, y2], [x2, y2 + halfstep] ]
        compute x1, y1, points1, range
        compute x2, y2, points2, range
      end
    end
  end
  
  def generate
    step, range = *sow_seeds
    
    while step > 1
      diamond step, range
      square step, range
      range /= smoothness
      step >>= 1
    end
  end
end
