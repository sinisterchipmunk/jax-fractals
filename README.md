# jax-fractals

Fractal textures for [Jax](http://blog.jaxgl.com/what-is-jax)!

[<img src="https://raw.github.com/sinisterchipmunk/jax-fractals/master/screenshots/hm.png" width="128" height="128">](https://github.com/sinisterchipmunk/jax-fractals/blob/master/screenshots/hm.png)
[<img src="https://raw.github.com/sinisterchipmunk/jax-fractals/master/screenshots/1.png" width="128" height="128">](https://github.com/sinisterchipmunk/jax-fractals/blob/master/screenshots/1.png)
[<img src="https://raw.github.com/sinisterchipmunk/jax-fractals/master/screenshots/3.png" width="128" height="128">](https://github.com/sinisterchipmunk/jax-fractals/blob/master/screenshots/3.png)
[<img src="https://raw.github.com/sinisterchipmunk/jax-fractals/master/screenshots/4.png" width="128" height="128">](https://github.com/sinisterchipmunk/jax-fractals/blob/master/screenshots/4.png)

## Why?

Because I can! Also, fractals are oh-so-useful for terrain generation, cloud simulation, lava, and various other natural-looking effects.

## Features

* Adds a command-line generator for creating static fractal images
  * Customizable options include random seed, image width, image height, and smoothness factor
  * Defaults to a grayscale image, but can generate fractals using any color for low and high values
  * Fractals which have power-of-two dimensions can be cleanly tiled
  * Fractals can be generated with an alpha channel, which is helpful for rendering clouds
  * Can generate "islands" -- that is, there are no high points on the borders
* Adds a Heightmap model to Jax for processing fractal images into terrain
  * Vertical scale can be set independently from width and depth scale
  * Quickly calculates normals for the height map, for efficient lighting
  * Returns interpolated height values for fractional coordinates
  * Height maps whose width and depth are powers of two can be cleanly tiled for endless landscapes
* For Rails projects, adds a controller for generating fractal images on-the-fly and caching them as appropriate

## Dependencies

This gem requires Jax and RMagick 2.

## Installation

Add the following to your Gemfile:

    gem 'jax-fractals'

Or, for the latest development version, the following:

    gem 'jax-fractals', :git => "http://github.com/sinisterchipmunk/jax-fractals"

Then type:

    bundle install

## Usage

### The Generator

The quickest way to get a fractal image into your app is to generate it from the command line:

    rails generate fractal name-of-fractal
    
By default, it will have pixel dimensions 128x128, and will be generated with a smoothness factor of 2. You can customize all of these options:

    rails generate fractal name-of-fractal --width=256 --height=256 --smoothness=1.25

A different fractal image will be generated each time the generator is run unless a random seed is specified:

    rails generate fractal name-of-fractal --seed=100
    
You can also change the colors for the low and high values, which default to black and white, respectively. The following example will replace black with red, and white with blue:

    rails generate fractal name-of-fractal --low-color=ff0000 --high-color=0000ff
    
Sometimes you need the fractal to include an alpha (transparency) channel, so that the lower values are more transparent and the higher ones are more opaque. Simple!

    rails generate fractal name-of-fractal --alpha

Occasionally, you'll want to generate a fractal that is guaranteed to have intensity values equal to 0 along its borders. This is useful if you're generating a single cloud in the sky (as opposed to a tileable texture) or an island in the sea. To do this with the generator:

    rails generate fractal name-of-fractal --island


### The Controller

To mount the fractal controller, add the following to your routes.rb file:

    mount Fractal::Engine => "/fractals"

Restart the Rails server, and you can generate a fractal by visiting its URL. There is a single required parameter, its ID, which is used as a random seed. You can also pass width, height, smoothness and color parameters.

Experiment with the following examples:

* [http://localhost:3000/fractals/1](http://localhost:3000/fractals/1)
* [http://localhost:3000/fractals/2](http://localhost:3000/fractals/2)
* [http://localhost:3000/fractals/2?island=1](http://localhost:3000/fractals/2?island=1)
* [http://localhost:3000/fractals/2?low_color=ff0000&high_color=0000ff](http://localhost:3000/fractals/2?low_color=ff0000&high_color=0000ff)
* [http://localhost:3000/fractals/2?low_color=ff0000&high_color=0000ff&alpha=true](http://localhost:3000/fractals/2?low_color=ff0000&high_color=0000ff&alpha=true)
* [http://localhost:3000/fractals/1?width=256&height=256](http://localhost:3000/fractals/1?width=256&height=256)
* [http://localhost:3000/fractals/1?smoothness=1.25](http://localhost:3000/fractals/1?smoothness=1.25)
* [http://localhost:3000/fractals/1?width=256&height=256&smoothness=1.25](http://localhost:3000/fractals/1?width=256&height=256&smoothness=1.25)

Once generated, fractals will be stored in the Rails cache, so that they only need to be generated one time. After generation, the cached copy will be returned instead.


### The Heightmap

Height maps will work with any image, not just fractals, but they play so nicely together that I couldn't resist adding the Heightmap model to this library.

The easiest way to create a height map is to create a resource file. In your Rails or Jax project, create the file `app/assets/jax/resources/heightmaps/test.resource` and add the following information to it:

    path: "/fractals/5"
    xz_scale: 0.75
    y_scale: 8.0
    
This will load the fractal dynamically from the Fractals controller (note: you have to change the path to reference a static image if you're not using Rails), scale its width and depth by 3/4, and then scale its height by 8 to produce a hilly (but not too mountainous!) terrain.

If you want to texture it (and who wouldn't?), create a material like you'd create any other Jax material:

    $ jax g material ground texture

Then, set it in the resource file:

    material: "ground"

#### Actually Using It

To add the "test" heightmap to the world, add it like you would any other Jax model instance. Do this in your Jax controller:

    @world.addObject Heightmap.find "test"

Done!
