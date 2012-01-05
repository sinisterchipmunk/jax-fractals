class Fixnum
  def pot?
    (self & (self - 1)) == 0
  end
end

module Math
  module_function
  
  def max(a, b)
    a > b ? a : b
  end

  def min(a, b)
    a > b ? b : a
  end
  
  def pot(x)
    pot = 1
    pot *= 2 until pot >= x
    pot
  end
end
