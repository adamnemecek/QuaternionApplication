function user_api_QCNN



clc
fprintf('\n����������...');
%% ���ݼ������ʽת���Լ���һ������
%{
%ģ�Ͳ��õ����ݿ�ΪMNIST
%����70000 ����д�������������е�6000����Ϊѵ��������10000����Ϊ��������
load mnist_uint8;
train_x = double(reshape(train_x',28,28,60000))/255;
test_x = double(reshape(test_x',28,28,10000))/255;
train_y = double(train_y');
test_y = double(test_y');
%}

%% ʵ��1������ʵ��
%{
%% ������ά��Ԫ������ͼ�Σ�patch1��patch2
rng(0)
patch_size = 32;
num_kind = 3;
patch1 = zerosq(patch_size,patch_size);
patch2 = zerosq(patch_size,patch_size);
patch3 = zerosq(patch_size,patch_size);
for x = 1 : patch_size
    for y = 1 : patch_size
        patch1(x,y) =  quaternion(x*x+y*y,x*x+y*y,x*x+y*y,2*x*x+y*y);
        patch2(x,y) =  quaternion(x*x-y*y,x*x-y*y,x*x-y*y,x*x+2*y*y);
        patch3(x,y) =  quaternion(x*x+y*y,x*x-y*y,x*x+y*y,x*x-y*y);
    end
end

%% ��ǩ��ʶ
outflag = [quaternion(0.1,0.5,0.1,0.5)  quaternion(0.5,0.2,0.1,0.5) quaternion(0.1,0.5,0.2,0.1)]';

%% ѵ�������ǩ+randq(1,1,train_per);
train_per = 500; % ÿһ����ٸ�����
train_x = zerosq(patch_size,patch_size,train_per*num_kind);
train_y = zerosq(num_kind,train_per*num_kind);
for i = 1 : train_per
    train_x(:,:,(i-1)*num_kind+1) = patch1+randq(patch_size,patch_size);
    train_x(:,:,(i-1)*num_kind+2) = patch2+randq(patch_size,patch_size);
    train_x(:,:,(i-1)*num_kind+3) = patch3+randq(patch_size,patch_size);
    train_y(:,(i-1)*num_kind+1) = [outflag(1) 0 0]';
    train_y(:,(i-1)*num_kind+2) = [0 outflag(2) 0]';
    train_y(:,(i-1)*num_kind+3) = [0 0 outflag(3)]';
end

%% ���Լ����ǩ
test_per = 200;
test_x = zerosq(patch_size,patch_size,test_per*num_kind);
test_y = zerosq(num_kind,test_per*num_kind);
for i = 1 : test_per
    test_x(:,:,(i-1)*num_kind+1) = patch1+randq(patch_size,patch_size);
    test_x(:,:,(i-1)*num_kind+2) = patch2+randq(patch_size,patch_size);
    test_x(:,:,(i-1)*num_kind+3) = patch3+randq(patch_size,patch_size);
    test_y(:,(i-1)*num_kind+1) = [outflag(1) 0 0]';
    test_y(:,(i-1)*num_kind+2) = [0 outflag(2) 0]';
    test_y(:,(i-1)*num_kind+3) = [0 0 outflag(2)]';
end
save 'data\data_quaternion_function.mat' 'train_x' -v7.3 'test_x' -v7.3 'train_y' -v7.3 'test_y' -v7.3
%}
load 'data_quaternion_function.mat';%'3D_shape.mat';%
train_x0 =train_x;
train_x=zeros(32,32,4,1500);
train_x(:,:,1,:)=train_x0.w;
train_x(:,:,2,:)=train_x0.x;
train_x(:,:,3,:)=train_x0.y;
train_x(:,:,4,:)=train_x0.z;
train_y=zeros(3,1500);
for i = 1 : 500
    train_y(:,(i-1)*3+1) = [1 0 0]';
    train_y(:,(i-1)*3+2) = [0 1 0]';
    train_y(:,(i-1)*3+3) = [0 0 1]';
end

test_x0 =test_x;
test_x=zeros(32,32,4,600);
test_x(:,:,1,:)=test_x0.w;
test_x(:,:,2,:)=test_x0.x;
test_x(:,:,3,:)=test_x0.y;
test_x(:,:,4,:)=test_x0.z;
test_y=zeros(3,600);
for i = 1 : 200
    test_y(:,(i-1)*3+1) = [1 0 0]';
    test_y(:,(i-1)*3+2) = [0 1 0]';
    test_y(:,(i-1)*3+3) = [0 0 1]';
end
save 'data\quaterniondata_2_realmatrix.mat' 'train_x' -v7.3 'test_x' -v7.3 'train_y' -v7.3 'test_y' -v7.3
% 
% %% ��������ṹ��ѵ������
% % ex1 Train a 6c-2s-12c-2s Convolutional neural network 
% % will run 1 epoch in about 200 second and get around 11% error. 
% % With 100 epochs you'll get around 1.2% error
% 
% rand('state',0)
% 
% qcnn.layers = {
%     struct('type', 'i') %input layer
%     struct('type', 'c', 'outputmaps', 12, 'kernelsize', 5) %convolution layer
%     struct('type', 's', 'scale', 4) %sub sampling layer
% %     struct('type', 'c', 'outputmaps', 12, 'kernelsize', 5) %convolution layer
% %     struct('type', 's', 'scale', 2) %subsampling layer
% };
% 
% % ѵ��ѡ�alphaΪѧϰ���ʣ�ȡֵһ��Ϊ������(0��1]��Χ�ڣ���
% % batchsizeΪ����ѵ����������������numepochesΪ����������
% opts.alpha = 1; %ѧϰ��
% opts.batchsize = 15; %ÿ������һ��batchsize��batch��ѵ����
%                      %Ҳ����ÿ��batchsize�������͵���һ��Ȩֵ��
%                      %�����ǰ����������������ˣ������������������ŵ���һ��Ȩֵ��
% opts.numepochs = 1; %ѵ������
% 
% %% ��ʼ�����磻�����ݽ�����ѵ������֤ģ��׼ȷ��
% qcnn = qcnnsetup(qcnn, train_x, train_y);  %��ʼ������ˡ�ƫ��
% qcnn = qcnntrain(qcnn, train_x, train_y, opts); %ѵ�����磺ǰ�򴫲������򴫲�����������
% [er, bad] = qcnntest(qcnn, test_x, test_y); %���Ե�ǰģ��׼ȷ��
% 
% %% plot mean squared error �����ƾ���������ߣ�
% % err_epoch1 = qcnn.rL;
% % save 'data\err_epoch1_sigm' 'err_epoch1'
% figure(2); plot(qcnn.rL);
% xlabel('QCNN ѵ������');
% ylabel('Train MSE');
% %assert(er<0.12, 'Too big error');
% disp([num2str(er*100),'%error']);
% 
% end
