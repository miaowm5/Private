function cross_river(water,w_length,boat,theta,varargin)
% 使用 cross_river(water,w_length,boat,theta[,speed]) 调用该函数
% 参数说明：
% water : 水流的速度（单位 m/s）
% w_length : 河的宽度（单位 m）
% boat : 小船的速度（单位 m/s）
% theta : 渡河的角度（角度值）
% speed : 描绘小船渡河动画的速度，可选，默认为 2500

speed = 2500;
  % 设置可选参数的默认值
setting=varargin;
while length(setting) > 0,
  speed = setting{1};  setting = setting(2:end);
end
  % 读取用户输入的可选参数

% 代码部分
while theta > 360
  theta = theta - 360
end
while theta < -360
  theta = theta + 360
end
if theta > 180 | -180 < theta < 0
  error('小船永远无法渡河');
end
  % 判断角度是否符合标准
theta = pi * ( theta / 180 );
  % 将角度值转为弧度值

x_speed = boat * cos(theta);
y_speed = boat * sin(theta);
  % 计算小船在水平、垂直方向上的分速度
x_speed = x_speed + water;
  % 计算小船在水平方向上的合速度

time = w_length / y_speed
  % 计算小船到达河对岸的时间
x_offset = time * x_speed
  % 计算小船到达河对岸时的偏移位置

close all
hold on
ylim([0 w_length*1.2])
  % 设置图像基本参数
line([0,x_offset],[0,0],'LineWidth',4,'color','b')
line([0,x_offset],[w_length,w_length],'LineWidth',4,'color','b')
  % 描绘河流两岸
comet(0:x_offset/speed:x_offset, 0:w_length/speed:w_length)
  % 以动态方式描绘小船的运动轨迹
line([0,x_offset],[0,w_length],'LineWidth',2,'color','r')
line([x_offset,x_offset],[0,w_length],'LineWidth',2,'color','r','LineStyle',':')
  % 描绘小船运动轨迹和辅助线
text(x_offset/2,w_length + w_length/10, ['x =',num2str(x_offset),'m','  time =',num2str(time),'s'] );
  % 描绘注释
