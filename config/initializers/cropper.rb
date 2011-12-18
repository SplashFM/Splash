module Paperclip
  class Cropper < Thumbnail
    def square?
      @target_geometry.height.to_i == @target_geometry.width.to_i
    end

    def transformation_command
      super.each_slice(2).map { |(sw, val)|
        if sw == '-crop'
          [sw, user_geometry || transform_geometry(val)]
        else
          [sw, val]
        end
      }.compact
    end

    def transform_geometry(geom)
      geom.gsub(/\d+"$/, '0"')
    end

    def user_geometry
      target = @attachment.instance

      if target.cropping?
        crop_x = target.crop_x
        crop_y = target.crop_y
        crop_w = target.crop_w
        crop_h = square? ? target.crop_w : target.crop_h

        "#{crop_w}x#{crop_h}+#{crop_x}+#{crop_y}"
      end
    end
  end
end
