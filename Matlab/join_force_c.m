clear all;close all;
  % 清理工作空间

% 设置部分

f1 = 6
  % F1的大小（单位 N）

f2 = 8
  % F2的大小（单位 N）

theta = 120
  % 两个力的夹角（角度值）

pic = true ;
  % 是否要作图（true:作图 false:不作图）

help_line = true ;
  % 是否要描绘辅助线（true:描绘辅助线 false:不描绘辅助线）

help_text = true ;
  % 是否要在图上标注每个力的大小（true:标注 false:不标注）

% 代码部分
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