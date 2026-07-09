require "./spec_helper"

class QRCode
  describe Utilities do
    describe ".get_mask" do
      it "evaluates every valid mask pattern (0..7)" do
        (0..7).each do |pattern|
          Utilities.get_mask(pattern, 3, 4).should be_a(Bool)
        end
      end

      it "rejects an out-of-range mask pattern with a typed error" do
        # MASK_COMPUTATIONS has 8 entries (indices 0..7); index 8 must be rejected,
        # not indexed (was an off-by-one: `>` instead of `>=`).
        expect_raises(QRCode::RuntimeError, /mask_pattern/) { Utilities.get_mask(8, 0, 0) }
      end
    end
  end
end
