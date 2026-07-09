require "./spec_helper"

# The constructor must reject invalid arguments with a typed QRCode::ArgumentError
# instead of leaking a bare IndexError (out-of-range version) or KeyError (unknown
# mode / level) from deep inside `make`. See AUDIT.md / issue #3 (P0 #4, P1).
class QRCode
  describe "argument validation" do
    it "rejects a version below 1 with a typed error" do
      expect_raises(QRCode::ArgumentError, /1\.\.40/) { QRCode.new("x", size: 0) }
      expect_raises(QRCode::ArgumentError, /1\.\.40/) { QRCode.new("x", size: -1) }
    end

    it "rejects a version above 40 with a typed error" do
      expect_raises(QRCode::ArgumentError, /1\.\.40/) { QRCode.new("x", size: 41) }
    end

    it "rejects an unknown mode with a typed error naming the valid modes" do
      expect_raises(QRCode::ArgumentError, /mode/) { QRCode.new("x", mode: :kanji) }
    end

    it "rejects an unknown error-correction level with a typed error" do
      expect_raises(QRCode::ArgumentError, /level/) { QRCode.new("x", level: :z) }
    end

    it "still builds for valid boundary versions" do
      QRCode.new("x", size: 1).version.should eq 1
      QRCode.new("x", size: 40).version.should eq 40
    end
  end
end
