#==============================================================================
# ■ 动态精灵脚本
#------------------------------------------------------------------------------
#
#   载入: include M5Script::M5Animation
#
#   方法：animate、delay、stop、animate?
#
#   使用脚本请署名，用于营利为目的的游戏请事先与我联系
#
#==============================================================================

#--------------------------------------------------------------------------
# ● 需要注入精灵类的模块
#--------------------------------------------------------------------------
module M5Script; module M5Animation
  #--------------------------------------------------------------------------
  # ● 载入
  #--------------------------------------------------------------------------
  def load_m5_20150309_animation
    @m5_animation = M5Script::M5AnimationCore::Animation.new(self)
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update_m5_20150309_animation
    @m5_animation.update
  end
  #--------------------------------------------------------------------------
  # ● 读者方法
  #--------------------------------------------------------------------------
  def m5_animation
    @m5_animation
  end
end
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
  # ● linner 线性变化
  #--------------------------------------------------------------------------
  def linner
    origin, target, time, ext = @data
    return @result = Array.new(time) if origin == target
    amount = ( target - origin ) / time.to_f
    time.times { |t| @result << ( origin + amount * (t + 1) ).to_i }
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
    time = get_time(time)
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
    raise '仅允许绑定精灵' unless sprite.is_a?(Sprite)
    @sprite = sprite
    @easing = Easing.new
    @callback = []
    stop
  end
  #--------------------------------------------------------------------------
  # ● 停止一切效果
  #--------------------------------------------------------------------------
  def stop
    @effect = {}
    effect_list.each { |p| @effect[p] = [] }
    @callback = []
  end
  #--------------------------------------------------------------------------
  # ● 允许操作的属性列表
  #--------------------------------------------------------------------------
  def effect_list
    [:x, :y, :zoom_x , :zoom_y , :angle , :opacity]
  end
  #--------------------------------------------------------------------------
  # ● 设置效果
  #--------------------------------------------------------------------------
  def animate(styles={},time="normal",easing="linner",ext={},callback=nil)
    current = get_current_data
    current.each_pair do |property, origin|
      target = styles[property] || origin
      @effect[property] += @easing.set(origin, target, time ,easing, ext)
    end
    add_callback(callback,time)
    self
  end
  #--------------------------------------------------------------------------
  # ● 设置回调
  #--------------------------------------------------------------------------
  def add_callback(callback,time)
    if callback
      @callback = Array.new(@easing.get_time(time))
      @callback << callback
    end
  end
  #--------------------------------------------------------------------------
  # ● 替换效果
  #--------------------------------------------------------------------------
  def replace(styles={},time="normal",easing="linner",ext={},callback=nil)
    current = get_current_data
    effect_list.each do |p|
      next unless styles[p]
      origin, target = current[p], styles[p]
      @effect[p] = @easing.set(origin, target, time ,easing, ext)
    end
    add_callback(callback,time)
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
  # ● 获取当前效果
  #--------------------------------------------------------------------------
  def get_current_data
    return {
      :x => get_effect_value(:x) || @sprite.x,
      :y => get_effect_value(:y) || @sprite.y,
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
    @sprite.x = x if x
    @sprite.y = y if y

    zoom_x,zoom_y = @effect[:zoom_x].shift, @effect[:zoom_y].shift
    @sprite.zoom_x = zoom_x / 100.0 if zoom_x
    @sprite.zoom_y = zoom_y / 100.0 if zoom_y

    angle = @effect[:angle].shift
    @sprite.angle = angle % 360 if angle

    opacity = @effect[:opacity].shift
    @sprite.opacity = opacity if opacity

    callback = @callback.shift
    callback.call if callback
  end
end
end # module M5AnimationCore
end # module M5Script
#--------------------------------------------------------------------------
# ● 注入精灵类
#--------------------------------------------------------------------------
class Sprite
  alias m5_20150309_initialize initialize
  def initialize *args
    m5_20150309_initialize *args
    load_m5_20150309_animation if respond_to?(:load_m5_20150309_animation)
  end
  alias m5_20150309_update update
  def update *args
    m5_20150309_update *args
    update_m5_20150309_animation if respond_to?(:update_m5_20150309_animation)
  end
end