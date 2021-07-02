function [cnns, cnnNames] = getCNNsFromDescriptorsSets( descriptors_sets )

    cnns = {};
    cnnNames = {};
       
    for i = 1:numel(descriptors_sets)
        
        if contains(descriptors_sets{i},'alex') 
            convnet = alexnet;
            convnet_name = 'alexnet';
        elseif contains(descriptors_sets{i},'VGG16') 
            convnet = vgg16;
            convnet_name = 'vgg16';
        elseif contains(descriptors_sets{i},'VGG19') 
            convnet = vgg19;
            convnet_name = 'vgg19';
        elseif contains(descriptors_sets{i},'google') 
            convnet = googlenet;
            convnet_name = 'googlenet';
        elseif contains(descriptors_sets{i},'resnet50') 
            convnet = resnet50;
            convnet_name = 'resnet50';
        elseif contains(descriptors_sets{i},'resnet18') 
            convnet = resnet18;
            convnet_name = 'resnet18';
        elseif contains(descriptors_sets{i},'resnet101') 
            convnet = resnet101;
            convnet_name = 'resnet101';
        elseif contains(descriptors_sets{i},'inceptionv3') 
            convnet = inceptionv3;
            convnet_name = 'inceptionv3';
        elseif contains(descriptors_sets{i},'shufflenet') 
            convnet = shufflenet;
            convnet_name = 'shufflenet';
        elseif contains(descriptors_sets{i},'squeezenet') 
            convnet = squeezenet;
            convnet_name = 'squeezenet';
        elseif contains(descriptors_sets{i},'mobilenetv2') 
            convnet = mobilenetv2;
            convnet_name = 'mobilenetv2';
        elseif contains(descriptors_sets{i},'densenet201') 
            convnet = densenet201;
            convnet_name = 'densenet201';
        elseif contains(descriptors_sets{i},'xception') 
            convnet = xception;
            convnet_name = 'xception';
        elseif contains(descriptors_sets{i},'nasnetmobile') 
            convnet = nasnetmobile;
            convnet_name = 'nasnetmobile';
        elseif contains(descriptors_sets{i},'nasnetlarge') 
            convnet = nasnetlarge;
            convnet_name = 'nasnetlarge';
        elseif contains(descriptors_sets{i},'darknet19') 
            convnet = darknet19;
            convnet_name = 'darknet19';
        elseif contains(descriptors_sets{i},'darknet53') 
            convnet = darknet53;
            convnet_name = 'darknet53';
        else
            continue;
        end
        
        cnns{end+1} = convnet;
        cnnNames{end+1} = convnet_name;
    end
    
end