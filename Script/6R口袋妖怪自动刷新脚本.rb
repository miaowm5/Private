MATCH = ["red","#ffff00","伊布","妙蛙种子","小火龙","杰尼龟",
         "菊草叶","火球鼠","小锯鳄","木守宫","火稚鸡","水跃鱼",
         "迷你龙",
        ]
MAP_ID = 102
ROUTE = "101道路"


URL = "http://rm.66rpg.com/plugin.php?id=pokemon:pokemon&index=pnc&action=pnc&mapid=#{MAP_ID}"
pokemon = 0
pokemon_list = []
loop do
  url = "#{URL}&actions=refresh"
  file = "6R.txt"
  Win32API.new("Urlmon", "URLDownloadToFile", "ippii", "i").(0, url, file, 0, 0)
  IO.foreach(file) do |line|
    if line.include?("#{ROUTE}遭遇")
      begin
        name = line[/<font>(\S+?)<\/font>/].slice(6,30).chomp("</font>")
        pokemon_list.push(name).uniq!
        p "遇到了第#{pokemon += 1}只宝K梦:#{name}"
      rescue
        p line
      end
      MATCH.each do |key_word|
        next unless key_word
        if line.include?(key_word)
          Win32API.new('shell32.dll','ShellExecuteA','pppppi','i').\
            call(0,'open',URL,0,0,1)
          rgss_stop
        end
      end
    end
  end
  p "#{ROUTE}的PM分布为："
  p pokemon_list
  wait_time = (rand(6) + 6)
  p "等待#{wait_time * 10}帧后刷新遇敌"
  Graphics.wait wait_time * 10
end