class QRCode::Numeric
  getter mode : Int32

  def initialize(@data : String)
    @mode = MODE[:mode_number]

    raise ArgumentError.new("Not a numeric string `#{@data}`") unless Numeric.valid_data?(@data)
  end

  def get_length
    @data.size
  end

  def self.valid_data?(data)
    data.each_char do |s|
      return false if NUMERIC.index(s).nil?
    end
    true
  end

  def write(buffer)
    buffer.numeric_encoding_start(get_length)

    (@data.size).times do |i|
      if i % 3 == 0
        chars = @data[i, 3]
        bit_length = get_bit_length(chars.size)
        buffer.put(get_code(chars), bit_length)
      end
    end
  end

  NUMBER_LENGTH = {-1, 4, 7, 10}

  private def get_bit_length(length)
    NUMBER_LENGTH[length]
  end

  private def get_code(chars)
    chars.to_i
  end
end
