module QRCode::Math
  # GF(256) antilog / log tables used by the Reed-Solomon generator.
  EXP_TABLE = build_exp_table
  LOG_TABLE = build_log_table(EXP_TABLE)

  private def self.build_exp_table
    table = Array(Int32).new(256, 0)
    (0...8).each { |i| table[i] = 1 << i }
    (8...256).each do |i|
      table[i] = table[i - 4] ^ table[i - 5] ^ table[i - 6] ^ table[i - 8]
    end
    table
  end

  private def self.build_log_table(exp_table)
    table = Array(Int32).new(256, 0)
    (0...255).each { |i| table[exp_table[i]] = i }
    table
  end

  def self.glog(n)
    raise RuntimeError.new("glog(#{n})") if n < 1
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
