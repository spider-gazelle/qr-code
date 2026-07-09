# https://github.com/samvincent/rqrcode-rails3
# https://github.com/whomwah/rqrcode/blob/master/lib/rqrcode/export/svg.rb
class QRCode
  # Hex colour without the leading `#` (the markup adds it): 3/4/6/8 digits.
  SVG_COLOR = /\A[0-9A-Fa-f]{3,8}\z/

  # Allowed SVG `shape-rendering` keywords.
  SVG_SHAPE_RENDERING = %w(auto optimizeSpeed crispEdges geometricPrecision inherit)

  def as_svg(offset = 0, color = "000", shape_rendering = "crispEdges", module_size = 11, standalone = true, fill : String? = "fff")
    # Reject anything that isn't a plain hex colour / known keyword: these values
    # are interpolated straight into the markup, so an unchecked string is an SVG
    # injection vector.
    unless color =~ SVG_COLOR
      raise ArgumentError.new(%{Invalid color #{color.inspect} (expected a hex value like "000" or "ffffff")})
    end

    if fill && !(fill =~ SVG_COLOR)
      raise ArgumentError.new(%{Invalid fill #{fill.inspect} (expected a hex value like "fff", or nil)})
    end

    unless SVG_SHAPE_RENDERING.includes?(shape_rendering)
      raise ArgumentError.new("Invalid shape_rendering #{shape_rendering.inspect}. Valid: #{SVG_SHAPE_RENDERING.join(", ")}")
    end

    # height and width dependent on offset and QR complexity
    dimension = (module_count * module_size) + (2 * offset)

    xml_tag = %{<?xml version="1.0" standalone="yes"?>}
    open_tag = %{<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:ev="http://www.w3.org/2001/xml-events" width="#{dimension}" height="#{dimension}" shape-rendering="#{shape_rendering}">}
    close_tag = "</svg>"

    result = [] of String
    modules.each_index do |c|
      tmp = [] of String
      modules.each_index do |r|
        y = c * module_size + offset
        x = r * module_size + offset

        next unless checked?(c, r)
        tmp << %{<rect width="#{module_size}" height="#{module_size}" x="#{x}" y="#{y}" style="fill:##{color}"/>}
      end
      result << tmp.join
    end

    if fill
      result.unshift %{<rect width="#{dimension}" height="#{dimension}" x="0" y="0" style="fill:##{fill}"/>}
    end

    if standalone
      result.unshift(xml_tag, open_tag)
      result << close_tag
    end

    result.join("\n")
  end
end
