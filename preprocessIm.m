function I = preprocessIm(filename, scale)
    
    I = imread( filename );
    
    % crop image to delete borders and keep only the useful part of the
    % image
    I = cropIm( I );
    % resize image to fit CNN's input layer
    I = imresize( I, scale );
    
end

