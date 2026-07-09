require "./spec_helper"
require "../src/qr-code/export/png"

class QRCode
  describe "#as_canvas" do
    white = StumpyPNG::RGBA.from_hex("#ffffff")

    it "renders a square canvas with a background quiet-zone corner" do
      canvas = QRCode.new("duncan", size: 1).as_canvas(size: 128)
      canvas.width.should eq canvas.height
      canvas[0, 0].should eq white
    end

    it "keeps a quiet zone even when the requested size is too small" do
      # v40 is 177 modules; at size 128 the old sizing rounded the border to 0px,
      # leaving the finder pattern flush against the edge (unscannable).
      canvas = QRCode.new("duncan", size: 40).as_canvas(size: 128)
      canvas.width.should eq canvas.height
      canvas.width.should be >= 177 + 2 * 4
      canvas[0, 0].should eq white
      canvas[canvas.width - 1, canvas.height - 1].should eq white
    end
  end
end
