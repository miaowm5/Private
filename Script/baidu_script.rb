class Window_introduce < Window_Base
  def initialize
    super(80,80,640-160,480-160)
    self.back_opacity = 160
    self.opacity = 160
    self.contents_opacity = 255
    self.contents = Bitmap.new(width - 32, height - 32)
  end  
  def set_text(text, align = 0)
    if text != @text or align != @align      
      self.contents.clear
      self.contents.font.color = normal_color      
      # 获取描绘区域的属性
      # x,y：当前文字描绘的位置
      # width,height：描绘文字区域的宽度和高度
      # new_x：每行文字的开始x坐标
      pos = {
        :x => 0,:y => 0,
        :new_x => 0,:width => 500,:height => 32,
      }
      # 按照顺序依次描绘文字
      text.scan(/./).each {|c| process_character(c,pos) }
      @text,@align = text,align      
    end
    self.visible = true
  end
  def process_character(c,pos)    
    case c
    # 若文字为“/”则换行
    when '/'
      pos[:x] = pos[:new_x]
      pos[:y] += pos[:height]
    # 处理正常文字
    else
      # 获取文字大小
      size = self.contents.text_size(c)
      # 描绘文字
      self.contents.draw_text(pos[:x],pos[:y],pos[:width],pos[:height], c)
      # 计算下一个文字的描绘位置
      pos[:x] += size.width
    end
  end
end
