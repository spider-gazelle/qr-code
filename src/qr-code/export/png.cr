require "stumpy_png"

# https://github.com/whomwah/rqrcode/blob/master/lib/rqrcode/export/png.rb#L1
class QRCode
  def as_canvas(
    bit_depth : Int32 = 1,
    border_modules : Int32 = 3,
    color_type : Symbol = :grayscale,
    color : String = "#000000",
    fill : String = "#ffffff",
    size : Int32 = 128
  )
    color = StumpyPNG::RGBA.from_hex(color)
    fill = StumpyPNG::RGBA.from_hex(fill)

    module_px_size = (size.to_f / (module_count + 2 * border_modules).to_f).floor.to_i
    module_px_size = 1 if module_px_size == 0
    img_size = module_px_size * module_count
    size = img_size if img_size > size

    remaining = size - img_size
    border_px = (remaining.to_f / 2.0).floor.to_i

    png = StumpyPNG::Canvas.new(size, size, fill)

    modules.each_index do |x|
      modules.each_index do |y|
        if checked?(x, y)
          (0...module_px_size).each do |i|
            (0...module_px_size).each do |j|
              png[(y * module_px_size) + border_px + j, (x * module_px_size) + border_px + i] = color
            end
          end
        end
      end
    end

    png
  end

  def as_png(
    bit_depth : Int32 = 1,
    border_modules : Int32 = 3,
    color_type : Symbol = :grayscale,
    color : String = "#000000",
    fill : String = "#ffffff",
    size : Int32 = 128
  )
    png = as_canvas(
      bit_depth,
      border_modules,
      color_type,
      color,
      fill,
      size
    )

    # return the image bytes
    io = IO::Memory.new
    StumpyPNG.write(png, io)
    io.to_slice
  end
end
