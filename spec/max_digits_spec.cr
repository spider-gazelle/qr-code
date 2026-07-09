require "./spec_helper"

# ISO/IEC 18004 data-capacity anchors (version 1 and version 40) per
# error-correction level and encoding mode. External ground truth used to pin the
# endpoints of every MAX_DIGITS array (see AUDIT.md / issue #3).
ISO_V1 = {
  l: {mode_number: 41, mode_alpha_numk: 25, mode_8bit_byte: 17},
  m: {mode_number: 34, mode_alpha_numk: 20, mode_8bit_byte: 14},
  q: {mode_number: 27, mode_alpha_numk: 16, mode_8bit_byte: 11},
  h: {mode_number: 17, mode_alpha_numk: 10, mode_8bit_byte: 7},
}

ISO_V40 = {
  l: {mode_number: 7089, mode_alpha_numk: 4296, mode_8bit_byte: 2953},
  m: {mode_number: 5596, mode_alpha_numk: 3391, mode_8bit_byte: 2331},
  q: {mode_number: 3993, mode_alpha_numk: 2420, mode_8bit_byte: 1663},
  h: {mode_number: 3057, mode_alpha_numk: 1852, mode_8bit_byte: 1273},
}

# Character capacity implied by the (verified) RS block layout + the ISO
# char-count rules. MAX_DIGITS must equal this for every version; deriving it here
# guards against silent table typos without hand-transcribing 480 values.
def char_capacity(version, ecc, mode)
  rs = QRCode::RSBlock.get_rs_blocks(version, ecc)
  data_bits = QRCode.count_max_data_bits(rs)
  avail = data_bits - 4 - QRCode::Utilities.get_length_in_bits(QRCode::MODE[mode], version)

  case mode
  when :mode_number
    rem = avail % 10
    (avail // 10) * 3 + (rem >= 7 ? 2 : (rem >= 4 ? 1 : 0))
  when :mode_alpha_numk
    (avail // 11) * 2 + (avail % 11 >= 6 ? 1 : 0)
  else
    avail // 8
  end
end

class QRCode
  describe "MAX_DIGITS capacity tables" do
    MAX_DIGITS.each do |level, modes|
      ecc = ERROR_CORRECT_LEVEL[level]

      modes.each do |mode, capacities|
        it "#{level}/#{mode} equals the RS-derived capacity for every version" do
          expected = (1..40).map { |v| char_capacity(v, ecc, mode) }
          capacities.should eq expected
        end

        it "#{level}/#{mode} matches the ISO v1 and v40 anchors" do
          capacities.size.should eq 40
          capacities.first.should eq ISO_V1[level][mode]
          capacities.last.should eq ISO_V40[level][mode]
        end
      end
    end
  end
end
