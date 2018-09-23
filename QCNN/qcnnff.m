function net = qcnnff(net, x)
    %% ȡ��GACNN������
    n = numel(net.layers);
    net.layers{1}.a{1} = x; % a������map����һ��28*28*50�� clifford����
    inputmaps = 1;
    
    %% ���ξ���ͽ���������
    for l = 2 : n   %  for each layer
        if strcmp(net.layers{l}.type, 'c')
            %  !!below can probably be handled by insane matrix operations
            for j = 1 : net.layers{l}.outputmaps   %  for each output map
                %  create temp output map
                %  z=zeros([28,28,50]-[4,4,0])=seros([24,24,50]);
                z = zerosq(size(net.layers{l - 1}.a{1}) - [net.layers{l}.kernelsize - 1 net.layers{l}.kernelsize - 1 0]);
                for i = 1 : inputmaps   %  for each input map
                    %  convolve with corresponding kernel and add to temp output map
                    z = z + convnq(net.layers{l - 1}.a{i}, net.layers{l}.k{i}{j}, 'valid');
                end
                %  add bias, pass through nonlinearity
                [z1, z2, z3] = size(z);
                bias = repmat(net.layers{l}.b{j},z1,z2,z3);
                net.layers{l}.a{j} = sigm(z + bias);
            end
            %  set number of input maps to this layers number of outputmaps
            inputmaps = net.layers{l}.outputmaps;
        elseif strcmp(net.layers{l}.type, 's')
            %  downsample
            for j = 1 : inputmaps
                % ���һ��[0.25,0.25;0.25,0.25]�ľ���ˣ�Ȼ�󽵲���  ?????�����ظ�����
                z = convnq(net.layers{l - 1}.a{j}, ones(net.layers{l}.scale) ./ (net.layers{l}.scale ^ 2), 'valid');   %  !! replace with variable
                %����scaleΪ����������������ƫ����=scale   ?????���м����˷�
                net.layers{l}.a{j} = z(1 : net.layers{l}.scale : end, 1 : net.layers{l}.scale : end, :);
            end
        end
    end
    
    %% �����֪�������ݴ�����Ҫ��subFeatureMap2���ӳ�Ϊһ��(4*4)*12=192��������
       %�����ڲ�����50������ѵ���ķ�����subFeatureMap2��ƴ�Ӻϳ�Ϊһ��192*50����������fv��
       %fv��Ϊ�����֪�������룬��ȫ���ӵķ�ʽ���ӵ�����㡣
    %  concatenate all end layer feature maps into vector
    net.fv = [];
    for j = 1 : numel(net.layers{n}.a) %fvÿ��ƴ����subFeatureMap2[j]��[����50������]
        sa = size(net.layers{n}.a{j}); % size(a)=[4,4,50]���õ�Sfm2��һ������ͼ�Ĵ�С
        %reshape(A,m,n)���Ѿ���A��Ϊm��n�еľ���Ԫ�ظ������䣬ԭ�������ų�һ�ӣ��ٰ����ų����ɶӣ�
        %��net.layers{numLayers}.a{j}(һ��Sfm2)���г�[4*4�У�1��]��������
        %������Sfm2ƴ�ϳ�Ϊһ��������fv��[net.layers{numLayers}.a{j},4*4,50]
        %����fv��һ��[(16*12)*50=192*50]�ľ���
        net.fv = [net.fv; reshape(net.layers{n}.a{j}, sa(1) * sa(2), sa(3))];
    end
    %  feedforward into output perceptrons
    %net.ffW��һ��[10,192]��Ȩ�ؾ���
    %net.ffW * net.fv��һ��[10,50]�ľ���
    %remat(net.ffb,1,size(net.fv,2))��bias���Ƴ�50���ſ�
    col = size(net.fv,2);   % page
%     net.o = sigm(net.ffW * net.fv + repmat(net.ffb, 1, col));%%Ȩ�����
    net.o = sigm( ((net.fv')*(net.ffW'))' + repmat(net.ffb, 1, col));%%Ȩ�����

end
