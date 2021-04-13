% BINARY CLASSIFICATION - (ALL vs HEM)

% ----------------------- FOLDERS -----------------------
% Windows main path
rootPath = 'C:\Users\loand\Pictures\ImmaginiLavoro\Medical\Blood\C-NMC';

trainingPaths = { fullfile(rootPath, 'C-NMC_training_data\fold_0'), ...
    fullfile(rootPath, 'C-NMC_training_data\fold_1'), ...
    fullfile(rootPath, 'C-NMC_training_data\fold_2')};
testPath = fullfile( rootPath, 'C-NMC_test_prelim_phase_data' );
testLabelsPath = fullfile( rootPath, 'C-NMC_test_prelim_phase_data\C-NMC_test_prelim_phase_data_labels.csv' );

% Test set preparation
testImgs = dir(fullfile( testPath, '*.bmp') );
names = {testImgs.name}.';
[testImgs, ~] = sort_nat(names);

testImgs(:) = fullfile(testPath, testImgs(:));
testLabels = getLabelsFromCsv(testLabelsPath);


%-----------------------  DATASET ACQUISITION and OVERSAMPLING --------------------------
classNumber = 2;
augSize = 227;

% Train + validation sets with 90/10 split
imds = imageDatastore( trainingPaths, 'IncludeSubfolders', true, 'LabelSource', 'foldernames' );
[imdsTrain, imdsValid] = splitEachLabel( imds, 0.9 );

% Test set
imdsTest = imageDatastore( trainingPaths, 'IncludeSubfolders', true, 'LabelSource', 'foldernames' );
imdsTest.Files = testImgs;
testSet.Labels = testLabels;

% Check label frequency for imbalance
%labelCount = countEachLabel(imdsTrain);
%histogram(imdsTrain.Labels);title('label frequency')

% Perform training set oversampling to avoid class imbalance
imdsTrain = overSampling(imdsTrain);

% Preprocess images (resize for network's input requirements)
imdsTrain.ReadFcn = @(filename)resizeIm(filename, augSize); 
imdsValid.ReadFcn = @(filename)resizeIm(filename, augSize); 

% Load the network
net = alexnet;
layers = net.Layers;
layers(end - 2) = fullyConnectedLayer(classNumber);
layers(end) = classificationLayer();

% Training options
miniBatchSize = 64;
valFrequency = max(floor(numel(imdsTest.Files)/miniBatchSize)*10,1);

options = trainingOptions('adam', ...
    'MiniBatchSize', miniBatchSize, ...
    'MaxEpochs', 1, ...
    'InitialLearnRate', 1e-4, ...
    'Shuffle', 'every-epoch', ...
    'ValidationData', imdsValid, ...
    'ValidationFrequency', valFrequency, ...
    'Verbose', false, ...
    'Plots', 'training-progress');

% -------------------    TRAIN NETWORK   -------------------------------
trainedNet = trainNetwork(imdsTrain, layers, options);
%save(fullfile(models_folder, model_name), "trainedNet");
preds = classify(trainedNet, imdsTest);
accuracy = nnz(preds == imdsTest.Labels)/numel(preds)

%Confusion Chart
chart = confusionchart(preds,imdsTest.Labels);
%save(fullfile(models_folder, "alexnet_chart"), "chart");
