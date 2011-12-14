module Paperclip
  class Cropper < Thumbnail
    def transformation_command
      crop_options = crop_command
      current_geometry_small = @current_geometry.height < @target_geometry.height &&
                                    @current_geometry.width < @target_geometry.width

      if crop_options && current_geometry_small
        crop_options

      elsif crop_options && !current_geometry_small
        crop_options + super.join(' ').sub(/ -crop \S+/, '').split(' ')

      elsif !crop_options && current_geometry_small
        ["-resize", "#{@current_geometry.width}x"]

      else
        super
      end
    end

    def crop_command
      target = @attachment.instance

      if target.cropping?
        crop_x = target.crop_x
        crop_y = target.crop_y
        crop_w = target.crop_w
        crop_h = square? ? target.crop_w : target.crop_h

        ["-crop", "#{crop_w}x#{crop_h}+#{crop_x}+#{crop_y}"]
      end
    end

    def square?
      @target_geometry.height.to_i == @target_geometry.width.to_i
    end
  end
end
