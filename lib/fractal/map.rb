class Fractal::Map < Array
  attr_accessor :width, :height
  alias :row :[]
  
  class Line < Array
    def initialize(count)
      super count, nil
    end
    
    def [](a)
      if a.kind_of?(Numeric)
        raise "Out of bounds: #{a} / #{length}" if a < 0 || a >= length
      end
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
    pop while length > height
    collect! { |line| line[0...width] }
    @width, @height = width, height
  end
  
  def [](x, y)
    raise "Out of bounds: #{y} / #{@height}" if y < 0 || y >= @height
    super(y)[x]
  end
  
  def []=(x, y, value)
    row(y)[x] = value
  end
  
  # Encodes the map as a grayscale bitmap, with a color depth of 8 bits per pixel.
  #
  # Returns the bitmap as an array of bytes.
  def bytes
    flatten.pack("C*").bytes.to_a
  end
end
