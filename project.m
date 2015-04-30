%% 18-799K HW 4
%  Gavriel Ader, gya
%  Spring 2015, Cai, CMU

%% Setup
clear all;
close all;

%% Constants
consts.rows = 128;
consts.cols = 128;
consts.threshold = 100;
consts.BWAreaOpenVal = 50;
consts.chars = ['y', 'x', '^', '+', '=', '1', '2', '3', '4', '5',...
         '6', '7', '8', '9', '0'];
consts.debug = 1;

%% Train character recognition model
% Images and hand-calculated ground truth data
im1 = imread('images/ground_truth.jpg');
pos1 = [359, 403, 108, 202;
       470, 512, 102, 151;
       605, 650, 96, 150;
       815, 892, 90, 150;
       968, 1020, 96, 134;
       347, 363, 265, 335;
       437, 499, 260, 330;
       555, 610, 260, 340;
       660, 705, 255, 340;
       768, 810, 252, 331;
       325, 380, 390, 475;
       430, 490, 392, 477;
       550, 608, 391, 473;
       665, 716, 388, 466;
       759, 831, 373, 453];

im2= imread('images/ground_truth_2.png');
pos2 = [221, 288, 65, 154;
        325, 386, 57, 116;
        450, 513, 58, 117;
        546, 589, 60, 113;
        621, 683, 70, 95;
        226, 239, 204, 280;
        296, 356, 210, 286;
        407, 468, 202, 279;
        512, 562, 194, 280;
        614, 657, 193, 280;
        700, 743, 192, 273;
        791, 840, 186, 268;
        875, 933, 187, 270;
        196, 253, 335, 409;
        295, 365, 337, 397;
        405, 461, 350, 449;
        515, 576, 338, 397;
        621, 666, 318, 380;
        711, 746, 321, 374;
        786, 863, 317, 354;
        218, 234, 475, 546;
        293, 354, 474, 545;
        400, 444, 478, 541;
        493, 535, 466, 548;
        592, 643, 466, 545;
        682, 730, 470, 535;
        774, 837, 472, 549;
        867, 928, 459, 530;
        209, 268, 586, 664;
        305, 386, 588, 655];   
    
trainingFeatures = train_model(im1, pos1, consts);
trainingFeatures = [trainingFeatures train_model(im2, pos2, consts)];

% Train a "one vs all" SVM
labels = repmat(1:15, 1, 3);
classifier = fitcecoc(trainingFeatures', labels');

%% Get the characters from the image
im = imread('images/whiteboard.png');
chars = extractLetters(im, consts);

%% match each char to each training char
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

%% Make into matlab syntax
eqn = charsGuessed;
eqn = eqn(3:end); %get rid of y=
eqn = strrep(eqn, '^', '.^');
eqn = strrep(eqn, '*', '.*');

%% Insert .* between numbers and x
eqn = regexprep(eqn, '([0-9])x', '$1.*x');

%% Plot
eqn = inline(eqn);
x = -10:10;
plot(x, eqn(x));