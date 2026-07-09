require "./spec_helper"

# Error-path coverage complementing the argument-validation specs. See issue #3.
class QRCode
  describe "error paths" do
    it "raises when checked? is given an out-of-range coordinate" do
      qr = QRCode.new("duncan", size: 1)
      expect_raises(QRCode::RuntimeError, /row.column/) { qr.checked?(-1, 0) }
      expect_raises(QRCode::RuntimeError, /row.column/) { qr.checked?(0, 999) }
    end

    it "raises when data overflows an explicitly requested version" do
      expect_raises(QRCode::RuntimeError, /overflow/) do
        QRCode.new("x" * 100, size: 1, level: :h)
      end
    end

    it "currently accepts an empty string (builds a v1 numeric symbol)" do
      # Whether empty input should be rejected is tracked as a P2 decision (#3);
      # this locks the present behaviour.
      qr = QRCode.new("")
      qr.version.should eq 1
      qr.mode.should eq :mode_number
    end
  end
end
