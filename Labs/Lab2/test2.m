% ----------------------------------------------------------------------- %
% CITS4402 Lab02 Week03                                                   %
% Author: Farshad Ghanbari                                                %
% Student Number: 21334883                                                %
% ----------------------------------------------------------------------- %

% Reset
clc;
clear;
close all;

% Tunable variables
image1 = "bill.png";
image2 = "steve.png";
c_l = 0.15; % lowpass  cut-off
c_h = 0.1;  % highpass cut_off
n = 2;

% Reading original images and resizing to same size
img1 = imread(image1);
img2 = imread(image2);
im1 = imresize(img1, [256, 256]);
im2 = imresize(img2, [256, 256]);

% Converting original images to black and white
g1 = rgb2gray(im1);
g2 = rgb2gray(im2);

% Converting images from spatial domain to frequency (fourier) domain
f1 = fft2(g1);
f2 = fft2(g2);

% Creating filters (low and high pass), specific for image sizes
s1 = size(g1);
s2 = size(g2);
lpass = lowpassfilter(s1, c_l, n);
hpass = highpassfilter(s2, c_h, n);

% Applying filters to images in frequency domain
% by Element wise matrix multiplication
f1_l = f1 .* lpass;
f2_h = f2 .* hpass;

% Converting filtered images to spatial domain for visualization.
g1_l = ifft2(f1_l);
g2_h = ifft2(f2_h);

% Adding filtered images in the frequency domain to create a hybrid
% Converting the hybrid to spatial domain for visualization
h_f = f1_l + f2_h;
hybrid = ifft2(h_f);

% Magnitude spectrum calculations for visualisations
% Alternative Formula => magnitude = log(1 + abs(fftshift(image)));
mag_f1_l = 20 * log10(abs(fftshift(f1_l)));
mag_f2_h = 20 * log10(abs(fftshift(f2_h)));
mag_h_f  = 20 * log10(abs(fftshift(h_f)));

% ----------------------------------------------------------------------- %
%                                  Figures                                %
% ----------------------------------------------------------------------- %

% Figure for Image Processing steps
figure("Name", "Original Image, Frequency Domain, Processed Images");
set(gcf,'OuterPosition',[50 400 1000 1000]);
colormap("gray");

subplot(3, 3, 1);
imagesc(g1);
title("Image 1");
axis equal;
axis off;
subplot(3, 3, 4);
imagesc(g2);
title("Image 2");
axis equal;
axis off;
subplot(3, 3, 2);
imagesc(mag_f1_l);
title("Frequency Spectrum - Smoothed");
axis equal;
axis off;
subplot(3, 3, 5);
imagesc(mag_f2_h);
title("Frequency Spectrum - Sharpened");
axis equal;
axis off;
subplot(3, 3, 3);
imagesc(g1_l);
title("Smoothed");
axis equal;
axis off;
subplot(3, 3, 6);
imagesc(g2_h);
title("Sharpened");
axis equal;
axis off;
subplot(3, 3, 8);
imagesc(mag_h_f);
title("Frequency Spectrum - Hybrid");
axis equal;
axis off;
subplot(3, 3, 9);
imagesc(hybrid);
title("Hybrid");
axis equal;
axis off;

% Figure for Hybrid Image
figure("Name", "Hybrid Image");
set(gcf,'OuterPosition',[1050 400 1000 1000]);
colormap(gray);

imagesc(hybrid);
axis equal;
axis off;