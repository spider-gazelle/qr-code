module QRCode::Utilities
  extend self

  PATTERN_POSITION_TABLE = [
    [] of Int32,
    [6, 18],
    [6, 22],
    [6, 26],
    [6, 30],
    [6, 34],
    [6, 22, 38],
    [6, 24, 42],
    [6, 26, 46],
    [6, 28, 50],
    [6, 30, 54],
    [6, 32, 58],
    [6, 34, 62],
    [6, 26, 46, 66],
    [6, 26, 48, 70],
    [6, 26, 50, 74],
    [6, 30, 54, 78],
    [6, 30, 56, 82],
    [6, 30, 58, 86],
    [6, 34, 62, 90],
    [6, 28, 50, 72, 94],
    [6, 26, 50, 74, 98],
    [6, 30, 54, 78, 102],
    [6, 28, 54, 80, 106],
    [6, 32, 58, 84, 110],
    [6, 30, 58, 86, 114],
    [6, 34, 62, 90, 118],
    [6, 26, 50, 74, 98, 122],
    [6, 30, 54, 78, 102, 126],
    [6, 26, 52, 78, 104, 130],
    [6, 30, 56, 82, 108, 134],
    [6, 34, 60, 86, 112, 138],
    [6, 30, 58, 86, 114, 142],
    [6, 34, 62, 90, 118, 146],
    [6, 30, 54, 78, 102, 126, 150],
    [6, 24, 50, 76, 102, 128, 154],
    [6, 28, 54, 80, 106, 132, 158],
    [6, 32, 58, 84, 110, 136, 162],
    [6, 26, 54, 82, 110, 138, 166],
    [6, 30, 58, 86, 114, 142, 170],
  ]

  G15      = 1 << 10 | 1 << 8 | 1 << 5 | 1 << 4 | 1 << 2 | 1 << 1 | 1 << 0
  G18      = 1 << 12 | 1 << 11 | 1 << 10 | 1 << 9 | 1 << 8 | 1 << 5 | 1 << 2 | 1 << 0
  G15_MASK = 1 << 14 | 1 << 12 | 1 << 10 | 1 << 4 | 1 << 1

  DEMERIT_POINTS_1 =  3
  DEMERIT_POINTS_2 =  3
  DEMERIT_POINTS_3 = 40
  DEMERIT_POINTS_4 = 10

  BITS_FOR_MODE = {
    MODE[:mode_number]     => [10, 12, 14],
    MODE[:mode_alpha_numk] => [9, 11, 13],
    MODE[:mode_8bit_byte]  => [8, 16, 16],
    # MODE[:mode_kanji]      => [8, 10, 12],
  }

  def max_size
    PATTERN_POSITION_TABLE.size
  end

  def get_bch_format_info(data)
    d = data << 10
    while Utilities.get_bch_digit(d) - Utilities.get_bch_digit(G15) >= 0
      d ^= (G15 << (Utilities.get_bch_digit(d) - Utilities.get_bch_digit(G15)))
    end
    ((data << 10) | d) ^ G15_MASK
  end

  def rszf(num : Int32, count : Int32)
    # zero fill right shift
    # (num >> count ) & ((2 ** ((num.size * 8) - count)) - 1)
    if num < 0
      unum = (-num).to_u32
      unum = ((~unum) &+ 1)
      (unum >> count).to_i32
    else
      num >> count
    end
  end

  def rszf(num : UInt8, count : Int32)
    # zero fill right shift
    num >> count
  end

  def get_bch_version(data)
    d = data << 12
    while Utilities.get_bch_digit(d) - Utilities.get_bch_digit(G18) >= 0
      d ^= (G18 << (Utilities.get_bch_digit(d) - Utilities.get_bch_digit(G18)))
    end
    (data << 12) | d
  end

  def get_bch_digit(data)
    digit = 0

    while data != 0
      digit = digit + 1
      data = Utilities.rszf(data, 1)
    end

    digit
  end

  def get_pattern_positions(version)
    PATTERN_POSITION_TABLE[version - 1]
  end

  def get_mask(mask_pattern, i, j)
    if mask_pattern > MASK_COMPUTATIONS.size
      raise RuntimeError.new("bad mask_pattern: #{mask_pattern}")
    end

    MASK_COMPUTATIONS[mask_pattern].call(i, j)
  end

  def get_error_correct_polynomial(error_correct_length)
    a = Polynomial.new([1], 0)

    (0...error_correct_length).each do |i|
      a = a.multiply(Polynomial.new([1, Math.gexp(i)], 0))
    end

    a
  end

  def get_length_in_bits(mode, version)
    if !MODE.values.includes?(mode)
      raise RuntimeError.new("Unknown mode: #{mode}")
    end

    if version > 40
      raise RuntimeError.new("Unknown version: #{version}")
    end

    # 1 - 9
    macro_version = 0

    if version.in?(1..9)
      # 1 - 9
      macro_version = 0
    elsif version <= 26
      # 10 - 26
      macro_version = 1
    elsif version <= 40
      # 27 - 40
      macro_version = 2
    end

    BITS_FOR_MODE[mode][macro_version]
  end

  def get_lost_points(modules)
    demerit_points = 0

    demerit_points += Utilities.demerit_points_1_same_color(modules)
    demerit_points += Utilities.demerit_points_2_full_blocks(modules)
    demerit_points += Utilities.demerit_points_3_dangerous_patterns(modules)
    demerit_points += Utilities.demerit_points_4_dark_ratio(modules)

    demerit_points
  end

  def demerit_points_1_same_color(modules)
    demerit_points = 0
    module_count = modules.size

    # level1
    (0...module_count).each do |row|
      (0...module_count).each do |col|
        same_count = 0
        dark = modules[row][col]

        (-1..1).each do |r|
          next if row + r < 0 || module_count <= row + r

          (-1..1).each do |c|
            next if col + c < 0 || module_count <= col + c
            next if r == 0 && c == 0
            if dark == modules[row + r][col + c]
              same_count += 1
            end
          end
        end

        if same_count > 5
          demerit_points += (DEMERIT_POINTS_1 + same_count - 5)
        end
      end
    end

    demerit_points
  end

  def demerit_points_2_full_blocks(modules)
    demerit_points = 0
    module_count = modules.size

    # level 2
    (0...(module_count - 1)).each do |row|
      (0...(module_count - 1)).each do |col|
        count = 0
        count += 1 if modules[row][col]
        count += 1 if modules[row + 1][col]
        count += 1 if modules[row][col + 1]
        count += 1 if modules[row + 1][col + 1]
        if (count == 0 || count == 4)
          demerit_points += DEMERIT_POINTS_2
        end
      end
    end

    demerit_points
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def demerit_points_3_dangerous_patterns(modules)
    demerit_points = 0
    module_count = modules.size

    # level 3
    modules.each do |row|
      (module_count - 6).times do |col_idx|
        if row[col_idx] &&
           !row[col_idx + 1] &&
           row[col_idx + 2] &&
           row[col_idx + 3] &&
           row[col_idx + 4] &&
           !row[col_idx + 5] &&
           row[col_idx + 6]
          demerit_points += DEMERIT_POINTS_3
        end
      end
    end

    (0...module_count).each do |col|
      (0...(module_count - 6)).each do |row|
        if modules[row][col] &&
           !modules[row + 1][col] &&
           modules[row + 2][col] &&
           modules[row + 3][col] &&
           modules[row + 4][col] &&
           !modules[row + 5][col] &&
           modules[row + 6][col]
          demerit_points += DEMERIT_POINTS_3
        end
      end
    end

    demerit_points
  end

  def demerit_points_4_dark_ratio(modules)
    # level 4
    dark_count = modules.reduce(0) do |sum, col|
      sum + col.count(true)
    end

    ratio = dark_count / (modules.size * modules.size)
    ratio_delta = (100 * ratio - 50).abs / 5

    demerit_points = ratio_delta * DEMERIT_POINTS_4
    demerit_points
  end
end
