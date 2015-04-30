function [ chars ] = extractLetters( im, consts )
%% Extract the letters from an image assuming to be mostly of a whiteboard.
% The image is assumed to be a color image.

imBW = threshold(im, consts);

%% find the bounding boxes

CC = bwconncomp(imBW);
S = regionprops(CC,'BoundingBox');

%% extract the largest bounding box--this is the whiteboard
largeInd = 0;
largeArea = 0;
for k = 1:length(S)
    thisBB = S(k).BoundingBox;
    area = thisBB(3)*thisBB(4);
    if (area > largeArea)
        largeInd = k;
        largeArea = area;
    end
end

%% further cleanup
whiteboardBW = imcrop(imBW, S(largeInd).BoundingBox);
whiteboard = imcrop(im, S(largeInd).BoundingBox);
CC = bwconncomp(whiteboardBW);
S = regionprops(CC,'BoundingBox');

[h, w] = size(whiteboardBW);
finalBBs = []; % one BB per row
for k = 1:length(S)
  thisBB = S(k).BoundingBox;
  if (thisBB(3)/w < .3 && thisBB(4)/h < .4 ...
    && thisBB(3) > 10)
    finalBBs = [finalBBs; thisBB];
  end
end

%% Get rid of anything whose y is outside two standard deviations -- noise
Ys = finalBBs(:,2);
av = mean(Ys);
stdev = std(Ys);
goodInds = (Ys > av - 2*stdev) & (Ys < av + 2*stdev);
finalBBs = finalBBs(goodInds,:);


%% Combine boxes close together in x dir --> turn two - into an =
Xs = finalBBs(:,1);
prev = Xs(1);
for i = 2:length(Xs)
    this = Xs(i);
    if (this - prev < 5)
        newX = min([this, prev]);
        newY = min([finalBBs(i, 2), finalBBs(i-1, 2)]);
        farRight = max([this + finalBBs(i,3), prev + finalBBs(i-1,3)]);
        newWidth = farRight - newX;
        farDown = max([finalBBs(i,2) + finalBBs(i,4), finalBBs(i-1,2) + finalBBs(i-1,4)]);
        newHeight = farDown - newY;
        newBB = [newX, newY, newWidth, newHeight];
        finalBBs(i,:) = newBB;
        finalBBs(i-1,:) = [];
    end
    prev = this;
end

%% debug show the image with bounding boxes
if consts.debug
    figure;
    imshow(whiteboard);
    hold on;
    for k = 1:size(finalBBs, 1);
        thisBB = finalBBs(k,:);
        rectangle('Position', thisBB);
    end
end

%% crop out letters
chars = [];
for k = 1:size(finalBBs, 1)
    thisBB = finalBBs(k,:);
    % minuses are so small, just recognize them now with all 0s
    if (thisBB(4) < 15)
        charCrop = zeros(consts.rows*consts.cols, 1);
    else
        charCrop = imcrop(whiteboardBW, thisBB);
        charCrop = imresize(charCrop, [consts.rows, consts.cols]);
        charCrop = reshape(charCrop, [consts.rows*consts.cols, 1]);
    end
    chars = [chars charCrop];
end

end

