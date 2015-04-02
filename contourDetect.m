% ������ȡ
% f:ԭʼ����ͼ��
% l:���ͼ�񣬱��ȱ������ĺ��룬0��ʾ��ȱ��
% features����������
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
pfeature(3)=[D.Eccentricity]';%������������ͬ���׾����Բ��ƫ����
pfeature(4)=[D.EquivDiameter]';%������������ͬ�����Բ��ֱ��
pfeature(5)=[D.MajorAxisLength]';%������������ͬ�Ķ��׾����Բ�ĳ���ĳ��ȣ���������
pfeature(6)=[D.MinorAxisLength]';%������������ͬ�Ķ��׾����Բ�Ķ���ĳ��ȣ���������
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
%2������������of defects
%%%%%%%%%%%
f=double(f);
l=double(l);
lb=double(lb);
[rows,cols]=size(f);
r=max(max(l));%�������
M=zeros(r,1);%����ͳ�ƾ�ֵ�����飨������ÿ���������һ������ľ�ֵ��
K=zeros(r,1);%����������������飨������ÿ���������һ������������
P=zeros(r,256);%���ڴ洢ÿ������Ĺ�һ��ֱ��ͼ
N=3;
U=zeros(r,N);%��ֵ��n�׾�ͳ����
?
%��ֵ&ֱ��ͼ
for i=1:rows
????for j=1:cols
????????if l(i,j)>0
????????????M(l(i,j))=f(i,j)+M(l(i,j)); %����Ҷ��ۼ�
????????????K(l(i,j))=K(l(i,j))+1;%��������ۼ�
                       P(l(i,j),f(i,j)+1)=P(l(i,j),f(i,j)+1)+1;%����ֱ��ͼͳ��
????????end
????end
end
?
M=M./K;%�����ֵ����
for i=1:r
????P(i,:)=P(i,:)/K(i,1); %��ֱ��ͼ��һ��
end
?
%��ֵ��n�׾�
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
%��������of defects
%(1)��ֵ
mean=zeros(r,1);
for i=1:r
????for j=1:256
?????mean(i)=mean(i)+(j-1)*P(i,j);
????end
end
%(2)��׼׼ƫ��standard deviation
sd=zeros(r,1);
for i=1:r
????sd(i)=U(i,2).^0.5;
end
%(3)ƽ���� flat degree
fd=zeros(r,1);
for i=1:r
????fd(i)=1-1/(1+U(i,2)/64516);
end
%(4)���׾� third moment
tm=zeros(r,1);
for i=1:r
????tm(i)=U(i,3);
end
tm=tm/64516;%��һ��
%(5)һ���� consistency
consistency=zeros(r,1);
for i=1:r
????for j=1:256
????????consistency(i)=consistency(i)+P(i,j).^2;
????end
end
%(6)��entropy
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
% 3��������� of defects
D=regionprops(l,'all');
Area=[D.Area]'./100;%�����ڵ�������
V=cat(1,D.BoundingBox);
BBxL=V(:,3);
BByL=V(:,4);
Eccentricity=[D.Eccentricity]';%������������ͬ���׾����Բ��ƫ����
EquivDiameter=[D.EquivDiameter]';%������������ͬ�����Բ��ֱ��
Extent=[D.Extent]';%ȱ����С��Ӿ����е�ȱ�����صı���
MajorAxisLength=[D.MajorAxisLength]';%������������ͬ�Ķ��׾����Բ�ĳ���ĳ��ȣ���������
MinorAxisLength=[D.MinorAxisLength]';%������������ͬ�Ķ��׾����Բ�ĳ���ĳ��ȣ���������
Orientation=[D.Orientation]';%x���������������ͬ���׾����Բ�ĳ����ĽǶ�
Solidity=[D.Solidity]';%Ҳ�������ڵ�͹���е����صı���
shapefeatures=[Area,BBxL,BByL,Eccentricity,EquivDiameter,Extent,MajorAxisLength,MinorAxisLength,Orientation,Solidity];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%