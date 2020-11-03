require "./bit_buffer"

class QRCode::EightBitByte
  getter mode : Int32

  def initialize(@data : String)
    @mode = MODE[:mode_8bit_byte]
  end

  def get_length
    @data.bytesize
  end

  def write(buffer : BitBuffer)
    buffer.byte_encoding_start(get_length)
    @data.each_byte do |b|
      buffer.put(b, 8)
    end
  end
end
