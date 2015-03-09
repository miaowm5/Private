#==============================================================================
# ■ 多个IconSet合并成一个
#------------------------------------------------------------------------------
#
#   插入脚本，图片扔到游戏目录下的ICO文件夹中，文件名用英文或者数字，
#   运行游戏，之后游戏目录下会生成合并好的文件
#
#==============================================================================

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
def conv_2_24(num)
  loop do
    break if num % 24 == 0
    num += 1
  end
  return num
end
path = "ICO"
bitmap_list = []
Dir.foreach(path) do |file|
  filename = path + "/" + file
  if FileTest.file?(filename)
    bitmap_list << Bitmap.new(filename)
  end
end
height = 0
bitmap_list.each {|bitmap| height += bitmap.height }
height = conv_2_24(height)
final_file = Bitmap.new(384,height)
pos = 0
bitmap_list.each do |bitmap|
  pos = conv_2_24(pos)
  rect = Rect.new(0,0,bitmap.width,bitmap.height)
  final_file.blt(0, pos, bitmap, rect)
  pos += bitmap.height
end
final_file.save_png("IconSet.png", true)
exit