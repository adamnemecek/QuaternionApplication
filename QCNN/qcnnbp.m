function net = qcnnbp(net, y)
    %% �������ã����㲢�����������ݶ�    
    
    %% 
    n = numel(net.layers);
    %   error
    net.e = net.o - y;
    %  loss function
    net.L = 1/2* sum(normer(net.e(:))) / size(net.e, 2);

    %%  backprop deltas ����β����֪�������
    net.od = net.e .* (net.o .* (onesq(size(net.o)) - net.o));   %  output delta��sigmoid�����
%     net.fvd = (net.ffW' * net.od); %Ȩ�����             %  feature vector delta��������������һ���ռ���һ����size=[192,50]
    net.fvd = (net.od' * net.ffW)'; %Ȩ���ҳ�
    %���MLP��ǰһ�㣨������ȡ�����һ�㣩�Ǿ���㣬�������������sigmoid�����Ĵ���error��Ҫ��
    %������ʶ����������в���Ҫ�õ�
    if strcmp(net.layers{n}.type, 'c')         %  only conv layers has sigm function
        %���ھ���㣬���� ����������� ����(net.fv.*(1-net.fv))
%         net.fvd = net.fvd .* (net.fv .* (onesq(size(net.fv)) - net.fv));    %Ȩ�����
        net.fvd = ((onesq(size(net.fv)) - net.fv) .* net.fv) .* net.fvd ;    %Ȩ���ҳ�
    end

    %% �ѵ����֪���������fetureVector�������󣬻ָ�ΪsubFeatureMap��4*4��ά������ʽ
    %  reshape feature vector deltas into output map style
    sa = size(net.layers{n}.a{1}); %size(a{1})=[4*4*50]��һ����a{1}~a{12}��
    fvnum = sa(1) * sa(2); %һ��ͼ�����е���������������4*4
    for j = 1 : numel(net.layers{n}.a) %subFeatureMap2��������1:12
        %net���һ���delta������������delta������ȡһ��featureMap��С��Ȼ�����Ϊһ��featureMap����״
        %��fvd���汣���������������������������cnnff.m������������map���ɵģ���������Ҫ���±��������map����ʽ��
        %net.fvd(((j-1)*fvnum+1),:)��һ��featureMap�����d��
        net.layers{n}.d{j} = reshape(net.fvd(((j - 1) * fvnum + 1) : j * fvnum, :), sa(1), sa(2), sa(3));
        %size(net.layers{numlayers}.d{j})=[4*4*50]
        %size(net.fvd)=[193*50]
    end
    
    
    %% �����������ȡ���磨����������㣩�Ĵ���
        %��������Ǿ���㣬�������Ӻ�һ�㣨�������㣩������������ʵ�������ý������ķ����̣�
        %Ҳ���ǽ������������Ϊ2*2=4�ݡ������������Ǿ���sigmoid����ģ��ӽ���������������
        %���Ҫ����sigmoid�󵼴���
        %��������ǽ������㣬�����Ӻ�һ�㣨����㣩������������ʵ�����þ���ķ�����̣�Ҳ
        %���Ǿ�������������������ת180�ȣ���������
    for l = (n - 1) : -1 : 1
        if strcmp(net.layers{l}.type, 'c')
            % ����Ǿ���㣬������һ�㣨�������㣩���������ôӺ���ǰ��̯�ķ�ʽ�������ϲ������̯2�����ٳ���4
            % �����������ȴ���
            for j = 1 : numel(net.layers{l}.a)
                % net.layers{l}.a{j}.*(1-net.layers{l}.a{j})Ϊsigmoid������
                % expand(,)����ʽչ����ˡ�
                net.layers{l}.d{j} = net.layers{l}.a{j} .* (onesq(size(net.layers{l}.a{j})) - net.layers{l}.a{j}) .* (expand(net.layers{l + 1}.d{j}, [net.layers{l + 1}.scale net.layers{l + 1}.scale 1]) / net.layers{l + 1}.scale ^ 2);
            end
        elseif strcmp(net.layers{l}.type, 's')
            % ����ǽ������㣬����һ�㣨����㣩���������þ���ķ�ʽ�õ���
            for i = 1 : numel(net.layers{l}.a) % ��l�����map������
                z = zeros(size(net.layers{l}.a{1})); % �õ�featuremap��С�������
                for j = 1 : numel(net.layers{l + 1}.a) % ��l+1���ռ����
                    % net.layers{l+1}.d{j} ��һ�㣨����㣩��������
                    % net.layers{l+1}.k{i}{j} ��һ�㣨����㣩�ľ����
                     z = z + convnq(net.layers{l + 1}.d{j}, rot180(net.layers{l + 1}.k{i}{j}), 'full');
                end
                net.layers{l}.d{i} = z;
            end
        end
    end

    %%  calc gradients ����������ȡ��͵����֪�����ݶ�
    % ����������ȡ�㣨���+�����������ݶ�
    for l = 2 : n
        if strcmp(net.layers{l}.type, 'c') % �����
            for j = 1 : numel(net.layers{l}.a) % l��featureMap������
                for i = 1 : numel(net.layers{l - 1}.a) % l-1��featureMap������
                    %����˵��޸���=����ͼ��*���ͼ���delta
                    net.layers{l}.dk{i}{j} = sum(convnq(flipall(net.layers{l - 1}.a{i}), net.layers{l}.d{j}, 'valid'),3) ./ size(net.layers{l}.d{j}, 3);
                end
                % net.layers{l}.d{j](:)��һ��24*24*50�ľ���db������50
                net.layers{l}.db{j} = sum(net.layers{l}.d{j}(:)) / size(net.layers{l}.d{j}, 3);
            end
        end
    end
    % ���㵥���֪�����ݶ�
    % sizeof(net.od)=[10,50]
    %�޸�������ͳ���50(batch��С)
%     net.dffW = net.od * (net.fv)' / size(net.od, 2);    % Ȩ�����
    net.dffW = (net.fv * net.od')' / size(net.od, 2);    % Ȩ���ҳ�
    net.dffb = mean(net.od, 2); %ȡ�ڶ�ά��ֵ

    function X = rot180(X)
        X = flip(flip(X, 1), 2);
    end

    function X=flipall(X)
        for dim=1:ndims(X)
            X = flip(X,dim);
        end
    end
end
