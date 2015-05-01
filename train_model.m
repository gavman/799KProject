function [ features ] = train_model( im, pos, consts )
%% Train the model used to identify characters

%% Do thresholding, turn positions into bounding boxes
bbs = [pos(:,1) pos(:,3), pos(:,2)-pos(:,1), pos(:,4)-pos(:,3)];

%% Debug -- show output
if (consts.debug)
    figure;
    imshow(im);
    hold on;
    for i = 1:size(bbs, 1)
        rectangle('Position', bbs(i,:));
    end
end

%% Get hog features for all chars
features = [];
for i = 1:size(bbs, 1)
    char = imcrop(im, bbs(i,:));
    char = imresize(char, [consts.rows, consts.cols]);
    [feature, ~] = extractHOGFeatures(char);
    features = [features feature'];
end

end

