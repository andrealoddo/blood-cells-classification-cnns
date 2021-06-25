function [features] = getActivations( CNNArch, computeCNNFeaturesTrained )

    alexnet_fc = 'fc7';
    vgg_fc = 'fc7';
    
    if computeCNNFeaturesTrained == 0
        googlenet_fc = 'loss3-classifier';
        resnet_fc = 'fc1000';
        inceptionv3net_fc = 'predictions';
    elseif computeCNNFeaturesTrained == 1
        googlenet_fc = 'new_fc';
        resnet_fc = 'new_fc';
        inceptionv3net_fc = 'new_fc';
    end    
    
    if contains(CNNArch, 'alexfc7') %%%alexnet Features
        features = activations(convnet, imds, alexnet_fc, 'MiniBatchSize', 32);
    elseif contains(CNNArch,'VGG') %%%VGG CNN Features
        features = activations(convnet, imds, vgg_fc, 'MiniBatchSize', 32);
    elseif contains(CNNArch, 'google') %%%CNN Features
        features = activations(convnet, imds, googlenet_fc, 'MiniBatchSize', 32);
    elseif contains(CNNArch, 'resnet') %%%CNN Features
        features = activations(convnet, imds, resnet_fc, 'MiniBatchSize', 32);
    elseif contains(CNNArch, 'Inception') %%%CNN Features
        features = activations(convnet, imds, inceptionv3net_fc, 'MiniBatchSize', 32);
    end
    
end

