require "./spec_helper"

class QRCode
  describe BitBuffer do
    it "accumulates bits MSB-first into bytes" do
      buffer = BitBuffer.new(1)
      buffer.put(0b101, 3)
      buffer.get_length_in_bits.should eq 3
      buffer.buffer.should eq [0b10100000]
    end

    it "byte-aligns then pads with PAD0/PAD1" do
      buffer = BitBuffer.new(1)
      buffer.put(0, 4)
      buffer.pad_until(24)
      buffer.get_length_in_bits.should eq 24
      buffer.buffer.should eq [0x00, BitBuffer::PAD0, BitBuffer::PAD1]
    end

    it "adds the 4-bit terminator only when it fits" do
      buffer = BitBuffer.new(1)
      buffer.put(0, 8)
      buffer.end_of_message(16) # room for the terminator
      buffer.get_length_in_bits.should eq 12

      tight = BitBuffer.new(1)
      tight.put(0, 8)
      tight.end_of_message(8) # no room -> no terminator
      tight.get_length_in_bits.should eq 8
    end

    it "adds a partial terminator of min(4, remaining) bits" do
      buffer = BitBuffer.new(1)
      buffer.put(0, 20)
      buffer.end_of_message(22) # remaining 2 -> add 2, not 0
      buffer.get_length_in_bits.should eq 22
    end
  end
end
