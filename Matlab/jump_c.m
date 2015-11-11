clear all;
  % 清理工作空间

% 设置部分

v = 3
  % 运动员的速度

theta = 45
  % 运动员的起跳角

g = 9.8
  % 重力加速度

% 代码部分
theta_back = theta
theta = pi * ( theta / 180 );
  % 将角度值转为弧度值
v_x = v * cos(theta);
  % 速度在水平方向上的分量
v_y = v * sin(theta);
  % 速度在垂直方向上的分量
t = ( v_y / g ) * 2;
  % 停留在空中的时间

s = t * v_x
  % 最终的跳远距离

t = 0:t/10:t;
  % 生成时间向量
x = v_x * t;
  % 生成水平方向位置向量
for(i= 1 : length(t) )
  y(i) = v_y * t(i) - 1/2 * g * t(i)^2;
end
  % 生成垂直方向位置向量
hold on
axis off
  % 保留之前描绘的轨迹
plot(x,y,'LineWidth',2,'LineStyle',':');
  % 描绘跳远过程的轨迹
text(s,0, ['【',num2str(theta_back),'°：',num2str(s),'m】'] ,'BackgroundColor','w','HorizontalAlignment','center');
  % 描绘注释文字
