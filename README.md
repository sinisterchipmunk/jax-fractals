# jax-fractals

Fractal textures for [Jax](http://blog.jaxgl.com/what-is-jax)!

## Why?

Because I can! Also, fractals are oh-so-useful for terrain generation, cloud simulation, lava, and various other natural-looking effects.

## Features

* Adds a command-line generator for creating static fractal images
  * Customizable options include random seed, image width, image height, and smoothness factor
* Adds a Heightmap model to Jax for processing fractal images into terrain
  * Vertical scale can be set independently from width and depth scale
  * Quickly calculates normals for the height map, for efficient lighting
  * Returns interpolated height values for fractional coordinates
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

### The Controller

To mount the fractal controller, add the following to your routes.rb file:

    mount Fractal::Engine => "/fractals"

Restart the Rails server, and you can generate a fractal by visiting its URL. There is a single required parameter, its ID, which is used as a random seed. You can also pass width, height and smoothness parameters.

Experiment with the following examples:

    http://localhost:3000/fractals/1
    http://localhost:3000/fractals/2
    http://localhost:3000/fractals/1?width=256&height=256
    http://localhost:3000/fractals/1?smoothness=1.25
    http://localhost:3000/fractals/1?width=256&height=256&smoothness=1.25

Once generated, fractals will be stored in the Rails cache, so that they only need to be generated one time. After generation, the cached copy will be returned instead.
