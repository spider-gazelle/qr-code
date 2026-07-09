require "./spec_helper"

class QRCode
  describe RSBlock do
    it "has one row per version/level (40 x 4)" do
      RSBlock::TABLE.size.should eq 40 * 4
    end

    it "is well-formed: groups of {count, total, data} with total > data > 0" do
      RSBlock::TABLE.each_with_index do |row, idx|
        (row.size % 3).should eq 0
        row.size.should be > 0

        (row.size // 3).times do |g|
          count = row[g * 3]
          total = row[g * 3 + 1]
          data = row[g * 3 + 2]

          count.should be > 0
          data.should be > 0
          (total > data).should be_true # each block needs at least one EC codeword
        end
      end
    end

    it "uses the same total codeword count across all four levels of a version" do
      # A version's module count is fixed, so total codewords (data + EC) must be
      # identical for L/M/Q/H; only the data/EC split changes. Catches a mistyped
      # `count`/`total` in the table.
      (1..40).each do |version|
        totals = [:l, :m, :q, :h].map do |level|
          blocks = RSBlock.get_rs_blocks(version, ERROR_CORRECT_LEVEL[level])
          blocks.sum(&.total_count)
        end
        totals.uniq.size.should eq 1
      end
    end

    it "matches the ISO total-codeword anchors at v1 and v40" do
      RSBlock.get_rs_blocks(1, ERROR_CORRECT_LEVEL[:l]).sum(&.total_count).should eq 26
      RSBlock.get_rs_blocks(40, ERROR_CORRECT_LEVEL[:h]).sum(&.total_count).should eq 3706
    end
  end
end
