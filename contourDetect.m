% 特征提取
% f:原始输入图像
% l:标记图像，标记缺陷区域的号码，0表示非缺陷
% features：特征向量
function [pfeature,texturefeatures,shapefeatures]=featureextraction(f,l,lb)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%1 features of pearl region
%%%%%%%%%
%long axis and short axis of pearl
s=diameter(double(lb));
%pearl majority axis
pfeature(1)=((s.MajorAxis(1,1)-s.MajorAxis(2,1)).^2+(s.MajorAxis(1,2)-s.MajorAxis(2,2)).^2).^0.5;
%pearl minority axis
pfeature(2)=((s.MinorAxis(1,1)-s.MinorAxis(2,1)).^2+(s.MinorAxis(1,2)-s.MinorAxis(2,2)).^2).^0.5;
%%%%%%%%
D=regionprops(double(lb),'all');
pfeature(3)=[D.Eccentricity]';%与区域有着相同二阶距的椭圆的偏心率
pfeature(4)=[D.EquivDiameter]';%与区域有着相同面积的圆的直径
pfeature(5)=[D.MajorAxisLength]';%与区域有着相同的二阶距的椭圆的长轴的长度（像素数）
pfeature(6)=[D.MinorAxisLength]';%与区域有着相同的二阶距的椭圆的短轴的长度（像素数）
%%%%%%%%%
%other features
f=uint8(f);
p=imhist(f);
parea=numel(f)-p(1);% pearl area
p=p./parea;
p(1)=0;
L=length(p);
[v,mu]=statmoments(p,3);
%pearl area(normalize to [0 1] by the area of all the image)
pfeature(7)=parea/numel(f);
%average agry level
pfeature(8)=mu(1);
%standard deviation
pfeature(9)=mu(2).^0.5;
%smoothness
varn=mu(2)/(L-1)^2;% normalize variance to [0 1]
pfeature(10)=1-1/(1+varn);
%third moment(normalized by (L-1).^2 also)
pfeature(11)=mu(3)/(L-1)^2;
%Uniformity
pfeature(12)=sum(p.^2);
% Entropy
pfeature(13)=-sum(p.*(log2(p+eps)));
%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%2纹理特征计算of defects
%%%%%%%%%%%
f=double(f);
l=double(l);
lb=double(lb);
[rows,cols]=size(f);
r=max(max(l));%区域个数
M=zeros(r,1);%用于统计均值的数组（数组中每行用来存放一个区域的均值）
K=zeros(r,1);%用于区域面积的数组（数组中每行用来存放一个区域的面积）
P=zeros(r,256);%用于存储每个区域的规一化直方图
N=3;
U=zeros(r,N);%均值的n阶矩统计量
?
%均值&直方图
for i=1:rows
????for j=1:cols
????????if l(i,j)>0
????????????M(l(i,j))=f(i,j)+M(l(i,j)); %区域灰度累加
????????????K(l(i,j))=K(l(i,j))+1;%区域个数累计
                       P(l(i,j),f(i,j)+1)=P(l(i,j),f(i,j)+1)+1;%区域直方图统计
????????end
????end
end
?
M=M./K;%计算均值向量
for i=1:r
????P(i,:)=P(i,:)/K(i,1); %将直方图规一化
end
?
%均值的n阶矩
for i=1:r
????for j=1:N
????????for k=1:256
????????????U(i,j)=U(i,j)+((k-M(i)-1).^j)*P(i,k);
????????end
????end
end
?
%%%%%%
%%%%%%%%%%%%%%%%%%
%特征计算of defects
%(1)均值
mean=zeros(r,1);
for i=1:r
????for j=1:256
?????mean(i)=mean(i)+(j-1)*P(i,j);
????end
end
%(2)标准准偏差standard deviation
sd=zeros(r,1);
for i=1:r
????sd(i)=U(i,2).^0.5;
end
%(3)平滑度 flat degree
fd=zeros(r,1);
for i=1:r
????fd(i)=1-1/(1+U(i,2)/64516);
end
%(4)三阶矩 third moment
tm=zeros(r,1);
for i=1:r
????tm(i)=U(i,3);
end
tm=tm/64516;%规一化
%(5)一致性 consistency
consistency=zeros(r,1);
for i=1:r
????for j=1:256
????????consistency(i)=consistency(i)+P(i,j).^2;
????end
end
%(6)熵entropy
entropy=zeros(r,1);
for i=1:r
????for j=1:256
????????if P(i,j)>0
?????????entropy(i)=entropy(i)+P(i,j)*log2(P(i,j));
????????end
????end
end
entropy=-entropy;
?
texturefeatures=[mean,sd,fd,tm,consistency,entropy];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3区域表述子 of defects
D=regionprops(l,'all');
Area=[D.Area]'./100;%区域内的像素数
V=cat(1,D.BoundingBox);
BBxL=V(:,3);
BByL=V(:,4);
Eccentricity=[D.Eccentricity]';%与区域有着相同二阶距的椭圆的偏心率
EquivDiameter=[D.EquivDiameter]';%与区域有着相同面积的圆的直径
Extent=[D.Extent]';%缺陷最小外接矩形中的缺陷像素的比例
MajorAxisLength=[D.MajorAxisLength]';%与区域有着相同的二阶距的椭圆的长轴的长度（像素数）
MinorAxisLength=[D.MinorAxisLength]';%与区域有着相同的二阶距的椭圆的长轴的长度（像素数）
Orientation=[D.Orientation]';%x轴和与区域有着相同二阶距的椭圆的长轴间的角度
Solidity=[D.Solidity]';%也在区域内的凸壳中的像素的比例
shapefeatures=[Area,BBxL,BByL,Eccentricity,EquivDiameter,Extent,MajorAxisLength,MinorAxisLength,Orientation,Solidity];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%