=begin
===============================================================================
  公共事件转换为特殊界面 By喵呜喵5
===============================================================================

【说明】

  可以将按照指定格式设置的公共事件转换为类似音乐盒、书籍系统这样的特殊界面

  ● 特殊规约注意！

    将本脚本用于收费游戏前请与我联系。

  ● 公共事件的设置格式

    请参考范例附带的说明文档

  ● 打开对应公共事件转换的界面

    在事件指令中的脚本里输入

    M5CES20141001.call(公共事件的ID)

      打开对应界面，按取消键可以回到当前界面

    M5CES20141001.jump(公共事件的ID)

      跳转到对应界面，按取消键将返回本界面之前的界面

=end
$m5script ||= {};$m5script[:M5CES20141001] = 20160102
module M5CES20141001
  MENU = [
#==============================================================================
#  设定部分
#==============================================================================


  ["持有道具",4],["清新道具",12],["制作人员",8],


  # 在这里设置后可以将转换的界面加入菜单
  # 设置格式为

  #    ["菜单指令名称",对应的公共事件ID],

  # 菜单指令的名称前后需要加上英文双引号，结尾需要加上英文逗号
  # 每条设置前后需要加上英文中括号，结尾需要加上英文逗号
  ]


  VAR = 6

  # 在这里设置一个变量ID，如果对应ID的变量值大于0，默认的菜单将被替换，
  # 取而代之，将打开与该变量值对应编号的公共事件生成的界面

#==============================================================================
#  设定结束
#==============================================================================
  def self.call(id = 1)
    SceneManager.call(Scene)
    SceneManager.scene.prepare(id)
    wait_for_input
  end
  def self.jump(id = 1)
    if SceneManager.scene_is?(Scene)
      bgm = SceneManager.scene.bgm
      bgs = SceneManager.scene.bgs
    end
    SceneManager.goto(Scene)
    SceneManager.scene.prepare(id,bgm,bgs)
    wait_for_input
  end
  def self.refresh
    return unless SceneManager.scene_is?(Scene)
    id = SceneManager.scene.ev
    jump(id)
  end
  def self.wait_for_input
    while Input.press?(:C)
      Graphics.wait 1
      Input.update
    end
  end
end # module M5CES20141001
module M5CES20141001
#--------------------------------------------------------------------------
# ● Window_Method
#--------------------------------------------------------------------------
module Window_Method
  def set_window(setting)
    self.x,self.y = c2number(setting[:X],0), c2number(setting[:Y],0)
    self.windowskin = Cache.system(setting[:Skin]) if setting[:Skin]
    self.width = c2number(setting[:Width], window_width)
    self.height = c2number(setting[:Height], window_height)
    create_contents
    self.visible = false if setting[:Hide]
    if setting[:Opacity].is_a?(String)
      self.opacity = setting[:Opacity].to_i
    elsif setting[:Opacity]
      self.opacity = 0
    end
  end
  def c2number(value,default)
    if value
      return value.to_i
    else
      return default
    end
  end
end

