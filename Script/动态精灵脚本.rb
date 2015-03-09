#==============================================================================
# ■ 动态精灵脚本
#------------------------------------------------------------------------------
#
#   载入：include M5Script::M5Animation
#         load_m5_animation、update_m5_animation
#
#   方法：animate、delay、stop、animate?
#   
#==============================================================================

#--------------------------------------------------------------------------
# ● 需要注入精灵类的模块
#--------------------------------------------------------------------------
module M5Script; module M5Animation
  #--------------------------------------------------------------------------
  # ● 载入
  #--------------------------------------------------------------------------
  def load_m5_animation
    @m5_animation = M5Script::M5AnimationCore.new(self)
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update_m5_animation; @m5_animation.update; end
  #--------------------------------------------------------------------------
  # ● 设置效果
  #--------------------------------------------------------------------------
  def animate; return @m5_animation.animate; end
  #--------------------------------------------------------------------------
  # ● 延时
  #--------------------------------------------------------------------------
  def delay; return @m5_animation.delay; end
  #--------------------------------------------------------------------------
  # ● 停止效果
  #--------------------------------------------------------------------------
  def stop; return @m5_animation.stop; end
  #--------------------------------------------------------------------------
  # ● 是否正在播放效果？
  #--------------------------------------------------------------------------
  def animate?; return @m5_animation.animate; end
end # module M5Animation
#--------------------------------------------------------------------------
# ● 核心模块
#--------------------------------------------------------------------------
module M5AnimationCore
#--------------------------------------------------------------------------
# ● 控制效果速度的类
#--------------------------------------------------------------------------
class Easing
  #--------------------------------------------------------------------------
  # ● 预置时间列表
  #--------------------------------------------------------------------------
  def time_list
    return {
      "normal" => 20,
      "fast" => 5,
      "slow" => 40,
    }
  end  
  #--------------------------------------------------------------------------
  # ● 线性变化
  #--------------------------------------------------------------------------
  def linner
    origin, target, time, ext = @data    
    return @result = Array.new(time) if origin == target    
    amount = ( target - origin ) / time.to_f
    time.times { |i| @result << ( origin + amount * (i + 1) ).to_i }    
  end
  #--------------------------------------------------------------------------
  # ● 获取时间
  #--------------------------------------------------------------------------
  def get_time(time)
    time = time_list[time] || time_list["normal"] if time.is_a?(String)
    return time
  end
  #--------------------------------------------------------------------------
  # ● 计算每帧的属性值
  #--------------------------------------------------------------------------
  def set(origin, target, time ,type , ext)
    type = "linner" if !respond_to?(type)
    @result = []
    @data = [origin, target, time, ext]
    send(type)
    return @result.clone
  end
end
#--------------------------------------------------------------------------
# ● 设置精灵效果的类
#--------------------------------------------------------------------------
class Animation
  #--------------------------------------------------------------------------
  # ● 载入
  #--------------------------------------------------------------------------
  def initialize(sprite)
    @sprite = sprite
    @easing = Easing.new
    stop
  end
  #--------------------------------------------------------------------------
  # ● 设置效果
  #--------------------------------------------------------------------------
  def animate(styles={},speed="normal",easing="linner",ext={})
    time = @easing.get_time(speed)
    current = get_current_data
    current.each_pair do |property, origin|
      target = styles[property] || origin
      @effect[property] += @easing.set(origin, target, time ,easing , ext)
    end
    self
  end
  #--------------------------------------------------------------------------
  # ● 判定是否正在播放效果
  #--------------------------------------------------------------------------
  def animate?
    @effect.map { |e| return true if e.size > 0 }
    false
  end
  #--------------------------------------------------------------------------
  # ● 延迟播放效果
  #--------------------------------------------------------------------------
  def delay(time)
    @effect.each_pair do |property, origin|
      @effect[property] += Array.new(time)
    end
    self
  end
  #--------------------------------------------------------------------------
  # ● 停止一切效果
  #--------------------------------------------------------------------------
  def stop
    @effect = { :x => [], :y => [], :ox => [], :oy => [],
      :zoom_x => [], :zoom_y => [], :angle => [], :opacity => [] }
  end
  #--------------------------------------------------------------------------
  # ● 获取当前效果
  #--------------------------------------------------------------------------
  def get_current_data
    return {
      :x => get_effect_value(:x) || @sprite.x,
      :y => get_effect_value(:y) || @sprite.y,      
      :ox => get_effect_value(:ox) || @sprite.ox,
      :oy => get_effect_value(:oy) || @sprite.oy,
      :zoom_x => get_effect_value(:zoom_x) || @sprite.zoom_x * 100,
      :zoom_y => get_effect_value(:zoom_y) || @sprite.zoom_y * 100,
      :angle => get_effect_value(:angle) || @sprite.angle,
      :opacity => get_effect_value(:opacity) || @sprite.opacity
    }
  end
  #--------------------------------------------------------------------------
  # ● 获取效果结束后的精灵属性值
  #--------------------------------------------------------------------------
  def get_effect_value(property)
    return nil if (size = @effect[property].size) == 0    
    loop do
      value = @effect[property][size -= 1]
      return value if value
      break if size == 0
    end
    return nil
  end
  #--------------------------------------------------------------------------
  # ● 更新精灵
  #--------------------------------------------------------------------------
  def update
    x,y = @effect[:x].shift, @effect[:y].shift
    ox,oy = @effect[:ox].shift, @effect[:oy].shift
    @sprite.x = x if x
    @sprite.y = y if y
    @sprite.ox = ox if ox
    @sprite.oy = oy if oy
    
    zoom_x,zoom_y = @effect[:zoom_x].shift, @effect[:zoom_y].shift    
    @sprite.zoom_x = zoom_x / 100.0 if zoom_x
    @sprite.zoom_y = zoom_y / 100.0 if zoom_y
    
    angle = @effect[:angle].shift
    @sprite.angle = angle % 360 if angle
    
    opacity = @effect[:opacity].shift
    @sprite.opacity = opacity if opacity
  end
end
end # module M5AnimationCore
end # module M5Script
