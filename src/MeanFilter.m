% ����boxfilter�ľ�ֵ�˲���
function mean = MeanFilter(img, r)
    N = boxfilter(ones(size(img)), r);
    mean = boxfilter(img, r) ./ N;
end