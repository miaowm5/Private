function friction(varargin)
% 使用 friction(已知量,已知量的值,已知量,已知量的值) 调用该函数
% 已知量说明：
% 'm' : 物体的质量
% 'mu' : 物体与接触面的动摩擦因数
% 'f' : 物体与接触面的动摩擦力
% 'g' : 重力加速度的值，默认为 9.8

m = '?'; mu = '?'; f = '?'; g = 9.8;
  % 设置已知量的默认值
value_amount = 0;
setting = varargin;
while length(setting) > 1
  value_amount = value_amount + 1;
  prop = setting{1};  value = setting{2};  setting = setting(3:end);
  switch prop
    case 'm'
      m = value;
    case 'mu'
      mu = value;
    case 'f'
      f = value;
    case 'g'
      g = value;
      value_amount = value_amount - 1;
    otherwise
      value_amount = value_amount - 1;
  end
end
  % 获取用户输入的已知量
if value_amount < 2;
  error('已知量太少!')
end
  % 当已知量个数过少时报错

if m == '?';
  % 当质量为未知量时
  m = f / ( mu * g );
  disp(['已知物体在某接触面上的动摩擦力大小为',num2str(f),'N，接触面的动摩擦因数为',num2str(mu),...
    '，求物体的质量（g取',num2str(g),'N / kg）']);
  disp(['答：物体的质量为',num2str(m),'kg。']);
elseif f == '?';
  % 当动摩擦力为未知量时
  f = m * g * mu;
  disp(['已知物体的质量为',num2str(m),'kg，接触面的动摩擦因数为',num2str(mu),...
    '，求物体在该接触面上的动摩擦力大小（g取',num2str(g),'N / kg）']);
  disp(['答：物体在该接触面上的动摩擦力为',num2str(f),'N。']);
else mu == '?';
  % 当动摩擦因数为未知量时
  mu = f / ( m * g );
  disp(['已知物体的质量为',num2str(m),'kg，在某接触面的动摩擦力大小为',num2str(f),...
    'N，求该接触面的动摩擦因数（g取 ',num2str(g),' N/kg）']);
  disp(['答：该接触面的动摩擦力因数为',num2str(mu)]);
end

if f < 0 | m < 0 | g < 0 | mu < 0;
  error('给定的已知量数据异常！');
end
  % 当给出的数据出现错误时报错
