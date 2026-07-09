require "./spec_helper"

class QRCode
  describe QRCode do
    it "has standalone option true by default" do
      doc = QRCode.new("qrcode").as_svg
      doc.should match(%r{<\?xml.*standalone="yes"})
      doc.should match(%r{<svg.*>})
      doc.should match(%r{</svg>})
    end

    it "omits surrounding XML when `standalone` is `false`" do
      doc = QRCode.new("qrcode").as_svg(standalone: false)
      doc.should_not match(%r{<\?xml.*standalone="yes"})
      doc.should_not match(%r{<svg.*>})
      doc.should_not match(%r{</svg>})
    end

    it "rejects a non-hex color (SVG injection)" do
      expect_raises(QRCode::ArgumentError, /color/) do
        QRCode.new("qrcode").as_svg(color: %{000"/><script>alert(1)</script>})
      end
    end

    it "rejects a non-hex fill (SVG injection)" do
      expect_raises(QRCode::ArgumentError, /fill/) do
        QRCode.new("qrcode").as_svg(fill: %{fff"><script>alert(1)</script>})
      end
    end

    it "rejects an unknown shape_rendering (SVG injection)" do
      expect_raises(QRCode::ArgumentError, /shape.rendering/) do
        QRCode.new("qrcode").as_svg(shape_rendering: %{crispEdges"><script>alert(1)</script>})
      end
    end

    it "accepts valid hex colors, a nil fill and standard shape_rendering" do
      QRCode.new("qrcode").as_svg(color: "1a2b3c", fill: "fff")
      QRCode.new("qrcode").as_svg(color: "000000", fill: nil)
      QRCode.new("qrcode").as_svg(shape_rendering: "geometricPrecision")
    end

    it "adds a 4-module quiet zone by default (offset scales with module_size)" do
      qr = QRCode.new("qrcode")
      mc = qr.module_count
      module_size = 11

      qr.as_svg.should contain(%{width="#{mc * module_size + 2 * (4 * module_size)}"})
      qr.as_svg(offset: 0).should contain(%{width="#{mc * module_size}"})
    end
  end
end
