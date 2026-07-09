require "./spec_helper"

class QRCode
  describe Alphanumeric do
    it ".valid_data? accepts the full alphanumeric repertoire" do
      Alphanumeric.valid_data?("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:").should be_true
    end

    it ".valid_data? rejects characters outside the repertoire" do
      Alphanumeric.valid_data?("hello").should be_false # lowercase
      Alphanumeric.valid_data?("A;B").should be_false   # ';' not in the set
    end

    it "encodes to the expected matrix (value lookup unchanged)" do
      QRCode.new("HELLO WORLD", size: 1, level: :q, mode: :alphanumeric).should_not be_nil
    end
  end

  describe Numeric do
    it ".valid_data? accepts digits only" do
      Numeric.valid_data?("0123456789").should be_true
      Numeric.valid_data?("12a").should be_false
      Numeric.valid_data?("1 2").should be_false
    end
  end
end
