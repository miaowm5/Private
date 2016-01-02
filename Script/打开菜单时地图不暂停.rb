class Scene_Menu
  alias m5_20150830_start start
  def start
    m5_20150830_start
    @spriteset = Spriteset_Map.new
  end
  alias m5_20150830_update update
  def update
    m5_20150830_update
    $game_map.update(true)
    # $game_player.update
    $game_timer.update
    @spriteset.update
  end
  alias m5_20150830_terminate terminate
  def terminate
    m5_20150830_terminate
    @spriteset.dispose
  end
end