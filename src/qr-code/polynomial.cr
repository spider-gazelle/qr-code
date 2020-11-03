require "./math"

class QRCode::Polynomial
  @num : Array(Int32)

  def initialize(num : Array(Int32), shift : Int32)
    raise RuntimeError.new("#{num.size}/#{shift}") if num.empty?
    offset = 0

    while offset < num.size && num[offset] == 0
      offset = offset + 1
    end

    @num = Array(Int32).new(num.size - offset + shift, 0)

    (0...(num.size - offset)).each do |i|
      @num[i] = num[i + offset]
    end
  end

  def get(index)
    @num[index]
  end

  def get_length
    @num.size
  end

  def multiply(e)
    num = Array(Int32).new(get_length + e.get_length - 1, 0)

    (0...get_length).each do |i|
      (0...e.get_length).each do |j|
        tmp = num[i + j].nil? ? 0 : num[i + j]
        num[i + j] = tmp ^ Math.gexp(Math.glog(get(i)) + Math.glog(e.get(j)))
      end
    end

    Polynomial.new(num, 0)
  end

  def mod(e)
    if get_length - e.get_length < 0
      return self
    end

    ratio = Math.glog(get(0)) - Math.glog(e.get(0))
    num = Array(Int32).new(get_length, 0)

    (0...get_length).each do |i|
      num[i] = get(i)
    end

    (0...e.get_length).each do |i|
      tmp = num[i].nil? ? 0 : num[i]
      num[i] = tmp ^ Math.gexp(Math.glog(e.get(i)) + ratio)
    end

    Polynomial.new(num, 0).mod(e)
  end
end
