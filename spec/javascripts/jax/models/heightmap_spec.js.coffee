describe "Heightmap", ->
  model = null
  
  describe "loaded from a path", ->
    beforeEach ->
      model = new Heightmap(path: "/fractals/1")
    
    it "should load the model", ->
      waitsFor -> model.loaded
      
  describe "with RGB, not grayscale", ->
    beforeEach ->
      model = new Heightmap(width: 1, depth: 1, heights: [[1]], y_scale: 16777215)
      # HACK no good way to do this, but really it's not meant to be done
      model.heights[0] = 1 # R
      model.heights[1] = 2 # G
      model.heights[2] = 3 # B
      model.heights[3] = 4 # A
      
    it "should sample RGB and ignore A", ->
      expected_height = 1 * 65536 + 2 * 256 + 3 # RGB, ignoring A
      expect(model.height(0, 0)).toEqual expected_height
  
  describe "defined in-line", ->
    beforeEach ->
      model = new Heightmap(width: 4, depth: 2, heights: [ [ 0, 4, 0, 0 ], [2, 3, 0, 0] ], y_scale: 255)
  
    it "should return the expected height data", ->
      expect(model.height(0, 0)).toEqual 0
      expect(model.height(1, 0)).toEqual 4
      expect(model.height(2, 0)).toEqual 0
      expect(model.height(3, 0)).toEqual 0
      expect(model.height(0, 1)).toEqual 2
      expect(model.height(1, 1)).toEqual 3
      expect(model.height(2, 1)).toEqual 0
      expect(model.height(3, 1)).toEqual 0
  
    it "should wrap height indices out of bounds", ->
      # X
      expect(model.height(-3, 0)).toEqual 4
      expect(model.height(-7, 0)).toEqual 4
      expect(model.height( 5, 0)).toEqual 4
      expect(model.height( 9, 0)).toEqual 4
      # Z
      expect(model.height(0, -1)).toEqual 2
      expect(model.height(0, -3)).toEqual 2
      expect(model.height(0,  2)).toEqual 0
      expect(model.height(0,  3)).toEqual 2
      expect(model.height(0,  4)).toEqual 0
      
    it "should compensate for fractional X,Z components", ->
      expect(model.height(0.5, 0)).toEqual 2
      expect(model.height(0,   0.5)).toEqual 1
      expect(model.height(0.5, 0.5)).toEqual 1.5
      
      # Proximity -- should return approximately the same as x+1/z+1
      expect(model.height(0.99999999, 0)).toBeGreaterThan 4-Math.EPSILON
      expect(model.height(0, 0.99999999)).toBeGreaterThan 2-Math.EPSILON
      expect(model.height(0.99999999, 0.99999999)).toBeGreaterThan 3-Math.EPSILON
      