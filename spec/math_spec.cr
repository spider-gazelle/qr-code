require "./spec_helper"

class QRCode
  describe Math do
    it "builds full 256-entry exp/log tables" do
      Math::EXP_TABLE.size.should eq 256
      Math::LOG_TABLE.size.should eq 256
    end

    it "has glog and gexp as inverses over GF(256)*" do
      (1..255).each do |n|
        Math.gexp(Math.glog(n)).should eq n
      end
    end

    it "has the field identities" do
      Math.gexp(0).should eq 1
      Math.glog(1).should eq 0
    end

    it "wraps gexp exponents modulo 255" do
      Math.gexp(255).should eq Math.gexp(0)
      Math.gexp(256).should eq Math.gexp(1)
      Math.gexp(-1).should eq Math.gexp(254)
    end

    it "rejects glog of values below 1" do
      expect_raises(QRCode::RuntimeError) { Math.glog(0) }
    end
  end
end
