require_dependency 'fractal'

class Fractal::FractalsController < ApplicationController
  before_filter :set_default_parameters
  before_filter :validate_dimensions
  
  # Fields:
  #
  #   id - the random seed for this fractal. Required.
  #   width - the width of this fractal. Default: 128
  #   height - the height of this fractal. Default: 128
  #   smoothness - the smoothness of this fractal. Lower values produce more jagged / turbulent
  #                results, higher values produce smoother results. Default: 2
  #   high_color - the hex color code to use for high intensity values. Default: "ffffff"
  #   low_color  - the hex color code to use for low intensity values. Default: "000000"
  #   alpha      - if true, an alpha channel will be added. Lower intensity values will be more
  #                transparent. Default: false
  #   island     - if true, an "island" fractal will be generated, such that its borders are
  #                guaranteed to have intensity values equal to 0. Default: false
  #
  def show
    cache_key = File.join(params[:id], params[:width].to_s, params[:height].to_s,
                          params[:smoothness].to_s, params[:alpha].to_s,
                          params[:high_color].to_s, params[:low_color].to_s,
                          params[:island].to_s)

    unless data = Rails.cache.read(cache_key)
      # The proc ensures that the image leaves scope prior to garbage collection,
      # thus ensuring that it will actually be collected. This is all to prevent
      # a memory leak, detailed here:
      # http://rubyforge.org/forum/forum.php?thread_id=1374&forum_id=1618
      proc {
        image = generate_image
        data = image.to_blob { self.format = 'PNG' }
        image.destroy!
      }.call
      GC.start
      
      Rails.cache.write cache_key, data
    end
    
    send_data data, :filename => "#{params[:id]}.png", :type => "image/png",
                    :disposition => 'inline'
  end

  protected
  def generate_image
    Fractal::Generator.image(params.merge(:seed => params[:id].to_i))
  end
  
  def set_default_parameters
    params[:width]  = params[:width].blank?  ? default_dimensions[:width]  : params[:width].to_i
    params[:height] = params[:height].blank? ? default_dimensions[:height] : params[:height].to_i
    params[:smoothness] = params[:smoothness].blank? ? 2 : params[:smoothness].to_f
    params[:smoothness] = 2 if params[:smoothness] <= 0
    params[:alpha] = false unless params.key?(:alpha)
    params[:island] = false unless params.key?(:island)
  end
  
  def default_dimensions
    { :width => 128, :height => 128 }
  end
  
  def validate_dimensions
    if (requested_width = params[:width]) > Fractal.max_size
      params[:width] = Fractal.max_size
      log = true
    end
    if (requested_height = params[:height]) > Fractal.max_size
      params[:height] = Fractal.max_size
      log = true
    end
    if log
      logger.warn <<-end_warning
      Requested dimensions #{requested_width}x#{requested_height} exceed maximum size
      #{Fractal.max_size}x#{Fractal.max_size}. If you need a larger fractal,
      create a file called config/initializers/fractals.rb and set
      
        Fractal.max_size = [some acceptable number]
        
      Or, set
      
        Fractal.max_size = nil
        
      ...to remove limits altogether (not recommended, as large fractals
      can take a long time to generate!)
      
      The safest way to use very large fractals is just to preprocess them:
      
        rails g fractal
        
      end_warning
    end
  end
end
