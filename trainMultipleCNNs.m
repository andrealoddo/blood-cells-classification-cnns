% BINARY CLASSIFICATION - (ALL vs HEM)

% ----------------------- GLOBAL SETTINGS -----------------------
classNumber = 2;
cnns = {alexnet, vgg16, vgg19, resnet18, resnet50, resnet101, googlenet, inceptionv3, shufflenet, squeezenet, mobilenetv2};
cnnNames = {'alexnet', 'vgg16', 'vgg19', 'resnet18', 'resnet50', 'resnet101', 'googlenet', 'inceptionv3', 'shufflenet', 'squeezenet', 'mobilenetv2'};

% ----------------------- FOLDERS -----------------------
if ispc
    % Windows dataset path
    rootPath = 'C:\Users\loand\Pictures\ImmaginiLavoro\Medical\Blood\C-NMC';
else
    % WS dataset path
    rootPath = '/home/server/Datasets/C-NMC/';
end

modelsPath = 'models';
cmPath = 'cm';
checkPath = 'checkpoints';

trainingPaths = { fullfile(rootPath, 'C-NMC_training_data', 'fold_0'), ...
    fullfile(rootPath, 'C-NMC_training_data', 'fold_1'), ...
    fullfile(rootPath, 'C-NMC_training_data', 'fold_2') };
testPath = fullfile( rootPath, 'C-NMC_test_prelim_phase_data' );
testLabelsPath = fullfile( rootPath, 'C-NMC_test_prelim_phase_data', 'C-NMC_test_prelim_phase_data_labels.csv' );

% Test set preparation
testImgs = dir(fullfile( testPath, '*.bmp') );
names = {testImgs.name}.';
[testImgs, ~] = sort_nat(names);

testImgs(:) = fullfile(testPath, testImgs(:));
testLabels = getLabelsFromCsv(testLabelsPath);


%----------------------- DATASET ACQUISITION and OVERSAMPLING -----------------------

% Train + validation sets with 90/10 split
imds = imageDatastore( trainingPaths, 'IncludeSubfolders', true, 'LabelSource', 'foldernames' );
[imdsTrain, imdsValid] = splitEachLabel( imds, 0.9 );

% Test set
imdsTest = imageDatastore( trainingPaths, 'IncludeSubfolders', true, 'LabelSource', 'foldernames' );
imdsTest.Files = testImgs;
imdsTest.Labels = testLabels;

% Check label frequency for imbalance
%labelCount = countEachLabel(imdsTrain);
%histogram(imdsTrain.Labels);title('label frequency')

% Perform training set oversampling to avoid class imbalance
imdsTrain = overSampling(imdsTrain);


%----------------------- TESTING WITH CNNS -----------------------
for i = 1:numel(cnns)

    % Load the network
    net = cnns{i};
    netName = cnnNames{i};
    netCheckPath = fullfile(checkPath, netName);
    if exist( netCheckPath ) ~= 7
        mkdir(netCheckPath)
    end
    if( isa( cnns{i}, 'SeriesNetwork' ) )
        layers = net.Layers;
        layers(end - 2) = fullyConnectedLayer(classNumber);
        layers(end) = classificationLayer();
        netToTrain = layers;
    elseif( isa( cnns{i}, 'DAGNetwork' ) )
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
    imdsTest.ReadFcn = @(filename)resizeIm(filename, inputSize);

    % Training options
    miniBatchSize = 32;
    maxEpochs = 50;
    valFrequency = max(floor(numel(imdsTest.Files)/miniBatchSize)*10,1);

    options = trainingOptions('adam', ...
        'MiniBatchSize', miniBatchSize, ...
        'MaxEpochs', maxEpochs, ...
        'InitialLearnRate', 1e-4, ...
        'LearnRateSchedule', 'piecewise', ...
        'Shuffle', 'every-epoch', ...
        'ValidationData', imdsValid, ...
        'ValidationFrequency', valFrequency, ...
        'Verbose', true, ...
        'CheckpointPath', netCheckPath, ...
        'Plots', 'training-progress');

    % -------------------    TRAIN NETWORK   ------------------------------
    trainedNet = trainNetwork(imdsTrain, netToTrain, options);

    % -------------------    PREDICTIONS   ------------------------------
    preds = classify(trainedNet, imdsTest);
    accuracy = nnz(preds == imdsTest.Labels)/numel(preds);
    fprintf( strcat(netName, ' ACCURACY: ', num2str(accuracy)) );

    % -------------------    CONFUSION MATRIX   ---------------------------
    chart = confusionchart(preds, imdsTest.Labels);

    % -------------------    SAVE   ---------------------------
    netName = strcat( netName, '__EP', num2str(maxEpochs), '__MBS', num2str(miniBatchSize) );
    save(fullfile(modelsPath, netName), "trainedNet");
    save(fullfile(cmPath, netName), "chart");

end
