function [ confusion ] = test_model( im, pos, labels, classifier, consts )
%Get the confusion matrix from testing the model with the input data
bbs = [pos(:,1) pos(:,3), pos(:,2)-pos(:,1), pos(:,4)-pos(:,3)];

confusion = zeros(length(consts.chars), length(consts.chars));

for i = 1:size(bbs, 1)
    char = imcrop(im, bbs(i,:));
    char = imresize(char, [consts.rows, consts.cols]);
    feature = extractHOGFeatures(char);
    guess = predict(classifier, feature);
    confusion(labels(i), guess) = confusion(guess, labels(i)) + 1;
end

end

