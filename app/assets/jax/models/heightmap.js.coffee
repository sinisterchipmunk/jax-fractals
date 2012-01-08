# Height map can be created in one of two ways. The most common is by referencing
# a height image by its path:
#
#     hm = new HeightMap path: "/path/to/image.png"
#
# When loaded form an image, the height value for any given vertex is calculated
# with the following formula, clamping the value between 0 and 1:
#
#     (red * 65536 + green * 256 + blue) / 16777215
#
# The height is then scaled by @y_scale, if given. Alpha values are ignored.
# You can ignore this formula entirely if the image is an 8bpp grayscale.
#
# You can also set the @xz_scale to control the horizontal dimensions of the
# height map.
#
#
# The second method of instantiation is to specify height values explicitly
# along with a width and depth. You can use nested arrays for this, for
# organization, but a single flat array is also supported:
#
#     hm = new HeightMap
#       width: 4
#       depth: 2
#       heights: [
#         [ 0, 64, 128, 255 ],
#         [ 255, 64, 128, 0 ]
#       ]
#
#     hm = new HeightMap
#       width: 4
#       depth: 2
#       heights: [
#           0, 64, 128, 255,
#         255, 64, 128,   0
#       ]
# 
# Note that each height value must be a number between 0 and 255, and each
# height value corresponds to a separate vertex (so, no worrying about RGBA).
# The height values will be automatically scaled to a value between 0 and 1,
# and then scaled again according to @y_scale, as with loading from an image.
#
RGB_SCALE = 1.0 / 16777215
Jax.getGlobal()['Heightmap'] = Jax.Model.create
  # Returns the height map value at the given X or Z offset. Values may be
  # fractional. If the values are negative or if they exceed the width or
  # depth of this height map, they will be wrapped. If they are fractional,
  # then a suitable height value between the floor and ceiling of the values
  # will be calculated.
  #
  # Examples:
  #     hm = new Heightmap(width:2,depth:2,heights:[[0,1],[2,0]])
  #     hm.height( 0  , 0   )    #=> 0
  #     hm.height( 1  , 0   )    #=> 1
  #     hm.height( 0  , 1   )    #=> 2
  #     hm.height(-1  , 0   )    #=> 1
  #     hm.height( 3  , 0   )    #=> 1
  #     hm.height( 0.5, 0   )    #=> 0.5
  #     hm.height( 0  , 0.75)    #=> 1.5
  #
  height: (x, z) ->
    if @heights == undefined then return 0 # heightmap hasn't loaded yet

    x %= @width
    z %= @depth
    x = @width + x if x < 0
    z = @depth + z if z < 0

    [fracX, fracZ] = [x % 1, z % 1]
    x = Math.floor x if fracX
    z = Math.floor z if fracZ
    
    p = (x+z*@width)*4
    # read RGB, ignoring alpha
    y = (@heights[p] * 65536 + @heights[p+1] * 256 + @heights[p+2]) * RGB_SCALE * @y_scale
    return y unless fracX || fracZ
    
    [h, h2, h3, h4] = [y, @height(x+1, z)-y, @height(x, z+1)-y, @height(x+1,z+1)-y]
    y = h2 * fracX + h3 * fracZ
    if fracX && fracZ
      y += (h4 + h2 - h3) * 0.5 * fracX
      y += (h4 + h3 - h2) * 0.5 * fracZ
      y /= 3
    h + y
    
  after_initialize: ->
    if @path
      @img = new Image
      @img.onload = =>
        @loaded = true
        c = document.createElement 'canvas'
        [c.width, c.height] = [@img.width, @img.height]
        c2d = c.getContext '2d'
        c2d.drawImage @img, 0, 0
        img = c2d.getImageData 0, 0, @img.width, @img.height
        @width = img.width
        @depth = img.height
        @heights = img.data
        @mesh.rebuild()
      @img.src = @path
    else if @width && @depth && @heights
      heights = @heights
      @heights = []
      # modify data for RGBA compatibility
      #
      # this is a tradeoff -- slightly more memory for
      # much faster image loading, since images will
      # be much bigger and much more common. Note the only
      # alternative is to iterate through each image pixel
      # and convert it to a straight value, much like below,
      # but way slower since images are bigger and more common.
      for h in heights
        if h instanceof Array
          @heights.push v, v, v, v for v in h
        else
          @heights.push h, h, h, h
      @loaded = true
    else
      throw new Error "Heightmap requires a path!"

    @mesh = new Jax.Mesh
      default_material: @material
      draw_mode: GL_TRIANGLE_STRIP
      init: (vertices, colors, texcoords, normals, indices) =>
        if @loaded
          # since we know some details about the map, this is much
          # faster than the default Jax normal calcs, which must find
          # and then average all adjacent face normals for any given
          # vertex.
          [r, l, t, b, h, v, n] = [vec3.create(),vec3.create(),vec3.create(),
                                   vec3.create(),vec3.create(),vec3.create(),
                                   vec3.create()]
          calculateNormal = (x,z) =>
            [r[0],r[1],r[2]] = [(x+1)*@xz_scale, @height(x+1,z), z*@xz_scale]
            [l[0],l[1],l[2]] = [(x-1)*@xz_scale, @height(x-1,z), z*@xz_scale]
            [t[0],t[1],t[2]] = [x*@xz_scale, @height(x,z+1), (z+1)*@xz_scale]
            [b[0],b[1],b[2]] = [x*@xz_scale, @height(x,z-1), (z-1)*@xz_scale]
            
            vec3.normalize vec3.subtract r, l, h
            vec3.normalize vec3.subtract t, b, v
            vec3.normalize vec3.cross v, h, n
            normals.push n[0], n[1], n[2]
          
          for x in [0..(@width-2)] by 2
            index_base = vertices.length / 3
            for z in [0..@depth]
              indices.push index_base+z*3+1, index_base+z*3
              vertices.push  x   *@xz_scale, @height(x  , z), z*@xz_scale
              vertices.push (x+1)*@xz_scale, @height(x+1, z), z*@xz_scale
              vertices.push (x+2)*@xz_scale, @height(x+2, z), z*@xz_scale
              texcoords.push  x    / @width, z / @depth
              texcoords.push (x+1) / @width, z / @depth
              texcoords.push (x+2) / @width, z / @depth
              calculateNormal x, z
              calculateNormal x+1, z
              calculateNormal x+2, z
              
            # reverse direction of z every other x, so triangle strip renders properly
            for z in [(@depth)..0]
              indices.push index_base+z*3+1, index_base+z*3+2
