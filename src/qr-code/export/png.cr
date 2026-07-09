require "stumpy_png"

# https://github.com/whomwah/rqrcode/blob/master/lib/rqrcode/export/png.rb#L1
class QRCode
  def as_canvas(
    border_modules : Int32 = 4,
    color : String = "#000000",
    fill : String = "#ffffff",
    size : Int32 = 128,
  )
    color = StumpyPNG::RGBA.from_hex(color)
    fill = StumpyPNG::RGBA.from_hex(fill)

    module_px_size = (size.to_f / (module_count + 2 * border_modules).to_f).floor.to_i
    module_px_size = 1 if module_px_size < 1

    # Always reserve a `border_modules` quiet zone: grow the canvas if the
    # requested `size` is too small, so the border can never round down to 0px.
    quiet_px = border_modules * module_px_size
    content_px = module_px_size * module_count
    canvas_size = content_px + 2 * quiet_px
    canvas_size = size if size > canvas_size

    border_px = (canvas_size - content_px) // 2

    png = StumpyPNG::Canvas.new(canvas_size, canvas_size, fill)

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
    border_modules : Int32 = 4,
    color : String = "#000000",
    fill : String = "#ffffff",
    size : Int32 = 128,
  )
    png = as_canvas(
      border_modules,
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
