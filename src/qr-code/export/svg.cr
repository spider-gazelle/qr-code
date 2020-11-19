# https://github.com/samvincent/rqrcode-rails3
# https://github.com/whomwah/rqrcode/blob/master/lib/rqrcode/export/svg.rb
class QRCode
  def as_svg(offset = 0, color = "000", shape_rendering = "crispEdges", module_size = 11, standalone = true, fill : String? = "fff")
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
