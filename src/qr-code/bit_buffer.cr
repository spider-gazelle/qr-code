require "./utilities"

class QRCode::BitBuffer
  getter buffer : Array(Int32)

  PAD0 = 0xEC
  PAD1 = 0x11

  def initialize(@version : Int32)
    @buffer = [] of Int32
    @length = 0
  end

  def get(index)
    buf_index = (index // 8)
    ((Utilities.rszf(@buffer[buf_index], 7 - index % 8)) & 1) == 1
  end

  def put(num, length)
    (0...length).each do |i|
      put_bit(((Utilities.rszf(num, length - i - 1)) & 1) == 1)
    end
  end

  def get_length_in_bits
    @length
  end

  def put_bit(bit : Bool)
    buf_index = @length // 8
    if @buffer.size <= buf_index
      @buffer << 0
    end

    if bit
      @buffer[buf_index] |= (Utilities.rszf(0x80, @length % 8))
    end

    @length += 1
  end

  def byte_encoding_start(length)
    put(MODE[:mode_8bit_byte], 4)
    put(length, Utilities.get_length_in_bits(MODE[:mode_8bit_byte], @version))
  end

  def alphanumeric_encoding_start(length)
    put(MODE[:mode_alpha_numk], 4)
    put(length, Utilities.get_length_in_bits(MODE[:mode_alpha_numk], @version))
  end

  def numeric_encoding_start(length)
    put(MODE[:mode_number], 4)
    put(length, Utilities.get_length_in_bits(MODE[:mode_number], @version))
  end

  def pad_until(prefered_size)
    # Align on byte
    while get_length_in_bits % 8 != 0
      put_bit(false)
    end

    # Pad with padding code words
    while get_length_in_bits < prefered_size
      put(BitBuffer::PAD0, 8)
      put(BitBuffer::PAD1, 8) if get_length_in_bits < prefered_size
    end
  end

  def end_of_message(max_data_bits)
    put(0, 4) unless get_length_in_bits + 4 > max_data_bits
  end
end
