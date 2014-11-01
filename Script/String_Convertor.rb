#==============================================================================
# ■ String
#------------------------------------------------------------------------------
# 　为字符串追加编码转换的机能。
#   [Source] http://rm.66rpg.com/thread-367933-1-1.html
#==============================================================================
# 参考：
# http://msdn.microsoft.com/en-us/library/windows/desktop/dd319072(v=vs.85).aspx
# http://msdn.microsoft.com/en-us/library/windows/desktop/dd374130(v=vs.85).aspx
# http://msdn.microsoft.com/en-us/library/windows/desktop/dd317756(v=vs.85).aspx
#==============================================================================

class String
  #--------------------------------------------------------------------------
  # ● 常量定义
  #--------------------------------------------------------------------------
  MultiByteToWideChar = Win32API.new('kernel32', 'MultiByteToWideChar', 'ilpipi', 'i')
  WideCharToMultiByte = Win32API.new('kernel32', 'WideCharToMultiByte', 'ilpipipp', 'i')
  Codepages = {
    :System => 0,     :UTF7   => 65000, :UTF8   => 65001,
    :S_JIS  => 932,   :GB2312 => 936,   :BIG5   => 950, 
  }
  #--------------------------------------------------------------------------
  # ● 伪 iconv 编码转换
  #--------------------------------------------------------------------------
  #     s : 原始编码，可使用 Codepages 中的符号或者直接使用代码页值。
  #     d : 目标编码，同上。
  #--------------------------------------------------------------------------
  def iconv s, d
    src  = s.is_a?(Symbol)? Codepages[s] : s
    dest = d.is_a?(Symbol)? Codepages[d] : d
 
    len = MultiByteToWideChar.call src, 0, self, -1, nil, 0
    buf = "\0" * (len * 2)
    MultiByteToWideChar.call src, 0, self, -1, buf, buf.size / 2
 
    len = WideCharToMultiByte.call dest, 0, buf, -1, nil, 0, nil, nil
    ret = "\0" * len
    WideCharToMultiByte.call dest, 0, buf, -1, ret, ret.size, nil, nil
 
    self.respond_to?(:force_encoding) ?
    ret.force_encoding("ASCII-8BIT").delete("\000") :
    ret.delete("\000")
  end
  #--------------------------------------------------------------------------
  # ● 快捷方式：从 ANSI 转为 UTF-8 编码
  #--------------------------------------------------------------------------
  def s2u
    self.respond_to?(:force_encoding) ?
    iconv(:System, :UTF8).force_encoding("utf-8") :
    iconv(:System, :UTF8)
  end
  #--------------------------------------------------------------------------
  # ● 快捷方式：从 UTF-8 转为 ANSI 编码
  #--------------------------------------------------------------------------
  def u2s
    iconv(:UTF8, :System)
  end
end
