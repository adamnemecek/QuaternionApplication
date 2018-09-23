function net = qcnnapplygrads(net, opts)
    %% �������ã������������
    %������ȡ�㣨�������������Ȩ�ظ���
    for l = 2 : numel(net.layers)  %�ӵ�2�㿪ʼ
        if strcmp(net.layers{l}.type, 'c') %����ÿ�������
            for j = 1 : numel(net.layers{l}.a) %ö�ٸò��ÿ�����
                %ö�����о���� net.layers{l}.k{ii}{j}
                for ii = 1 : numel(net.layers{l - 1}.a) %ö���ϲ��ÿ������
                    net.layers{l}.k{ii}{j} = net.layers{l}.k{ii}{j} - opts.alpha * net.layers{l}.dk{ii}{j};
                end
                %�޸�bias
                net.layers{l}.b{j} = net.layers{l}.b{j} - opts.alpha * net.layers{l}.db{j};
            end
        end
    end
    
    %�����֪���Ĳ�������
    net.ffW = net.ffW - opts.alpha * net.dffW;
    net.ffb = net.ffb - opts.alpha * net.dffb;
end
