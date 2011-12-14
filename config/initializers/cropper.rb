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
        ["-crop", "#{target.crop_w}x#{target.crop_h}+#{target.crop_x}+#{target.crop_y}"]
      end
    end
  end
end
