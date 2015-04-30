function [ imBW ] = threshold( im, consts )

%% Do image thresholding
threshold = consts.threshold;
background = uint8(zeros(size(im)));
absolute_difference = abs(rgb2gray(im) - rgb2gray(background));
imBW = (absolute_difference < threshold);
imBW = bwareaopen(imBW, consts.BWAreaOpenVal);

end

