class QRCode
  ALPHANUMERIC = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', ' ', '$', '%', '*', '+', '-', '.', '/', ':']
  NUMERIC      = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']

  MODE = {
    mode_number:     1 << 0,
    mode_alpha_numk: 1 << 1,
    mode_8bit_byte:  1 << 2,
  }

  MODE_NAME = {
    number:       :mode_number,
    alphanumeric: :mode_alpha_numk,
    byte_8bit:    :mode_8bit_byte,
  }

  ERROR_CORRECT_LEVEL = {
    l: 1,
    m: 0,
    q: 3,
    h: 2,
  }

  MASK_PATTERN = {
    pattern000: 0,
    pattern001: 1,
    pattern010: 2,
    pattern011: 3,
    pattern100: 4,
    pattern101: 5,
    pattern110: 6,
    pattern111: 7,
  }

  MASK_COMPUTATIONS = [
    Proc(Int32, Int32, Bool).new { |i, j| (i + j) % 2 == 0 },
    Proc(Int32, Int32, Bool).new { |i, _| i % 2 == 0 },
    Proc(Int32, Int32, Bool).new { |_, j| j % 3 == 0 },
    Proc(Int32, Int32, Bool).new { |i, j| (i + j) % 3 == 0 },
    Proc(Int32, Int32, Bool).new { |i, j| ((i // 2) + (j // 3)) % 2 == 0 },
    Proc(Int32, Int32, Bool).new { |i, j| (i * j) % 2 + (i * j) % 3 == 0 },
    Proc(Int32, Int32, Bool).new { |i, j| ((i * j) % 2 + (i * j) % 3) % 2 == 0 },
    Proc(Int32, Int32, Bool).new { |i, j| ((i * j) % 3 + (i + j) % 2) % 2 == 0 },
  ]

  POSITION_PATTERN_LENGTH = (7 + 1) * 2 + 1
  FORMAT_INFO_LENGTH      = 15

  # http://web.archive.org/web/20110710094955/http://www.denso-wave.com/qrcode/vertable1-e.html
  # http://web.archive.org/web/20110710094955/http://www.denso-wave.com/qrcode/vertable2-e.html
  # http://web.archive.org/web/20110710094955/http://www.denso-wave.com/qrcode/vertable3-e.html
  # http://web.archive.org/web/20110710094955/http://www.denso-wave.com/qrcode/vertable4-e.html
  # Each array contains levels max chars from level 1 to level 40
  MAX_DIGITS = {
    l: {
      mode_number: [
        41, 77, 127, 187, 255, 322, 370, 461, 552, 652, 772,
        883, 1022, 1101, 1250, 1408, 1548, 1725, 1903, 2061,
        2232, 2409, 2620, 2812, 3057, 3283, 3514, 3669, 3909, 4158,
        4417, 4686, 4965, 5253, 5529, 5836, 6153, 6479, 6743, 7089,
      ],
      mode_alpha_numk: [
        25, 47, 77, 114, 154, 195, 224, 279, 335, 395,
        468, 535, 619, 667, 758, 854, 938, 1046, 1153, 1249,
        1352, 1460, 1588, 1704, 1853, 1990, 2132, 2223, 2369, 2520,
        2677, 2840, 3009, 3183, 3351, 3537, 3729, 3927, 4087, 4296,
      ],
      mode_8bit_byte: [
        17, 32, 53, 78, 106, 134, 154, 192, 230, 271,
        321, 367, 425, 458, 520, 586, 644, 718, 792, 858,
        929, 1003, 1091, 1171, 1273, 1367, 1465, 1528, 1628, 1732,
        1840, 1952, 2068, 2188, 2303, 2431, 2563, 2699, 2809, 2953,
      ],
    },
    m: {
      mode_number: [
        34, 63, 101, 149, 202, 255, 293, 365, 432, 513,
        604, 691, 796, 871, 991, 1082, 1212, 1346, 1500, 1600,
        1708, 1872, 2059, 2188, 2395, 2544, 2701, 2857, 3035, 3289,
        3486, 3693, 3909, 4134, 4343, 4588, 4775, 5039, 5313, 5596,
      ],
      mode_alpha_numk: [
        20, 38, 61, 90, 122, 154, 178, 221, 262, 311,
        366, 419, 483, 528, 600, 656, 734, 816, 909, 970,
        1035, 1134, 1248, 1326, 1451, 1542, 1637, 1732, 1839, 1994,
        2113, 2238, 2369, 2506, 2632, 2780, 2894, 3054, 3220, 3391,
      ],
      mode_8bit_byte: [
        14, 26, 42, 62, 84, 106, 122, 152, 180, 213,
        251, 287, 331, 362, 412, 450, 504, 560, 624, 666,
        711, 779, 857, 911, 997, 1059, 1125, 1190, 1264, 1370,
        1452, 1538, 1628, 1722, 1809, 1911, 1989, 2099, 2213, 2331,
      ],
    },
    q: {
      mode_number: [
        27, 48, 77, 111, 144, 178, 207, 259, 312, 364,
        427, 489, 580, 621, 703, 775, 876, 948, 1063, 1159,
        1224, 1358, 1468, 1588, 1718, 1804, 1933, 2085, 2181, 2358,
        2473, 2670, 2805, 2949, 3081, 3244, 3417, 3599, 3791, 3993,
      ],
      mode_alpha_numk: [
        16, 29, 47, 67, 87, 108, 125, 157, 189, 221,
        259, 296, 352, 376, 426, 470, 531, 574, 644, 702,
        742, 823, 890, 963, 1041, 1094, 1172, 1263, 1322, 1429,
        1499, 1618, 1700, 1787, 1867, 1966, 2071, 2181, 2298, 2420,
      ],
      mode_8bit_byte: [
        11, 20, 32, 46, 60, 74, 86, 108, 130, 151,
        177, 203, 241, 258, 292, 22, 364, 394, 442, 482,
        509, 565, 611, 661, 715, 751, 805, 868, 908, 982,
        1030, 1112, 1168, 1228, 1283, 1351, 1423, 1499, 1579, 1663,
      ],
    },
    h: {
      mode_number: [
        17, 34, 58, 82, 106, 139, 154, 202, 235, 288, 331, 374, 427, 468, 530, 602, 674,
        331, 374, 427, 468, 530, 602, 674, 746, 813, 919,
        969, 1056, 1108, 1228, 1286, 1425, 1501, 1581, 1677, 1782,
        1897, 2022, 2157, 2301, 2361, 2524, 2625, 2735, 2927, 3057,
      ],
      mode_alpha_numk: [
        10, 20, 35, 50, 64, 84, 93, 122, 143, 174, 200,
        200, 227, 259, 283, 321, 365, 408, 452, 493, 557,
        587, 640, 672, 744, 779, 864, 910, 958, 1016, 1080,
        1150, 1226, 1307, 1394, 1431, 1530, 1591, 1658, 1774, 1852,
      ],
      mode_8bit_byte: [
        7, 14, 24, 34, 44, 58, 64, 84, 98, 119,
        137, 155, 177, 194, 220, 250, 280, 310, 338, 382,
        403, 439, 461, 511, 535, 593, 625, 658, 698, 742,
        790, 842, 898, 958, 983, 1051, 1093, 1139, 1219, 1273,
      ],
    },
  }

  class ArgumentError < ArgumentError; end

  class RuntimeError < RuntimeError; end
end

require "./qr-code/*"

class QRCode
  getter modules : Array(Array(Bool?))
  getter module_count : Int32
  getter version : Int32

  @common_patterns : Array(Array(Bool?))? = nil
  @data_cache : Array(Int32)?
  @error_correct_level : Int32
  @data_list : Numeric | Alphanumeric | EightBitByte

  def initialize(@data : String, size : Int32? = nil, level : Symbol = :h, mode : Symbol? = nil)
    mode = MODE_NAME[mode] if mode
    mode ||= case
             when Numeric.valid_data?(@data)
               MODE_NAME[:number]
             when Alphanumeric.valid_data?(@data)
               MODE_NAME[:alphanumeric]
             else
               MODE_NAME[:byte_8bit]
             end
    max_size_array = MAX_DIGITS[level][mode]
    size = size || smallest_size_for(@data, max_size_array)

    if size > Utilities.max_size
      raise ArgumentError.new("Given size greater than maximum possible size of #{Utilities.max_size}")
    end

    @error_correct_level = ERROR_CORRECT_LEVEL[level]
    @version = size
    @module_count = @version * 4 + POSITION_PATTERN_LENGTH
    @modules = Array.new(@module_count, [] of Bool?)
    @data_list =
      case mode
      when :mode_number
        Numeric.new(@data)
      when :mode_alpha_numk
        Alphanumeric.new(@data)
      else
        EightBitByte.new(@data)
      end

    @data_cache = nil
    make
  end

  # <tt>checked?</tt> is called with a +col+ and +row+ parameter. This will
  # return true or false based on whether that coordinate exists in the
  # matrix returned. It would normally be called while iterating through
  # <tt>modules</tt>. A simple example would be:
  #
  #  instance.checked?( 10, 10 ) => true
  #

  def checked?(row, col)
    if !row.in?(0...@module_count) || !col.in?(0...@module_count)
      raise RuntimeError.new("Invalid row/column pair: #{row}, #{col}")
    end
    @modules[row][col]
  end

  # This is a public method that returns the QR Code you have
  # generated as a string. It will not be able to be read
  # in this format by a QR Code reader, but will give you an
  # idea if the final outout. It takes two optional args
  # +:true+ and +:false+ which are there for you to choose
  # how the output looks. Here's an example of it's use:
  #
  #  instance.to_s =>
  #  xxxxxxx x  x x   x x  xx  xxxxxxx
  #  x     x  xxx  xxxxxx xxx  x     x
  #  x xxx x  xxxxx x       xx x xxx x
  #
  #  instance.to_s( dark: 'E', light: 'Q' ) =>
  #  EEEEEEEQEQQEQEQQQEQEQQEEQQEEEEEEE
  #  EQQQQQEQQEEEQQEEEEEEQEEEQQEQQQQQE
  #  EQEEEQEQQEEEEEQEQQQQQQQEEQEQEEEQE
  #

  def to_s(dark : Char = 'x', light : Char = ' ', quiet_zone_size : Int32 = 0)
    rows = [] of Array(Char)

    @modules.each do |row|
      cols = Array.new(quiet_zone_size, light)
      row.each do |col|
        cols << (col ? dark : light)
      end
      rows << cols
    end

    quiet_zone_size.times do
      rows.unshift(Array.new(rows.first.size, light))
      rows << Array.new(rows.first.size, light)
    end
    rows.map(&.join("")).join("\n")
  end

  # Public overide as default inspect is very verbose
  #
  #  RQRCodeCore::QRCode.new('my string to generate', size: 4, level: :h)
  # => QRCodeCore: @data='my string to generate', @error_correct_level=2, @version=4, @module_count=33
  #

  def inspect
    "QRCode: @data='#{@data}', @error_correct_level=#{@error_correct_level}, @version=#{@version}, @module_count=#{@module_count}"
  end

  # Return a symbol for current error connection level
  def error_correction_level
    ERROR_CORRECT_LEVEL.each do |key, value|
      return key if value == @error_correct_level
    end
  end

  # Return a symbol in QRMODE.keys for current mode used
  def mode
    case @data_list
    when Numeric
      :mode_number
    when Alphanumeric
      :mode_alpha_numk
    else
      :mode_8bit_byte
    end
  end

  protected def make # :nodoc:
    prepare_common_patterns
    make_impl(false, get_best_mask_pattern)
  end

  private def prepare_common_patterns
    @modules.map! { Array(Bool?).new(@module_count, nil) }

    place_position_probe_pattern(0, 0)
    place_position_probe_pattern(@module_count - 7, 0)
    place_position_probe_pattern(0, @module_count - 7)
    place_position_adjust_pattern
    place_timing_pattern

    @common_patterns = @modules.map(&.clone)
  end

  private def make_impl(test, mask_pattern) # :nodoc:
    @modules = @common_patterns.not_nil!.map(&.clone)

    place_format_info(test, mask_pattern)
    place_version_info(test) if @version >= 7

    if @data_cache.nil?
      @data_cache = QRCode.create_data(
        @version, @error_correct_level, @data_list
      )
    end

    map_data(@data_cache.not_nil!, mask_pattern)
  end

  private def place_position_probe_pattern(row, col) # :nodoc:
    (-1..7).each do |r|
      next if !(row + r).in?(0...@module_count)

      (-1..7).each do |c|
        next if !(col + c).in?(0...@module_count)

        is_vert_line = (r.in?(0..6) && (c == 0 || c == 6))
        is_horiz_line = (c.in?(0..6) && (r == 0 || r == 6))
        is_square = r.in?(2..4) && c.in?(2..4)

        is_part_of_probe = is_vert_line || is_horiz_line || is_square
        @modules[row + r][col + c] = is_part_of_probe
      end
    end
  end

  private def get_best_mask_pattern # :nodoc:
    min_lost_point = 0
    pattern = 0

    (0...8).each do |i|
      make_impl(true, i)
      lost_point = Utilities.get_lost_points(self.modules)

      if i == 0 || min_lost_point > lost_point
        min_lost_point = lost_point
        pattern = i
      end
    end
    pattern
  end

  private def place_timing_pattern # :nodoc:
    len = @module_count - 8
    (8...len).each do |i|
      @modules[i][6] = @modules[6][i] = i % 2 == 0
    end
  end

  private def place_position_adjust_pattern # :nodoc:
    positions = Utilities.get_pattern_positions(@version)

    positions.each do |row|
      positions.each do |col|
        next unless @modules[row][col].nil?

        (-2..2).each do |r|
          (-2..2).each do |c|
            is_part_of_pattern = (r.abs == 2 || c.abs == 2 || (r == 0 && c == 0))
            @modules[row + r][col + c] = is_part_of_pattern
          end
        end
      end
    end
  end

  private def place_version_info(test) # :nodoc:
    bits = Utilities.get_bch_version(@version)

    (0...18).each do |i|
      mod = (!test && ((bits >> i) & 1) == 1)
      @modules[i // 3][i % 3 + @module_count - 8 - 3] = mod
      @modules[i % 3 + @module_count - 8 - 3][i // 3] = mod
    end
  end

  private def place_format_info(test, mask_pattern) # :nodoc:
    data = (@error_correct_level << 3 | mask_pattern)
    bits = Utilities.get_bch_format_info(data)

    FORMAT_INFO_LENGTH.times do |i|
      mod = (!test && ((bits >> i) & 1) == 1)

      # vertical
      if i < 6
        row = i
      elsif i < 8
        row = i + 1
      else
        row = @module_count - 15 + i
      end
      @modules[row][8] = mod

      # horizontal
      if i < 8
        col = @module_count - i - 1
      elsif i < 9
        col = 15 - i - 1 + 1
      else
        col = 15 - i - 1
      end
      @modules[8][col] = mod
    end

    # fixed module
    @modules[@module_count - 8][8] = !test
  end

  private def map_data(data, mask_pattern) # :nodoc:
    inc = -1
    row = @module_count - 1
    bit_index = 7
    byte_index = 0

    (@module_count - 1).step(to: 1, by: -2) do |col|
      col = col - 1 if col <= 6

      loop do
        (0...2).each do |c|
          if @modules[row][col - c].nil?
            dark = false
            if byte_index < data.size && !data[byte_index]?.nil?
              dark = ((Utilities.rszf(data[byte_index], bit_index) & 1) == 1)
            end
            mask = Utilities.get_mask(mask_pattern, row, col - c)
            dark = !dark if mask
            @modules[row][col - c] = dark
            bit_index -= 1

            if bit_index == -1
              byte_index += 1
              bit_index = 7
            end
          end
        end

        row += inc

        if row < 0 || @module_count <= row
          row -= inc
          inc = -inc
          break
        end
      end
    end
  end

  private def smallest_size_for(string, max_size_array) # :nodoc:
    l = string.bytesize
    ver = max_size_array.index { |i| i >= l }
    raise RuntimeError.new("code length overflow. (#{l} digits > any version capacity)") unless ver
    ver + 1
  end

  def self.count_max_data_bits(rs_blocks)
    max_data_bytes = rs_blocks.reduce(0) do |sum, rs_block|
      sum + rs_block.data_count
    end

    max_data_bytes * 8
  end

  def self.create_data(version, error_correct_level, data_list) # :nodoc:
    rs_blocks = RSBlock.get_rs_blocks(version, error_correct_level)
    max_data_bits = QRCode.count_max_data_bits(rs_blocks)
    buffer = BitBuffer.new(version)

    data_list.write(buffer)
    buffer.end_of_message(max_data_bits)

    if buffer.get_length_in_bits > max_data_bits
      raise RuntimeError.new("code length overflow. (#{buffer.get_length_in_bits}>#{max_data_bits}). (Try a larger size!)")
    end

    buffer.pad_until(max_data_bits)

    QRCode.create_bytes(buffer, rs_blocks)
  end

  def self.create_bytes(buffer, rs_blocks) # :nodoc:
    offset = 0
    max_dc_count = 0
    max_ec_count = 0
    dcdata = Array.new(rs_blocks.size, [] of Int32)
    ecdata = Array.new(rs_blocks.size, [] of Int32)

    rs_blocks.each_with_index do |rs_block, r|
      dc_count = rs_block.data_count
      ec_count = rs_block.total_count - dc_count
      max_dc_count = [max_dc_count, dc_count].max
      max_ec_count = [max_ec_count, ec_count].max

      dcdata_block = Array.new(dc_count, 0)
      dcdata_block.size.times do |i|
        dcdata_block[i] = 0xff & buffer.buffer[i + offset]
      end
      dcdata[r] = dcdata_block

      offset = offset + dc_count
      rs_poly = Utilities.get_error_correct_polynomial(ec_count)
      raw_poly = Polynomial.new(dcdata[r], rs_poly.get_length - 1)
      mod_poly = raw_poly.mod(rs_poly)

      ecdata_block = Array.new(rs_poly.get_length - 1, 0)
      ecdata_block.size.times do |i|
        mod_index = i + mod_poly.get_length - ecdata_block.size
        ecdata_block[i] = mod_index >= 0 ? mod_poly.get(mod_index) : 0
      end
      ecdata[r] = ecdata_block
    end

    total_code_count = rs_blocks.reduce(0) do |sum, rs_block|
      sum + rs_block.total_count
    end

    data = Array.new(total_code_count, 0)
    index = 0

    max_dc_count.times do |i|
      rs_blocks.size.times do |r|
        if i < dcdata[r].size
          data[index] = dcdata[r][i]
          index += 1
        end
      end
    end

    max_ec_count.times do |i|
      rs_blocks.size.times do |r|
        if i < ecdata[r].size
          data[index] = ecdata[r][i]
          index += 1
        end
      end
    end

    data
  end
end

require "./qr-code/export/*"
