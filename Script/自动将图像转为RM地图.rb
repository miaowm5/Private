
# PNG 保存 (ＣＡＣＡＯ http://cacaosoft.web.fc2.com/)
class Bitmap
  def save_png(filename, alpha = false)
    sgnt = "\x89PNG\r\n\x1a\n"
    ihdr = _chunk('IHDR', [width,height,8,(alpha ? 6 : 2),0,0,0].pack('N2C5'))
    data = []
    height.times do |y|
      data << 0
      width.times do |x|
        color = self.get_pixel(x, y)
        data << color.red << color.green << color.blue
        data << color.alpha if alpha
      end
    end
    idat = _chunk('IDAT', Zlib::Deflate.deflate(data.pack('C*')))
    iend = _chunk('IEND', "")
    File.open(filename, 'wb') do |file|
      file.write(sgnt)
      file.write(ihdr)
      file.write(idat)
      file.write(iend)
    end
  end
private
  def _chunk(name, data)
    return [data.size, name, data, Zlib.crc32(name + data)].pack('NA4A*N')
  end
end

mapid = 3
# 地图 ID

filename = "pic"
# 转换图片文件名

power = 12
# 初始压缩质量（值越大速度越快，生成的图像质量越差）

speed = 1
# 压缩粗糙程度（值越大速度越快，生成的图像质量越差）

tilesetid = 6
# 新地图使用的图块，为0新建图块，否则修改原图块

tilename = ["tileB","tileC","tileD","tileE"]
# 图块素材文件名

def data_reset(map)
  $tilemap = map.data
  $color_list = [Color.new(255,255,255,0)]
end
def add_color(color)
  index = $color_list.index(color)
  return index if index
  $color_list.push color
  return $color_list.size - 1
end
def change_color(red,green,blue,power)
  return Color.new( (red.to_i / power) * power, ( green.to_i / power ) * power,
    ( blue.to_i / power) * power, 255)
end
def get_bitmap_data(map,bitmap,need_change = false,power = 2,speed = 2)
  data_reset(map)
  error = false
  catch :get_data_normal do
    map.width.times do |x|
      map.height.times do |y|
        color = bitmap.get_pixel(x, y)
        if need_change
          color = change_color(color.red, color.green, color.blue, power)
        end
        index = add_color(color)
        if index >= 1024
          p "处理失败，对画质进行压缩后重新开始"
          error = true
          throw :get_data_normal
        end
        $tilemap[x,y,2] = index
        $tilemap[x,y,0],$tilemap[x,y,1],$tilemap[x,y,3] = 2048,0,16
      end
      p "正在处理 #{x} / #{map.width}"
    end
  end #catch
  get_bitmap_data(map, bitmap, true, power + speed, speed ) if error
  msgbox("转换结束，正在生成地图，当前压缩度为#{power}") unless error
end
def save_bitmap_to_file(name)
  tile_bitmap1 = Bitmap.new(512,512)
  tile_bitmap2 = Bitmap.new(512,512)
  tile_bitmap3 = Bitmap.new(512,512)
  tile_bitmap4 = Bitmap.new(512,512)
  $color_list.each_with_index do |color,index|
    tile_id = index / 256
    index = index % 256
    x = index % 8
    y = index / 8
    if index >= 128
      x += 8; y -= 16
    end
    bitmap = [tile_bitmap1,tile_bitmap2,tile_bitmap3,tile_bitmap4]
    bitmap[tile_id].fill_rect(x * 32, y * 32, 32, 32, color)
  end
  tile_bitmap1.save_png("Graphics/Tilesets/#{name[0]}.png", true)
  tile_bitmap2.save_png("Graphics/Tilesets/#{name[1]}.png", true)
  tile_bitmap3.save_png("Graphics/Tilesets/#{name[2]}.png", true)
  tile_bitmap4.save_png("Graphics/Tilesets/#{name[3]}.png", true)
end
map = load_data(sprintf("Data/Map%03d.rvdata2", mapid))
tileset = load_data("Data/Tilesets.rvdata2")
bitmap = Bitmap.new(filename)
get_bitmap_data(map, bitmap, false, power.to_i, speed.to_i)
save_bitmap_to_file(tilename)
if !tileset[tilesetid]
  tilesetid = tileset.size
  tileset[tilesetid] = tileset[1].clone
end
tileset[tilesetid].tileset_names[5, 4] = tilename
map.data = $tilemap
map.tileset_id = tilesetid
save_data(map,sprintf("Data/Map%03d.rvdata2", mapid))
save_data(tileset,"Data/Tilesets.rvdata2")
exit