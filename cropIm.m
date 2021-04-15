function croppedIm = cropIm(I)
       
    nonBlackPixels = any(I ~= 0, 3);
    [maskRows, maskColumns] = find(nonBlackPixels);
    croppedIm = I(min(maskRows):max(maskRows), min(maskColumns):max(maskColumns), :);

end
