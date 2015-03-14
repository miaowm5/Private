class TestSprite < Sprite
  include M5Script::M5Animation
  alias m5a m5_animation
  def initialize(index)
    super(nil)
    self.bitmap = Cache.system("2")
    self.x = 3 + index * 70
  end
end
@sprites = Array.new(8){ |i| TestSprite.new(i) }
def init
  @sprites.each{ |s| s.y = 0; s.m5a.stop }
  styles = { :y => 368 }
  time = 120
  @sprites[0].m5a.animate(styles,time,"linner")
  @sprites[1].m5a.animate(styles,time,"bounce")
  @sprites[2].m5a.animate(styles,time,"sinin")
  @sprites[3].m5a.animate(styles,time,"sinout")
  @sprites[4].m5a.animate(styles,time,"sininout")
  @sprites[5].m5a.animate(styles,time,"backin")
  @sprites[6].m5a.animate(styles,time,"backout")
  @sprites[7].m5a.animate(styles,time,"backinout")
end
loop do
  Graphics.update
  Input.update
  init if Input.trigger?(:C)
  @sprites.each(&:update)
end