end # module M5CES20141001
module M5CES20141001
#--------------------------------------------------------------------------
# ● Load
#--------------------------------------------------------------------------
class Load < Game_Interpreter
  def clear
    super
    @open = []
    @after_open = []
    @input_list = {}
    @setting_list = {}
    @command = []
    @end = []
    @status = :open
  end
  alias m5_ces_setup1 setup
  def setup(list)
    m5_ces_setup1(list, 0)
    update while running?
    return @open,@after_open,@command,@input_list,@end,@setting_list
  end
  def setup2(list)
    m5_ces_setup1(list, 0)
    @status = :command_setting
    update while running?
    return @command
  end
  def wait_for_message;end
  def run
    while @list[@index] do
      execute_command
      @index += 1
    end
    Fiber.yield
    @fiber = nil
  end
  def this_event; @list[@index]; end
  def jump_to_next(condition)
    @index += 1
    ev_list = []
    while eval(condition)
      ev_list.push this_event
      @index += 1
    end
    return ev_list
  end
  def execute_command
    command = @list[@index]
    @params = command.parameters
    @indent = command.indent
    case @status
    when :open
      get_open_command(command)
    when :command
      get_command_list(command)
    when :command_setting
      get_command_setting(command)
    when :end
      @end.push command
    end
  end
  def get_open_command(command)
    if command.code == 112 && @indent == 0
      @open.push RPG::EventCommand.new(0,0,[])
      @status = :command
    elsif command.code == 111 && @params[0] == 11
      command_list = []
      input = case @params[1]
              when 2  then :DOWN ; when 8  then :UP
              when 4  then :LEFT ; when 6  then :RIGHT
              when 11 then :A ;    when 12 then :B
              when 13 then :C ;    when 14 then :X
              when 15 then :Y ;    when 16 then :Z
              when 17 then :L ;    when 18 then :R
              end
      @input_list[input] = jump_to_next("this_event.indent > @indent")
      @index -= 1
      jump_to_next("this_event.indent > @indent && this_event.code != 412")
    elsif command.code == 111 && @params == [2,"A",0]
      command_list = []
      @after_open = jump_to_next("this_event.indent > @indent")
      @index -= 1
      jump_to_next("this_event.indent > @indent && this_event.code != 412")
    elsif command.code == 111
      command_111
    elsif command.code == 411
      command_411
    elsif command.code == 108 || command.code == 408
      get_setting_list
    else
      @open.push command
    end
  end
  def get_command_list(command)
    @index -= 1
    @command = jump_to_next("this_event.code != 413 && this_event.indent != 0")
    @status = :end
  end
  def get_command_setting(command)
    if command.code == 111
      command_111
    elsif command.code == 411
      command_411
    elsif command.code == 402
      name = command.parameters[1]
      choice_command = jump_to_next("this_event.indent > @indent")
      while this_event.code != 403 && this_event.code != 404
        jump_to_next("this_event.indent > @indent")
      end
      if this_event.code == 403
        hover_command = jump_to_next("this_event.indent > @indent")
      end
      hover_command ||= []
      choice_command.push RPG::EventCommand.new(0,0,[])
      hover_command.push RPG::EventCommand.new(0,0,[])
      @command.push [name, choice_command, hover_command]
    end
  end
  def get_setting_list
    return unless (/^\s*(\S+)\s+(.+)$/) =~ @params[0]
    name = $1
    setting_array = $2.scan(/\s*(.+?)\s*([,，]|$)/)
    /(\D+)(\d*)/ =~ name
    name = (regular_name($1) + $2).to_sym
    @setting_list[name] ||= {}
    setting_array.each do |s|
      s[0].scan(/(.+?)\s*([:：]\s*(.+)|$)/) do |m|
        @setting_list[name][regular_name(m[0]).to_sym] = m[2] || true
      end
    end
  end
  def regular_name(string)
    string.to_s
    name_list.each {|match| return match[0] if match.include? string}
    return string
  end
  def name_list
  [
    %w[Info 信息窗口 信息窗 信息 窗口],
    %w[Command 选择窗口 选择窗 选择],
    %w[Scene 界面 场景 SCENE scene],
    %w[Pic 图片],

    %w[X X坐标 x],
    %w[Y Y坐标 y],
    %w[Width WIDTH width 宽度 宽],
    %w[Height HEIGHT height 高度 高],
    %w[Opacity 透明 背景透明 无背景 透明度 opacity OPACITY],
    %w[Hide 隐藏 关闭 不可见],
    %w[Skin 皮肤],
    %w[FontColor 字体颜色],
    %w[FontSize 字体大小 字号],
    %w[FontName 字体 字体名称],
    %w[FontBold 改变加粗],
    %w[FontItalic 改变倾斜],

    %w[CancelAble 禁止取消 禁止退出 无法退出],
    %w[OkAble 禁止确认 无法确认],
    %w[Horz 横向光标 横向按键 横向],
    %w[Select 默认选择 选择],
    %w[AutoUpdate 自动更新 自动选择],
    %w[NoUpdate 初次例外],

    %w[Background 背景],
  ]
  end
end

end # module M5CES20141001
module M5CES20141001
#--------------------------------------------------------------------------
# ● Screen & Picture
#--------------------------------------------------------------------------
class Game_NewScreen < Game_Screen
  def initialize
    super
    @pictures = Game_NewPictures.new
  end
end
class Game_NewPicture < Game_Picture
end
class Game_NewPictures < Game_Pictures
  def [](number)
    @data[number] ||= Game_NewPicture.new(number)
  end
end
class Sprite_NewPicture < Sprite_Picture
end

