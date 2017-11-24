% exposure fusion
addpath('exposure_fusion');
I = load_images('.\img\house');
[hei, wid, channels, num] = size(I);

%%

I_gray = zeros(hei, wid, num);
var_I = zeros(hei, wid, num);      % local variance in log domain
omega = zeros(hei, wid, num);
for n = 1:num
    I_gray(:,:,n) = rgb2gray(I(:,:,:,n));
    %var_I(:,:,n) = GetLocalVariance(log(I_gray(:,:,n)), 1);     % �ֲ�����ļ������л����NaN ������ log �ڸ��
    var_I(:,:,n) = GetLocalVariance(I_gray(:,:,n), 1); 
    omega(:,:,n) = 77/255*FuncGamma(I(:,:,1,n)) + 150/255*FuncGamma(I(:,:,2,n)) + 29/255*FuncGamma(I(:,:,3,n));
end

% Eqn(32), overall local variance
sigma = sum(omega.*(var_I+0.001), 3) ./ (sum(omega, 3)+10e-13);

% Eqn(34)
Gamma = sum(sum(1./sigma/ hei / wid)) * sigma;

% fine details
Lk = zeros(hei, wid, num);
for n2 = 1:num
%     Lk(:,:,n2) = WGIF_(I_gray(:,:,n2), I_gray(:,:,n2), 16, 1/128, Gamma);
     Lk(:,:,n2) = I_gray(:,:,n2) - WGIF_(I_gray(:,:,n2), I_gray(:,:,n2), 16, 1/4, Gamma);
%    Lk(:,:,n2) = WeightedGuidedImageFilter(Gamma, I_gray(:,:,n2), 16, 1/4);
end

% ���������������wgif�㷨��ÿ��ͼ���л�ȡһ����ϸ�ڣ�Ȼ���ٽ����е�ϸ�ںϲ�
% ����õ������ع�����õ�ͼ��ϸ�ڣ������Щͼ��ϸ�����ϵ��м�ͼ���еõ����յ�ͼ��
L = sum(Lk.*omega, 3)./sum(omega, 3);  % Eqn(35)   

%%
I_int = exposure_fusion(I, [1,1,1]);
chi = 1;
I_out = I_int .* exp(repmat(chi*L, [1,1,3]));
%I_out = I_int .* repmat(chi*L, [1,1,3]);
figure(); imshow(I_out);


