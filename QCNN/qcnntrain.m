function net = qcnntrain(net, x, y, opts)
%% �������ã�ѵ��CNN��
%����������У�ÿ��ѡȡһ��batch��50������������ѵ����
%��ѵ��������50������������ݶȣ����֮��һ���Ը��µ�ģ��Ȩ���С�
% ����ѵ�������е��ã�
% 	gacnnff.m ���ǰ�����
% 	gacnnbp.m ����������ݶȼ���
% 	gacnnapplygrads.m �ɼ���������ݶȼӵ�ԭʼģ����ȥ
    
%% ѵ������
    m = size(x, 3); % mΪͼƬ������������size(x)=��28*28*60000��
    numbatches = m / opts.batchsize; % batchsizeΪ��ѵ��ʱ��һ������ͼƬ��������=60000/50=1200����
    if rem(numbatches, 1) ~= 0
        error('numbatches not integer');
    end
    net.rL = []; % rL����С��������ƽ�����У���ͼҪ�á�
    for i = 1 : opts.numepochs  %����ѵ��
        %��ʾѵ�����ڼ���epoch��һ�����ٸ�epoch
        disp(['epoch ' num2str(i) '/' num2str(opts.numepochs)]);
        tic;
        %randperm(n)������1��n�����������ظ�������У��ɵõ����ظ����������
        %����1��m(ͼƬ����)������������ظ����У����ڴ���ѵ��˳��
        kk = randperm(m);
        for l = 1 : numbatches  %ѵ��ÿһ��batch
            %�õ�ѵ���źţ�һ��������һ��x(:,:,sampleorder)��ÿ��ѵ����ȡ50������
            batch_x = x(:, :, kk((l - 1) * opts.batchsize + 1 : l * opts.batchsize));
            %���ǩ��һ��������Ӧ�ı�ǩΪһ��
            batch_y = y(:,    kk((l - 1) * opts.batchsize + 1 : l * opts.batchsize));
            
            %NN�ź�ǰ�򴫵�����
            net = qcnnff(net, batch_x);
            %���������򴫲��������ݶ�
            net = qcnnbp(net, batch_y);
            %Ӧ���ݶȣ�����ģ�Ͳ���
            net = qcnnapplygrads(net, opts);
            %net.LΪģ�͵�costFunction������С�������mse
            %net.rL����С��������ƽ������
            if isempty(net.rL)
                net.rL(1) = net.L;
            end
            net.rL(end + 1) = net.L;%0.99 * net.rL(end) + 0.01 * net.L;
        end
        toc;
    end
    
end
