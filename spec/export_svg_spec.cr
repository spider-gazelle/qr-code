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
  end
end
