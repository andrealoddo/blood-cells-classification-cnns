function trainedNet = loadPretrainedCNN( CNNArch, models )
    
    if contains(CNNArch,'FTalex') %%%alexnet CNN Features
        convnet_ind = find( contains( {models.name}.', 'alex' ) );
        load( fullfile(models(convnet_ind).folder, models(convnet_ind).name ) );
    elseif contains(CNNArch,'FTVGG16') %%%vgg16 CNN Features
        convnet_ind = find( contains( {models.name}.', 'vgg16' ) );
        load( fullfile(models(convnet_ind).folder, models(convnet_ind).name ) );
    elseif contains(CNNArch,'FTVGG19') %%%vgg19 CNN Features
        convnet_ind = find( contains( {models.name}.', 'vgg19' ) );
        load( fullfile(models(convnet_ind).folder, models(convnet_ind).name ) );
    elseif contains(CNNArch,'FTgoogle') %%%google CNN Features
        convnet_ind = find( contains( {models.name}.', 'google' ) );
        load( fullfile(models(convnet_ind).folder, models(convnet_ind).name ) );
    elseif contains(CNNArch,'FTresnet50') %%%resnet50 CNN Features
        convnet_ind = find( contains( {models.name}.', 'resnet50' ) );
        load( fullfile(models(convnet_ind).folder, models(convnet_ind).name ) );
    elseif contains(CNNArch,'FTresnet18') %%%resnet18 CNN Features
        convnet_ind = find( contains( {models.name}.', 'resnet18' ) );
        load( fullfile(models(convnet_ind).folder, models(convnet_ind).name ) );
    elseif contains(CNNArch,'FTresnet101') %%%resnet101 CNN Features
        convnet_ind = find( contains( {models.name}.', 'resnet101' ) );
        load( fullfile(models(convnet_ind).folder, models(convnet_ind).name ) );
    elseif contains(CNNArch,'FTinceptionv3') %%%inceptionv3 CNN Features
        convnet_ind = find( contains( {models.name}.', 'inceptionv3' ) );
        load( fullfile(models(convnet_ind).folder, models(convnet_ind).name ) );
    end
    fprintf('loaded %s neural network\n', models(convnet_ind).name);

    
end

