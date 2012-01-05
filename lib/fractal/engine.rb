require 'rails'

class Fractal::Engine < Rails::Engine
  engine_name "fractals"
  isolate_namespace Fractal
  
  routes do
    match "/:id", :controller => "fractals", :action => "show"
  end
end
