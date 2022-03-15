% Author: Farshad Ghanbari
% Student Number: 21334883
% Email: 21334883@student.uwa.edu.au

% Reads original rgb images and plots them side by side
obama_rgb  = imread("obama.jpg");
mccain_rgb = imread("mccain.jpg");
figure("Name", "Original Images: Obama & Mccain");
subplot(1,2,1), imshow(obama_rgb),  title("Obama");
subplot(1,2,2), imshow(mccain_rgb), title("mccain");

% Converts rgb images to black and white and plots them side by side
obama_g  = rgb2gray(obama_rgb);
mccain_g = rgb2gray(mccain_rgb);
figure("Name", "Grayscale Images: Obama & Mccain");
subplot(1,2,1), imshow(obama_g),  title("Obama");
subplot(1,2,2), imshow(mccain_g), title("mccain");

% Converts the grayscale images from spatial domain to freqency domain
% using 2D fast fourier transform.
obama_freq  = fft2(obama_g);
mccain_freq = fft2(mccain_g);

[num_rows, num_cols] = size(obama_g);
c_low = 0.3; c_high = 0.1; n = 1;
lpass = lowpassfilter([num_rows, num_cols], c_low, n);
hpass = highpassfilter([num_rows, num_cols], c_high, n);
sm_o_freq = lpass .* obama_freq;
sh_m_freq = hpass .* mccain_freq;

smoothedBarrack = ifft2(sm_o_freq);
sharpenedJohn = ifft2(sh_m_freq);

figure("name", "Comparison of the filtered images");
subplot(1,2,1), imagesc(smoothedBarrack);
title("Low pass filtered image of Obama")
axis equal;
subplot(1,2,2), imagesc(sharpenedJohn);
title("High pass filtered image of McCain")
axis equal;

smoothedBarrackBw = uint8(smoothedBarrack);
sharpenedJohnBw = uint8(sharpenedJohn);

figure("name", "Comparison of the greyscale filtered images");
subplot(1,2,1), imshow(smoothedBarrackBw);
title("Greyscale low pass filtered image of Obama")
axis on;
subplot(1,2,2), imshow(sharpenedJohnBw);
title("Greyscale high pass filtered image of McCain =")
axis on;

% Looks good, compose the two images by adding them in the frequency domain
% converting them back to the spatial domain, and comparing their double
% and integer representations

combinedImgFreq = sm_o_freq + sh_m_freq;

combinedImg = ifft2(combinedImgFreq);

figure("name", "Composed hybrid image");
imagesc(combinedImg);
axis on;

combinedImgBw = uint8(combinedImg);
figure("name", "Composed greyscale hybrid image");
imshow(combinedImgBw);
axis on;

% I don't really want to stand up, so let's resize the image to simulate moving further backwards

scalingRatios = [1.0 0.5 0.25 0.125];
% pre-assign cell array memory to save computation
resizedImages = {
    cell(num_rows, num_cols)
    cell(num_rows, num_cols)
    cell(num_rows, num_cols)
    cell(num_rows, num_cols)
 };
for n = 1:4
    resizedImages{n}  = imresize(combinedImgBw, scalingRatios(n));
end

figure("name", "Hybrid image scaled down to simulate distance");
for i = 1:4
    subplot(2, 2, i), imshow(resizedImages{i});
    title(sprintf("Hybrid image resized to %0.3f of the original size", scalingRatios(i)));
    axis on;
end