end # module M5CES20141001
module M5CES20141001
#--------------------------------------------------------------------------
# ● Interpreter
#--------------------------------------------------------------------------
class Interpreter < Game_Interpreter
  def initialize(scene,depth = 0)
    super(depth)
    @scene = scene
  end
  def setup(list, flag = :normal)
    return unless list
    @flag = flag
    super(list, 0)
    update while running?
  end
  def wait(duration)
    return if @flag == :open
    duration.times do
      Graphics.update
      @scene.update_for_wait
    end
  end
  def map_interpreter
    SceneManager.goto(Scene_Map)
    $game_map.interpreter.setup(@list[@index, @list.length])
  end
  def screen
    @scene.screen
  end
  def wait_for_message;end
  def command_204
    type,value,speed = @params[0], @params[1], @params[2]
    background = @scene.background_plane
    case type
    when 4,6 then background.set_x((type - 5) * value, speed)
    when 2,8 then background.set_y((5 - type) / 3 * value, speed)
    end
  end
  def command_105
    window = @scene.info_windows[@params[0]-1]
    return unless window
    message = ""
    while next_event_code == 405
      @index += 1
      message += @list[@index].parameters[0]
      message += "\n"
    end
    window.refresh message
  end
  def command_101
  end
  def command_355
    script = @list[@index].parameters[0] + "\n"
    while next_event_code == 655
      @index += 1
      script += @list[@index].parameters[0] + "\n"
    end
    @scene.eval_code(script)
  end
  alias m5_20150202_command_244 command_244
  def command_244
    return m5_20150202_command_244 unless @flag == :end
    @scene.bgm.play
    @scene.bgs.play
  end
  def command_117
    common_event = $data_common_events[@params[0]]
    if common_event
      child = Interpreter.new(@scene, @depth + 1)
      child.setup(common_event.list, 0)
      child.run
    end
  end
  [201,205,212,213,217].each do |m|
    define_method "command_#{m}".to_sym do
      map_interpreter
    end
  end
end

end # module M5CES20141001
module M5CES20141001
#--------------------------------------------------------------------------
# ● Plane_Background
#--------------------------------------------------------------------------
class Plane_Background < Plane
  def initialize
    super
    @x = @y = @update_x = @update_y = 0
  end
  def update
    return unless self.bitmap
    @x += @update_x
    @y += @update_y
    self.ox, self.oy = @x, @y
  end
  def set_x(x, speed)
    @x = self.ox
    @update_x = move_speed(x, speed)
  end
  def set_y(y, speed)
    @y = self.oy
    @update_y = move_speed(y, speed)
  end
  def move_speed(value,speed)
    value * case speed
            when 1 then 0.125 ; when 2 then 0.25
            when 3 then 0.5   ; when 4 then 1.0
            when 5 then 2.0   ; when 6 then 4.0
            end
  end
  def dispose
    self.bitmap.dispose if self.bitmap
    super
  end
end

end # module M5CES20141001
module M5CES20141001
#--------------------------------------------------------------------------
# ● Window_Content
#--------------------------------------------------------------------------
class Window_Content < Window_Base
  include Window_Method
  def initialize(setting_main,setting,index)
    super(0, 0, 1, 1)
    @setting = setting_main || {}
    @setting = @setting.clone
    @setting.merge!(setting)
    set_window(@setting)
    reset_font_settings
  end
  def refresh(text = "")
    contents.clear
    draw_text_ex(4, 0, text)
  end
  def window_height
    0
  end
  def window_width
    0
  end
  def normal_color
    text_color(c2number(@setting[:FontColor],0))
  end
  def reset_font_settings
    change_color(normal_color)
    contents.font.name = @setting[:FontName] || Font.default_name
    contents.font.size = c2number(@setting[:FontSize],Font.default_size)
    contents.font.bold = Font.default_bold
    contents.font.italic = Font.default_italic
    contents.font.bold = !contents.font.bold if @setting[:FontBold]
    contents.font.italic = !contents.font.italic if @setting[:FontItalic]
  end
end

end # module M5CES20141001
module M5CES20141001
#--------------------------------------------------------------------------
# ● Window_NewCommand
#--------------------------------------------------------------------------
class Window_NewCommand < Window_Command
  include Window_Method
  def initialize(setting,command,scene)
    @scene = scene
    @command = M5CES20141001::Load.new.setup2(command)
    @setting = setting || {}
    @index = -1
    super(0, 0)
    set_window(@setting)
    refresh
    @load_over = true unless @setting[:NoUpdate]
    @index = -1
    load_setting
    @load_over = true
  end
  def window_height
    [super,Graphics.height].min
  end
  def make_command_list
    @command.each do |command|
      add_command(command[0], :nil, true)
    end
  end
  def load_setting
    self.arrows_visible = false if @setting[:Horz]
    if @setting[:Select]
      select(@setting[:Select].to_i - 1)
    else
      select(0)
    end
  end
  def select(index)
    return if @index == index
    super(index)
    return unless @load_over
    return unless @command[@index]
    @scene.interpre.setup(@command[@index][2])
    @scene.interpre.setup(@command[@index][1]) if @setting[:AutoUpdate]
  end
  def process_ok
    return unless @command[@index]
    @scene.interpre.setup(@command[@index][1])
    activate
  end
  def process_cancel
    SceneManager.return
  end
  def ok_enabled?
    !@setting[:OkAble]
  end
  def cancel_enabled?
    !@setting[:CancelAble]
  end
  alias m5_ces_cursor_down1 cursor_down
  def cursor_down *arg
    return if @setting[:Horz]
    m5_ces_cursor_down1 *arg
  end
  alias m5_ces_cursor_up1 cursor_up
  def cursor_up *arg
    return if @setting[:Horz]
    m5_ces_cursor_up1 *arg
  end
  def cursor_right *arg
    return unless @setting[:Horz]
    m5_ces_cursor_down1 *arg
  end
  def cursor_left *arg
    return unless @setting[:Horz]
    m5_ces_cursor_up1 *arg
  end
