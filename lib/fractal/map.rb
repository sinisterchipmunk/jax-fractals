class Fractal::Map < Array
  attr_accessor :width, :height
  
  class Line < Array
    def initialize(count)
      super count, nil
    end
    
    def [](a)
      raise "Out of bounds: #{a} / #{length}" if a < 0 || a >= length
      super
    end
    
    def []=(a, *)
      raise "Out of bounds: #{a} / #{length}" if a < 0 || a >= length
      super
    end
  end
  
  def initialize(size)
    @width = @height = size
    super(size) { Fractal::Map::Line.new(size) }
  end
  
  def truncate(width, height)
    pop while length > width
    for line in self
      line.pop while line.length > height
    end
    @width, @height = width, height
  end
  
  def [](a)
    raise "Out of bounds: #{a} / #{@width}" if a < 0 || a >= @width
    super
  end
  
  def []=(a, *)
    raise "Can't mass assign map lines (this is a 2D array)"
    super
  end
  
  # Encodes the map as a grayscale bitmap, with a color depth of 8 bits per pixel.
  #
  # Returns the bitmap as an array of bytes.
  def bytes
    flatten.pack("C*").bytes.to_a
  end
end
