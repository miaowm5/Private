class Window_introduce < Window_Base
  def initialize
    super(80,80,640-160,480-160)
    self.back_opacity = 160                               #
    self.opacity = 160      #这里都是透明度，
    self.contents_opacity = 255                       #
    self.contents = Bitmap.new(width - 32, height - 32) #这个不管他，照搬

  end

  #--------------------------------------------------------------------------
  # ● 设置文本
  #     text  : 窗口显示的字符串
  #     align : 对齐方式 (0..左对齐、1..中间对齐、2..右对齐)
  #--------------------------------------------------------------------------
  def set_text(text, align = 0)
    if text != @text or align != @align
      # 再描绘文本
      self.contents.clear
      self.contents.font.color = normal_color
      pos = {
        :x => 0,:y => 0,
        :new_x => 0,:width => 500,:height => 32,
      }
      text = text.scan(/./)
      text.each {|c| process_character(c,pos) }
      @text = text
      @align = align
      @actor = nil
    end
    self.visible = true
  end
  def process_character(c,pos)
    size = self.contents.text_size(c)    
    case c
    when '/'
      pos[:x] = pos[:new_x]
      pos[:y] += size.height
    else
      self.contents.draw_text(pos[:x],pos[:y],500,32, c)
      pos[:x] += size.width
    end
  end
end
