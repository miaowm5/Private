function join_force(f1,f2,theta,varargin)
% 使用 join_force(f1,f2,theta[,style]) 调用该函数
% 参数说明：
% f1 : F1的大小（单位 N）
% f2 : F2的大小（单位 N）
% theta : 两个力的夹角（角度值）
% style : 画图参数的可选字符串，参数可以为以下的一个或多个：
%   "no-pic" : 不画图
%   "no-line" : 不画辅助线
%   "no-text" : 不在图上标出力的大小

pic = true ;
help_line = true ;
help_text = true ;
  % 设置可选参数的默认值
setting=varargin;
while length(setting) > 0,
  value = setting{1};  setting = setting(2:end);
  switch value
    case 'no-pic'
      pic = false;
    case 'no-line'
      help_line = false;
    case 'no-text'
      help_text = false
  end
end
  % 读取用户输入的可选参数

theta = pi * ( theta / 180 );
  % 将角度值转为弧度值
x_offset = f2 * cos(theta); y_offset = f2 * sin(theta);
  % 计算F2在X、Y方向上的分力
x_final = f1 + f2 * cos(theta); y_final = f2 * sin(theta);
  % 利用三角形定则求合力
f = (x_final^2 + y_final^2)^(1/2)
  % 计算合力的大小

if pic

  axis off

  line([0,f1],[0,0],'LineWidth',2,'color','r')
  line([0,x_offset],[0,y_offset],'LineWidth',2,'color','g')
  line([0,x_final],[0,y_final],'LineWidth',2,'color','b')
    % 绘制分力及合力图片

  if help_line
    line([f1,x_final],[0,y_final],'LineWidth',2,'color','b','LineStyle',':')
    line([x_offset,x_final],[y_offset,y_final],'LineWidth',2,'color','b','LineStyle',':')
      % 绘制辅助线
  end

  if help_text
    text(f1,0, ['F1 =',num2str(f1),'N'] );
    text(x_offset,y_offset, ['F2 =',num2str(f2),'N'] );
    text(x_final,y_final, ['F =',num2str(f),'N'] );
      % 描绘注释
  end

end