% Author: Farshad Ghanbari
% Student Number: 21334883
% Email: 21334883@student.uwa.edu.au
% NOTE: After part d, I inverted the image, since erosion and dilation were
% having opposite effects. Please let me know why this might be.

% Part a
% Reads the original truecolor image RGB
RGBImage = imread("lego1.png");
% Displays the original truecolor image RGB
figure("name", "Original Truecolor Image RGB")
imshow(RGBImage);

% Part b
% Converts the truecolor image RGB to grayscale
grayImage = rgb2gray(RGBImage);
% Displays the grayscale image
figure("name", "Grayscale Image")
imshow(grayImage);

% Part c
% Displays the histogram of the image
figure("name", "Histogram of Grayscale Values")
imhist(grayImage);

% Part d
% Converts the grayscale image to binary black and white using the
% threshold
threshold = 175;
% Inverted the black and white image, beause erosion and dilation were
% having opposite effects in my computer. I think it was acting on white
% pixels, so I had to invert.
bwImage = ~(grayImage > threshold);
% Displays the inverted binary black and white image.
figure("name", sprintf("Inverted Black and White Image with %d Threshold", threshold))
imshow(bwImage);

% Part e
% Applys the morphological erosion operation using a 3 pixel square
% structuring element
se = strel("square", 3);
e = imerode(bwImage, se);
% Displays the inverted eroded image
figure("name", "Image After Erosion")
imshow(e);

% Part f
% Applys the morphological dilation operation using a 3 pixel square
% structuring element
d = imdilate(bwImage, se);
% Displays the inverted dilated image
figure("name", "Image After Dilation");
imshow(d);

% Part g
% Performing morphological image processing operations to get the correct
% count of the number of objects. impoen = erosion + dilation
SE = strel('disk', 3);
o = imopen(bwImage, SE);
figure("name", "Image Following the Open Operation");
imshow(o)

% Performs connected component labeling and prints the count of objects
[L, n] = bwlabel(o);
fprintf('There are %d objects in lego1.png\n', n);

% Output in my computer: n = 20

