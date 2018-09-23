function net = qcnnsetup(net, x, y)
%% �������ã���ʼ��GACNN�Ĳ����������ø���mapsize�Ĵ�С��__����˵���ο�ʵ��CNN
%                                ��ʼ�������ľ���ˡ�ƫ�ã�
%                                ����β�������֪���Ĳ�������
% �������ã�
% ƫ�ã�bias����һ��ͳһ����Ϊ0��
% Ȩ�����ã�����[-1,1]֮��������/sqrt(6/(������Ԫ����+�����Ԫ����)��
% �����Ȩ�أ����롢���Ϊfan_in��fan_out��
% ����˳�ʼ����C1����1*6������ˣ�C3����6*12=72������ˡ�
%   fan_in=numInputmaps * net.layers{1}.kernelsize^2��
%   fin=1*25  or  6*25      ��fin��ʾ�ò��һ�����map������Ӧ�����о���ˣ���������Ԫ��������1*25��6*25��
%   fan_out=net.layers{1}.outputmaps * net.layers{1}.kernelize^2��
%   fout=1*6*25  or  6*12*25
%   net.layers{1}.k{i]{j}=(randu(net.layers{1}.kernelsize)-0.5*oner(net.layers{1}.kernelsize))*2*sqrt(6/fain_in+fan_out);

%%  �汾���
    assert(~isOctave() || compare_versions(OCTAVE_VERSION, '3.8.0', '>='), ['Octave 3.8.0 or greater is required for CNNs as there is a bug in convolution in previous versions. See http://savannah.gnu.org/bugs/?39314. Your version is ' myOctaveVersion]);   
    
%% ����������Ĳ�����ʼ��    
    inputmaps = 1;  % ����� map
    mapsize = size(x(:, :, 1)); % �����������Ĵ�С
% ����ͨ������net����ṹ������㹹��CNN
    for l = 1 : numel(net.layers)   %  ÿһ��
        if strcmp(net.layers{l}.type, 's')  % �������� or �ػ���
            mapsize = mapsize / net.layers{l}.scale; % ��������С
            assert(all(floor(mapsize)==mapsize), ['Layer ' num2str(l) ' size must be integer. Actual: ' num2str(mapsize)]);
            for j = 1 : inputmaps   % ƫ�ó�ʼ��
                net.layers{l}.b{j} = zeros(mapsize);
            end
        end
        if strcmp(net.layers{l}.type, 'c')  % �����
            mapsize = mapsize - net.layers{l}.kernelsize + 1; % ��������С
            fan_out = net.layers{l}.outputmaps * net.layers{l}.kernelsize ^ 2; % Ȩ�ز��� ���� or ������
            for j = 1 : net.layers{l}.outputmaps  %  ÿһ�����ͨ�� map
                fan_in = inputmaps * net.layers{l}.kernelsize ^ 2;
                for i = 1 : inputmaps  %  ÿһ��������� map
                    net.layers{l}.k{i}{j} = randq(net.layers{l}.kernelsize) * 2 * sqrt(6 / (fan_in + fan_out)); % ��ʼ�������
                end
                net.layers{l}.b{j} = zeros(1); % ƫ�ó�ʼ��
            end
            inputmaps = net.layers{l}.outputmaps;
        end
    end
    
   %% β�������֪����ȫ���ӣ��Ĳ�����Ȩ�غ�ƫ�ã����ã�
    % 'onum' is the number of labels, that's why it is calculated using size(y, 1). If you have 20 labels so the output of the network will be 20 neurons.
    % 'fvnum' is the number of output neurons at the last layer, the layer just before the output layer.
    % 'ffb' is the biases of the output neurons.
    % 'ffW' is the weights between the last layer and the output neurons. Note that the last layer is fully connected to the output layer, that's why the size of the weights is (onum * fvnum)
    fvnum = prod(mapsize) * inputmaps;  %prod():����Ԫ�صĳ˻�(����A(m,n),m>=2,n>=2ʱ���гˣ����Ϊ������)��
    onum = size(y, 1);  %����ڵ������

    net.ffb = zeros(onum, 1);
    net.ffW = randq(onum, fvnum) * 2 * sqrt(6 / (onum + fvnum));
end
