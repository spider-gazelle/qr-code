module QRCode::Math
  EXP_TABLE = Array(Int32).new(256, 0)
  LOG_TABLE = Array(Int32).new(256, 0)

  (0...8).each do |i|
    EXP_TABLE[i] = 1 << i
  end

  (8...256).each do |i|
    EXP_TABLE[i] = EXP_TABLE[i - 4] ^ EXP_TABLE[i - 5] ^ EXP_TABLE[i - 6] ^ EXP_TABLE[i - 8]
  end

  (0...255).each do |i|
    LOG_TABLE[EXP_TABLE[i]] = i
  end

  def self.glog(n)
    raise RuntimeError.new("glog(#{n})") if (n < 1)
    LOG_TABLE[n]
  end

  def self.gexp(n)
    while n < 0
      n = n + 255
    end

    while n >= 256
      n = n - 255
    end

    EXP_TABLE[n]
  end
end
