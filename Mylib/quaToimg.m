function [ I ] = quaToimg( Q )
%UNTITLED6 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
narginchk(0, 1), nargoutchk(0, 1)
[h,w]=size(Q);
I=zeros(h,w,3);
I(:,:,1)=Q.x;
I(:,:,2)=Q.y;
I(:,:,3)=Q.z;
I=uint8(I);
end