end

end # module M5CES20141001
module M5CES20141001
#--------------------------------------------------------------------------
# ● Scene_M5CES20141001
#--------------------------------------------------------------------------
class Scene < Scene_Base
  attr_reader :ev,:bgm,:bgs
  attr_reader :interpre
  attr_reader :info_windows,:command_window
  attr_reader :picture_sprites,:background_plane,:screen
  def prepare(id,bgm = nil,bgs = nil)
    @ev = id
    @bgm = bgm
    @bgs = bgs
  end
  def start
    super
    @bgm ||= RPG::BGM.last
    @bgs ||= RPG::BGS.last
    load_events(@ev)
    @interpre = Interpreter.new(self)
    create_background
    creat_sprites
    creat_windows
    @interpre.setup(@open,:open)
    creat_command
    update
  end
  def post_start
    super
    @interpre.setup(@after_open)
    update
  end
  def load_events(id)
    ev = $data_common_events[id]
    raise "公共事件读取失败！" unless ev
    ev_list = ev.list.clone
    load = Load.new
    @open, @after_open, @command, @input, @end, @setting = load.setup(ev_list)
    @setting[:Scene] ||= {}
  end
  def creat_windows
    @setting[:Info2] ||= {}
    @info_windows = Array.new(8) do |i|
      set = @setting[ ("Info#{i+1}").to_sym ]
      set ? Window_Content.new(@setting[:Info], set, i) : nil
    end
  end
  def creat_command
    @command_window = Window_NewCommand.new(@setting[:Command], @command, self)
  end
  def creat_sprites
    @picture_sprites = []
    @background_plane = Plane_Background.new
    if name = @setting[:Scene][:Background]
      @background_plane.bitmap = Cache.picture(name)
    end
    @screen = Game_NewScreen.new
  end
  def create_background
    @background_sprite = Sprite.new
    @background_sprite.bitmap = SceneManager.background_bitmap
    @background_sprite.color.set(16, 16, 16, 128)
  end
  def update_for_wait
    update_graphics
    Graphics.update
  end
  def update
    super
    update_graphics
    update_input
  end
  def update_graphics
    @background_plane.update
    @screen.update
    @screen.pictures.each do |pic|
      @picture_sprites[pic.number] ||= Sprite_NewPicture.new(nil, pic)
      @picture_sprites[pic.number].update
    end
  end
  def update_input
    @input.keys.each do |key|
      @interpre.setup(@input[key]) if Input.trigger?(key)
    end
  end
  def terminate
    @interpre.setup(@end,:end)
    super
    dispose_scene_windows
    dispose_scene_sprites
  end
  def dispose_scene_windows
    @info_windows.each {|win| win.dispose if win }
  end
  def dispose_scene_sprites
    @screen.clear
    @background_plane.dispose
    @background_sprite.dispose
    @picture_sprites.compact!
    @picture_sprites.each do |pic|
      pic.bitmap.dispose if pic.bitmap
      pic.dispose
    end
  end
  def eval_code(code); eval code; end
  def 退出界面; SceneManager.return; end
  def 刷新界面; M5CES20141001.refresh; end
  def 切换界面(id); M5CES20141001.jump(id); end
  def 打开界面(id); M5CES20141001.call(id); end
end
end # module M5CES20141001
#--------------------------------------------------------------------------
# ● Window_MenuCommand
#--------------------------------------------------------------------------
class Window_MenuCommand
  alias m5_20141001_add_formation_command add_formation_command
  def add_formation_command
    m5_20141001_add_formation_command
    M5CES20141001::MENU.each_with_index do |set|
      add_command(set[0],"m5_ces20141001_#{set[1]}".to_sym)
    end
  end
  alias m5_20141001_handle? handle?
  def handle?(symbol)
    if /m5_ces20141001_\S+/ =~ symbol.to_s
      return true
    else
      return m5_20141001_handle?(symbol)
    end
  end
  alias m5_20141001_call_handler call_handler
  def call_handler(symbol)
    id = /m5_ces20141001_(\S+)/ =~ symbol.to_s ? $1.to_i : nil
    return m5_20141001_call_handler(symbol) unless id
    M5CES20141001.call(id)
  end
end
#--------------------------------------------------------------------------
# ● Scene_Map
#--------------------------------------------------------------------------
class Scene_Map
  alias m5_20150226_call_menu call_menu
  def call_menu
    var = $game_variables[ M5CES20141001::VAR ]
    if var > 0
      M5CES20141001.call(var)
    else
      m5_20150226_call_menu
    end
  end
end