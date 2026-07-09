require "./spec_helper"

class QRCode
  describe Polynomial do
    it "strips leading zero coefficients in the constructor" do
      poly = Polynomial.new([0, 0, 5, 3], 0)
      poly.get_length.should eq 2
      poly.get(0).should eq 5
      poly.get(1).should eq 3
    end

    it "reserves `shift` trailing coefficients" do
      poly = Polynomial.new([1, 2], 3)
      poly.get_length.should eq 5
      poly.get(0).should eq 1
      poly.get(1).should eq 2
      poly.get(4).should eq 0
    end

    it "raises on an empty coefficient list" do
      expect_raises(QRCode::RuntimeError) { Polynomial.new([] of Int32, 0) }
    end
  end

  describe "Utilities.get_error_correct_polynomial" do
    it "produces a generator of degree == error-correct length" do
      (1..30).each do |n|
        Utilities.get_error_correct_polynomial(n).get_length.should eq n + 1
      end
    end

    it "is monic (leading coefficient 1)" do
      Utilities.get_error_correct_polynomial(10).get(0).should eq 1
    end
  end
end
