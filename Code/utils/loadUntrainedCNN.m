function convnet = loadUntrainedCNN( CNNArch )
    
    if contains(CNNArch,'alex') %%%alexnet CNN Features
        convnet = alexnet;
        fprintf('loaded alexnet neural network');
    elseif contains(CNNArch,'VGG16') %%%vgg16 CNN Features
        convnet = vgg16;
        fprintf('loaded vgg16 neural network');
    elseif contains(CNNArch,'VGG19') %%%vgg19 CNN Features
        convnet = vgg19;
        fprintf('loaded vgg19 neural network');
    elseif contains(CNNArch,'google') %%%google CNN Features
        convnet = googlenet;
        fprintf('loaded googlenet neural network');
    elseif contains(CNNArch,'resnet50') %%%resnet50 CNN Features
        convnet = resnet50;
        fprintf('loaded resnet50 neural network');
    elseif contains(CNNArch,'resnet18') %%%resnet18 CNN Features
        convnet = resnet18;
        fprintf('loaded resnet18 neural network');
    elseif contains(CNNArch,'resnet101') %%%resnet101 CNN Features
        convnet = resnet101;
        fprintf('loaded resnet101 neural network');
    elseif contains(CNNArch,'inceptionv3') %%%inceptionv3 CNN Features
        convnet = inceptionv3;
        fprintf('loaded inceptionv3 neural network');
    end
    
end

