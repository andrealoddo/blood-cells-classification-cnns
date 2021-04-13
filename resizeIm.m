function I = resizeIm(filename, scale)
    
    I = imread( filename );
    I = imresize( I, scale );
    
end

