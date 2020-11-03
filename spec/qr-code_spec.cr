require "./spec_helper"

class QRCode
  describe QRCode do
    it "should work with size 1" do
      qr = QRCode.new("duncan", size: 1)
      qr.modules.size.should eq(21)
      qr.modules.should eq(MATRIX_1_H)

      qr = QRCode.new("duncan", size: 1, level: :l)
      qr.modules.should eq(MATRIX_1_L)
      qr = QRCode.new("duncan", size: 1, level: :m)
      qr.modules.should eq(MATRIX_1_M)
      qr = QRCode.new("duncan", size: 1, level: :q)
      qr.modules.should eq(MATRIX_1_Q)
    end

    it "should work with size 3" do
      qr = QRCode.new("duncan", size: 3)
      qr.modules.size.should eq 29
      qr.modules.should eq MATRIX_3_H
    end

    it "should work with size 5" do
      qr = QRCode.new("duncan", size: 5)
      qr.modules.size.should eq 37
      qr.modules.should eq MATRIX_5_H
    end

    it "should work with size 10" do
      qr = QRCode.new("duncan", size: 10)
      qr.modules.size.should eq 57
      qr.modules.should eq MATRIX_10_H
    end

    it "should work with size 4" do
      qr = QRCode.new("www.bbc.co.uk/programmes/b0090blw", level: :l, size: 4)
      qr.modules.should eq MATRIX_4_L
      qr = QRCode.new("www.bbc.co.uk/programmes/b0090blw", level: :m, size: 4)
      qr.modules.should eq MATRIX_4_M
      qr = QRCode.new("www.bbc.co.uk/programmes/b0090blw", level: :q, size: 4)
      qr.modules.should eq MATRIX_4_Q

      qr = QRCode.new("www.bbc.co.uk/programmes/b0090blw")
      qr.modules.size.should eq 33
      qr.modules.should eq MATRIX_4_H
    end

    it "should print output using to_s" do
      qr = QRCode.new("duncan", size: 1)
      "xxxxxxx xx x  xxxxxxx\n".should eq qr.to_s[0..21]
      "qqqqqqqnqqnqnnqqqqqqq\n".should eq qr.to_s(dark: 'q', light: 'n')[0..21]
      "@@@@@@@ @@ @  @@@@@@@\n".should eq qr.to_s(dark: '@')[0..21]
    end

    it "should work with auto numeric" do
      # When digit only automatically uses numeric mode, default ecc level is :h
      digits = QRCode.new(Array.new(17, '1').join("")) # Version 1, numeric mode, ECC h
      digits.version.should eq 1
      digits.mode.should eq :mode_number
      digits.error_correction_level.should eq :h
      # When alpha automatically works
      alpha = QRCode.new(Array.new(10, 'X').join("")) # Version 1, alpha mode, ECC h
      alpha.version.should eq 1
      alpha.mode.should eq :mode_alpha_numk
      alpha.error_correction_level.should eq :h
      # Generic should use binary
      binary = QRCode.new(Array.new(7, 'x').join("")) # Version 1, 8bit mode, ECC h
      binary.version.should eq 1
      binary.mode.should eq :mode_8bit_byte
      binary.error_correction_level.should eq :h
    end

    it "should work with level 2 numeric" do
      data = "279042272585972554922067893753871413584876543211601021503002"

      qr = QRCode.new(data, size: 2, level: :m, mode: :number)
      qr.to_s[0..25].should eq "xxxxxxx   x x x   xxxxxxx\n"
    end

    it "should not throw an error performing rszf" do
      QRCode.new("2 1058 657682")
      QRCode.new("40952", size: 1, level: :h)
      QRCode.new("40932", size: 1, level: :h)
    end

    it "should raise an error if max size is exceeded" do
      expect_raises(QRCode::ArgumentError) { QRCode.new("duncan", size: 41) }
    end

    it "should return the correct version" do
      QRCode.new(Array.new(289, '1').join(""), level: :h, mode: :number).version.should eq 11
      QRCode.new(Array.new(175, 'A').join(""), level: :h, mode: :alphanumeric).version.should eq 11
      QRCode.new(Array.new(383, 'a').join(""), level: :h, mode: :byte_8bit).version.should eq 21
    end

    it "should work with different levels" do
      QRCode.new("duncan", level: :l)
      QRCode.new("duncan", level: :m)
      QRCode.new("duncan", level: :q)
      QRCode.new("duncan", level: :h)

      %i(a b c d e f g i j k n o p r s t u v w x y z).each do |ltr|
        expect_raises(KeyError) { QRCode.new("duncan", level: ltr) }
      end
    end

    it "should work with utf8" do
      qr = QRCode.new("тест")
      qr.modules.should eq MATRIX_UTF8_RU_TEST
    end
  end
end
