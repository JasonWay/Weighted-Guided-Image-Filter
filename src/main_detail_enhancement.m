%% WGIF full detail enhancement

% I = imread('.\img\tulips.bmp');
%I = imread('.\img\bird.jpg');
I = imread('.\img\sky.jpg');
% Ig = rgb2gray(I);
X = double(I)/255;

r = 16;
lambda = 1/128;
theta = 4;

Z = zeros(size(X));
Z(:,:,1) = WeightedGuidedImageFilter(X(:,:,1), X(:,:,1), r, lambda);
Z(:,:,2) = WeightedGuidedImageFilter(X(:,:,2), X(:,:,2), r, lambda);
Z(:,:,3) = WeightedGuidedImageFilter(X(:,:,3), X(:,:,3), r, lambda);

X_enhanced = (X-Z)*theta + Z;

% figure('Name', 'img in');
% imshow(X);
figure('Name', 'WGIF detail enhancement');
% imshow([X,(X-Z)*2+Z, (X-Z)*4+Z, (X-Z)*8+Z]);
imshow([X, Z, X_enhanced]);


%% WGIF selective detail enhancement

% I = imread('.\img\tulips.bmp');
% I = imread('.\img\sky.jpg');
I = imread('.\img\bird.jpg');
% Ig = rgb2gray(I);
X = double(I)/255;

r = 16;
lambda = 1/128;

[hei, wid, ~] = size(X);
r2 = floor(min(hei, wid) / 3);

Z = zeros(size(X));
gamma0 = zeros(size(X));
gamma = zeros(size(X));
for a = 1:3
    gamma0(:,:,a) = EdgeAwareWeighting(X(:,:,a));
    gamma1 = gamma0(:,:,a) / max(max(gamma0(:,:,a)));     % ��һ��
    gamma_bw = AdaptiveThreshold(gamma1, r2, 4);         % �ֲ�����Ӧ��ֵ��
    gamma(:,:,a) = gamma1 .* ~gamma_bw + gamma_bw;
    Z(:,:,a) = WGIF_(X(:,:,a), X(:,:,a), r, lambda, gamma0(:,:,a));     % ͼ��ƽ��
end

X_detail = X - Z;
X_enhanced = X_detail * 4 + X;              % full enhancement
X_enhanced2 = X_detail .* gamma * 4 + X;    % selective enhancement

% figure('Name', 'in --- WGIF_out');
% imshow([X,Z]);
figure('Name', 'in --- full --- selective');
imshow([X,X_enhanced, X_enhanced2]); 

%% WGIF selective detail enhancement  gray

% I = imread('.\img\tulips.bmp');
I = imread('.\img\sky.jpg');
Ig = rgb2gray(I);
X = double(Ig)/255;

r = 16;
lambda = 1/128;

gamma0 = EdgeAwareWeighting(X);

Z = WGIF_(X,X,r,lambda, gamma0);

X_detail = X - Z;


% ͨ����ֵ������
[hei, wid] = size(X);
r2 = floor(min(hei, wid) / 3);
gamma1 = gamma0 / max(max(gamma0));
gamma_bw = AdaptiveThreshold(gamma1, r2, 4);
gamma_wb = ~gamma_bw;
gamma2 = gamma1 .* gamma_wb;
gamma3 = gamma2 + gamma_bw;

gamma = gamma3;


% v2, ��һ��
% ֻ����ǿ�ٲ��ֱ�Ե
% gamma = gamma0 / max(max(gamma0));

%{
1. ֻ��gamma���й�һ���� ֻ����ǿ�ٲ��ֱ�Ե
2. ͨ����ֵ1��gamma��ֵ��Ȼ�����壺����Ҳ�ᱻ��ǿ����Ч����ȫ����ǿû����
2.1. ֱ���ö�ֵ�����gamma, 
2.1.1. ����ֵ1��gamma���ж�ֵ����Ч�������룬��ȫ��û����
2.1.2. �þֲ�����Ӧ��ֵ����gamma��ֵ�����е�ϣ����������Щ��������Ҫ��һ������
3. ͨ��ȫ�ֶ�ֵ����gamma�������壺û�Թ�
4. ͨ���ֲ�����Ӧ��ֵ����gamma�������壺ĿǰЧ����ѣ�ֻ��ǿ���ֱ�Ե�� �����в�����ǲ�������Ҳ�ᱻ��ǿ,
����ͨ�������ֲ�����Ӧ��ֵ���Ĵ��ڰ뾶��������
%}


figure();
subplot(121);   imshow(gamma);     title('gamma');
subplot(122);   imhist(uint8(gamma*255));   title('histgram of gamma');

X_enhanced = X_detail * 4;
X_enhanced2 = X_detail .* gamma * 4;

figure('Name', 'WGIF');
imshow([X,Z]);
figure('Name', 'WGIF selective detail enhancement');
imshow([X_enhanced,X_enhanced2]);