function Iout = readAndPreprocessImage(filename, prepro, sizes, graylevel)
% PPType = Pre-processign type: scale, crop, medpool, maxpool, minpool
if nargin == 3
    graylevel = 256;
elseif nargin == 2
    sizes = [227 227];
    graylevel = 256;
elseif nargin == 1
    prepro = 'map';
    sizes = [227 227];
    graylevel = 256;
end

I = imread(filename);

if ~contains(prepro,'none')
    if strcmp(prepro, 'u8')
        I = uint8(I);
    elseif strcmp(prepro, 'imu8')
        I = im2uint8(I);
    elseif strcmp(prepro, 'immatu8')
        I = im2uint8(mat2gray(I));
    elseif strcmp(prepro, 'u8+s')
        I = imadjust(uint8(I));
    elseif strcmp(prepro, 'imu8+s')
        I = imadjust(im2uint8(I));
    elseif strcmp(prepro, 'imu8+s')
        I = imadjust(im2uint8(mat2gray(I)));
    elseif strcmp(prepro, 'map')==1
        I = I + abs(min(I(:)));
        I = (I / (max(I(:))/256));
        I = uint8(I);
    end
end

if graylevel ~= 256
    scale = 256/graylevel;
    I = I/scale;
end

% Some images may be grayscale. Replicate the image 3 times to
% create an RGB image.
if ismatrix(I)
    I = cat(3,I,I,I);
end

% scale the image
Iout = imresize(I, sizes);