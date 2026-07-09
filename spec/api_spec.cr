require "./spec_helper"
require "../src/qr-code/export/png"

class QRCode
  describe "constructor API" do
    it "accepts `version:` as the preferred name for the QR version" do
      QRCode.new("x", version: 3).version.should eq 3
    end

    it "still accepts the deprecated `size:` alias" do
      QRCode.new("x", size: 3).version.should eq 3
    end
  end

  describe "#as_png" do
    it "produces PNG bytes (no bit_depth / color_type params)" do
      bytes = QRCode.new("x").as_png(size: 64)
      bytes.should be_a(Bytes)
      bytes.size.should be > 0
    end
  end
end
