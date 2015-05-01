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

load('data.mat');

%% Train character recognition model
% Load images and hand-calculated ground truth data
im1 = imread(data.train_im_1);
im2 = imread(data.train_im_2);
trainingFeatures = train_model(im1, data.train_pos_1, consts);
trainingFeatures = [trainingFeatures train_model(im2, data.train_pos_2, consts)];
labels = [data.train_labels_1 data.train_labels_2];

% Train a "one vs all" SVM
classifier = fitcecoc(trainingFeatures', labels');

%% Test Character Model
% Images and hand-calculated ground truth data
test_im = imread(data.test_im_1);
confusion = test_model(test_im, data.test_pos_1, data.test_labels_1, classifier, consts);

%% Get the characters from the image
im = imread('images/whiteboard.png');
if (consts.debug)
    figure;
    imshow(im);
end
chars = extractLetters(im, consts);

%% match each char to each training char
charsGuessed = predict_string(chars, classifier, consts);

%% Make into matlab syntax
eqn = format_for_matlab(charsGuessed);

%% Plot
eqn_final = inline(eqn);
x = -10:10;
figure;
plot(x, eqn_final(x));
xlabel('x');
ylabel('y');
title(charsGuessed);