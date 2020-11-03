class QRCode::Alphanumeric
  getter mode : Int32

  def initialize(@data : String)
    @mode = MODE[:mode_alpha_numk]
    raise ArgumentError.new("Not a alpha numeric uppercase string `#{@data}`") unless Alphanumeric.valid_data?(@data)
  end

  def get_length
    @data.size
  end

  def self.valid_data?(data)
    data.each_char do |s|
      return false if ALPHANUMERIC.index(s).nil?
    end
    true
  end

  def write(buffer)
    buffer.alphanumeric_encoding_start(get_length)

    (@data.size).times do |i|
      if i % 2 == 0
        if i == (@data.size - 1)
          value = ALPHANUMERIC.index(@data[i]).not_nil!
          buffer.put(value, 6)
        else
          value = (ALPHANUMERIC.index(@data[i]).not_nil! * 45) + ALPHANUMERIC.index(@data[i + 1]).not_nil!
          buffer.put(value, 11)
        end
      end
    end
  end
end
