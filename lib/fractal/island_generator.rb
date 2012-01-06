# Generates fractals which are guaranteed to have border pixels set to 0
class Fractal::IslandGenerator < Fractal::Generator
  protected
  def sow_seeds
    step, range = *super
    map[      0,        0] = 0
    map[      0, height-1] = 0
    map[width-1,        0] = 0
    map[width-1, height-1] = 0
    
    # we can multiply range by 2 to maintain brightness
    # because we are effectively cutting area in half by
    # setting borders to 0 -- we must do this if we want
    # max brightness == 255, instead of 128
    [step, range*2]
  end
  
  def compute(x, y, points, range)
    # set borders to 0, but center to 128
    if x == (width-1)/2 && y == (width-1/2)
      map[x, y] = 128
    elsif x == 0 || x == width-1
      map[0, y] = 0
      map[width-1, y] = 0
    elsif y == 0 || y == height-1
      map[x, 0] = 0
      map[x, height-1] = 0
    else
      super
    end
  end
end
