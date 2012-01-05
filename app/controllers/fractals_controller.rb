require_dependency 'fractal'

class FractalsController < ApplicationController
  before_filter :set_default_dimensions, :only => :show
  
  # Fields:
  #
  #   id - the random seed for this fractal. Required.
  #   width - the width of this fractal. Default: 128
  #   height - the height of this fractal. Default: 128
  #   smoothness - the smoothness of this fractal. Lower values produce more jagged / turbulent results,
  #                higher values produce smoother results. Default: 2
  #
  def show
    cache_key = File.join(params[:id], params[:width].to_s, params[:height].to_s, params[:smoothness].to_s)
    unless data = Rails.cache.read(cache_key)
      # The proc ensures that the image leaves scope prior to garbage collection,
      # thus ensuring that it will actually be collected. This is all to prevent
      # a memory leak, detailed here:
      # http://rubyforge.org/forum/forum.php?thread_id=1374&forum_id=1618
      proc {
        gen = Fractal::Generator.new params[:width], params[:height],
                                     :seed => params[:id].to_i,
                                     :smoothness => params[:smoothness]
        image = Magick::Image.new(gen.width, gen.height)
        image.import_pixels 0, 0, gen.width, gen.height, 'I', gen.bytes.pack('C*')
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
  def set_default_dimensions
    params[:width]  = params[:width].blank?  ? default_dimensions[:width]  : params[:width].to_i
    params[:height] = params[:height].blank? ? default_dimensions[:height] : params[:height].to_i
    params[:smoothness] = params[:smoothness].blank? ? 2 : params[:smoothness].to_f
    params[:smoothness] = 2 if params[:smoothness] <= 0
  end
  
  def default_dimensions
    { :width => 128, :height => 128 }
  end
end
