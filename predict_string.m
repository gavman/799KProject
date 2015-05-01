function [ charsGuessed ] = predict_string( chars, classifier, consts )
%PREDICT_STRING Pridict the string based on the characters found

charsGuessed = [];
for i = 1:size(chars, 2)
    char = chars(:,i);
    if (sum(char) == 0) % minuses have all 0s
        charsGuessed = [charsGuessed '-'];
    else
        char = extractHOGFeatures(reshape(char, [consts.rows, consts.cols]));
        charGuessIndex = predict(classifier, char);
        charsGuessed = [charsGuessed consts.chars(charGuessIndex)];
    end
end

if (consts.debug)
    charsGuessed
end


end

