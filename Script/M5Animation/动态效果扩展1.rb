#==============================================================================
# ■ 动态精灵脚本 动态效果扩展1
#------------------------------------------------------------------------------
#
# 算法参考：http://www.cnblogs.com/cloudgamer/archive/2009/01/06/tween.html
#
#   bounce、sinin、sinout、sininout、backin、backout、backinout
#
#==============================================================================

module M5Script; module M5AnimationCore
class Easing
  def bounce
    b, target, time, ext = @data
    return @result = Array.new(time) if b == target
    c = target - b; d = time.to_f
    time.times do |t|
      t += 1; t /= d
      if t < ( 1 / 2.75 ); a = 0; t -= 0
      elsif t < ( 2 / 2.75 ); a = 0.75; t -= ( 1.5 / 2.75 )
      elsif t < ( 2.5 / 2.75 ); a = 0.9375; t -= ( 2.25 / 2.75 )
      else; a = 0.984375; t -= ( 2.625 / 2.75 )
      end
      @result << ( c * ( 7.5625 * t * t + a ) + b ).to_i
    end
  end
  def sinin
    b, target, time, ext = @data
    return @result = Array.new(time) if b == target
    c = target - b; d = time.to_f
    time.times do |t|
      t += 1
      @result << (-c * Math.cos(t/d * (Math::PI/2)) + c + b).to_i
    end
  end
  def sinout
    b, target, time, ext = @data
    return @result = Array.new(time) if b == target
    c = target - b; d = time.to_f
    time.times do |t|
      t += 1
      @result << (c * Math.sin(t/d * (Math::PI/2)) + b).to_i
    end
  end
  def sininout
    b, target, time, ext = @data
    return @result = Array.new(time) if b == target
    c = target - b; d = time.to_f
    time.times do |t|
      t += 1
      @result << (-c/2 * (Math.cos(Math::PI*t/d) - 1) + b).to_i
    end
  end
  def backin
    b, target, time, ext = @data
    return @result = Array.new(time) if b == target
    c = target - b; d = time.to_f
    time.times do |t|
      t += 1; t /= d; s = 1.70158
      @result << (c*t*t*((s+1)*t - s) + b).to_i
    end
  end
  def backout
    b, target, time, ext = @data
    return @result = Array.new(time) if b == target
    c = target - b; d = time.to_f
    time.times do |t|
      t += 1; t = t / d - 1; s = 1.70158
      @result << (c*(t*t*((s+1)*t + s) + 1) + b).to_i
    end
  end
  def backinout
    b, target, time, ext = @data
    return @result = Array.new(time) if b == target
    c = target - b; d = time.to_f
    time.times do |t|
      t += 1; s = 1.70158 * 1.525
      t /= d / 2
      if t < 1
        @result << (c/2*(t*t*((s+1)*t - s)) + b).to_i
      else
        t -= 2
        @result << (c/2*(t*t*((s+1)*t + s) + 2) + b).to_i
      end
    end
  end
end
end; end