module Paperclip
  class Cropper < Thumbnail
    def cropping?
      @attachment.instance.cropping?
    end

    def square?
      @target_geometry.height.to_i == @target_geometry.width.to_i
    end

    def transformation_command
      if cropping?
        super.each_slice(2).map { |(sw, val)|
          if sw == '-crop'
            [sw, user_geometry]
          else
            [sw, val]
          end
        }.compact
      else
        super.each_slice(2).map { |(sw, val)|
          if sw == '-crop'
            [sw, transform_geometry(val)]
          else
            [sw, val]
          end
        }.compact
      end
    end

    def transform_geometry(geom)
      geom.gsub(/\d+"$/, '0"')
    end

    def user_geometry
      target = @attachment.instance
      crop_x = target.crop_x
      crop_y = target.crop_y
      crop_w = target.crop_w
      crop_h = square? ? target.crop_w : target.crop_h

      "#{crop_w}x#{crop_h}+#{crop_x}+#{crop_y}"
    end
  end
end
