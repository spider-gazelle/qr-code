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
  end
end
