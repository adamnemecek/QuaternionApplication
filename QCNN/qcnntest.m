function [er, bad] = qcnntest(net, x, y)
    %% ��֤������׼ȷ��
    %  feedforward
    net = qcnnff(net, x);
    [~, h] = max(normer(net.o));
    [~, a] = max(normer(y));
    % find(x) Find indices of nonzero elements.
    bad = find(h ~= a); %����Ԥ��������������
    er = numel(bad) / size(y, 2); %���������
    
end
