require "./spec_helper"

# Behavioural regressions for the corrupted MAX_DIGITS tables: without an explicit
# `size:`, the constructor must pick the smallest version whose capacity holds the
# payload. The corrupted tables previously rejected valid data (raised) or
# over-sized it. See AUDIT.md / issue #3.
class QRCode
  describe "automatic version sizing" do
    it "sizes large numeric-H data that fits v40 (regression: h/mode_number)" do
      QRCode.new("1" * 3000, level: :h, mode: :number).version.should eq 40
      QRCode.new("1" * 2500, level: :h, mode: :number).version.should eq 36
    end

    it "sizes large alphanumeric-H data that fits v40 (regression: h/mode_alpha_numk)" do
      QRCode.new("A" * 1800, level: :h, mode: :alphanumeric).version.should eq 40
    end

    it "does not over-size byte-Q data at the v16 boundary (regression: q/mode_8bit_byte)" do
      QRCode.new("x" * 300, level: :q, mode: :byte_8bit).version.should eq 16
    end
  end
end
