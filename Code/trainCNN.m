function [trainedNet, chart] = trainCNN(net, netName, netCheckPath, modelPath,...
    confPath, AUG, classNumber, imdsTrain, imdsValid, imdsTest, saveCheckPoints)

    % trainCNN          performs training of a CNN and returns the final
    %                   model and the CM
    %   net:            the network to train (ex: alexnet)
    %   netName:        the name of the network (ex: 'alexnet')
    %   netCheckPath:   path for a folder in which the checkpoints will be
    %                   saved (ex: 'models/alexnet')
    %   modelPath:     path for saving the final model
    %   cmPath:         path for saving the confusion matrix
    %   classNumber:    number of classes to predict
    %   imdsTrain:      training set
    %   imdsValid:      validation set
    %   imdsTest:       test set

    if( saveCheckPoints == 1 )
        if( isfolder( netCheckPath ) == 0 )
            mkdir(netCheckPath)
        end
    end

    if( isa( net, 'SeriesNetwork' ) )
        layers = net.Layers;
        layers(end - 2) = fullyConnectedLayer(classNumber);
        layers(end) = classificationLayer();
        netToTrain = layers;
    elseif( isa( net, 'DAGNetwork' ) )
        lgraph = layerGraph(net);
        [learnableLayer, classLayer] = findLayersToReplace(lgraph);
        newLearnableLayer = fullyConnectedLayer(classNumber, ...
            'Name', 'new_fc', ...
            'WeightLearnRateFactor', 10, ...
            'BiasLearnRateFactor', 10);
        newClassLayer = classificationLayer('Name','new_classoutput');
        lgraph = replaceLayer(lgraph, learnableLayer.Name, newLearnableLayer);
        lgraph = replaceLayer(lgraph, classLayer.Name, newClassLayer);
        netToTrain = lgraph;
    else
        fprintf('ERROR: unrecognized network architecture');
    end

    % Preprocess images (resize for network's input requirements)
    inputSize = net.Layers(1).InputSize(:, 1:2);
    imdsTrain.ReadFcn = @(filename)resizeIm(filename, inputSize);
    imdsValid.ReadFcn = @(filename)resizeIm(filename, inputSize);
    imdsTest.ReadFcn  = @(filename)resizeIm(filename, inputSize);

    % Training options
    miniBatchSize = 8;
    maxEpochs = 50;
    valFrequency = max(floor(numel(imdsTest.Files)/miniBatchSize)*10,1);
    
    % Net name
	netName = strcat( netName, '__EP', num2str(maxEpochs), '__MBS', num2str(miniBatchSize), '__AUG', num2str(AUG) );
    if( isfile( fullfile(modelPath, netName) ) == 0 )
        
        if( saveCheckPoints == 0 )
            options = trainingOptions('adam', ...
                'MiniBatchSize', miniBatchSize, ...
                'MaxEpochs', maxEpochs, ...
                'InitialLearnRate', 1e-4, ...
                'LearnRateSchedule', 'piecewise', ...
                'LearnRateDropPeriod', 10, ...
                'LearnRateDropFactor', 0.1, ...
                'L2Regularization', 0.1, ...
                'Shuffle', 'every-epoch', ...
                'ValidationData', imdsValid, ...
                'ValidationFrequency', valFrequency, ...
                'Verbose', true, ...
                'Plots', 'training-progress', ...
                'OutputFcn', @(info)stopIfAccuracyNotImproving( info, 5 ));
        elseif( saveCheckPoints == 1 )
            options = trainingOptions('adam', ...
                'MiniBatchSize', miniBatchSize, ...
                'MaxEpochs', maxEpochs, ...
                'InitialLearnRate', 1e-4, ...
                'LearnRateSchedule', 'piecewise', ...
                'LearnRateDropPeriod', 10, ...
                'LearnRateDropFactor', 0.1, ...
                'L2Regularization', 0.1, ...
                'Shuffle', 'every-epoch', ...
                'ValidationData', imdsValid, ...
                'ValidationFrequency', valFrequency, ...
                'Verbose', true, ...
                'Plots', 'training-progress', ...
                'CheckpointPath', netCheckPath, ...
                'OutputFcn', @(info)stopIfAccuracyNotImproving( info, 5 ));
        end

        % -------------------    TRAIN NETWORK   ------------------------------
        trainedNet = trainNetwork(imdsTrain, netToTrain, options);

        % -------------------    PREDICTIONS   ------------------------------
        preds = classify(trainedNet, imdsTest);
        accuracy = nnz(preds == imdsTest.Labels)/numel(preds);
        sprintf("ACCURACY OF %s: %.2f.", netName, accuracy)

        % -------------------    CONFUSION MATRIX   ---------------------------
        chart = confusionchart(preds, imdsTest.Labels);

        % -------------------    SAVE   ---------------------------
        save(fullfile(modelPath, netName), "trainedNet");
        save(fullfile(confPath, netName), "chart");
    end

end
