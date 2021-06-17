function [model, wAVG] = Classification(DBTrain, TrainLabels, DBTest, TestLabels, classifier, value)

%if they are empty a model is already present
if isempty(DBTrain) && isempty(TrainLabels) 
    model = value;
    if strcmp(classifier, 'ANN')==1 
        outputs = model(DBTest');
        [~, prediction] = max(outputs);
    else
        prediction = predict(model, DBTest);
        if isa(prediction,'cell')
            prediction = str2double(prediction);
        end
    end
else
    if nargin==6 %If a value is present use this value
        NN = value;%Nearest Neighbor value
        level = value;%tree pruning level 
        trees = value;%trees number for ensemble classifier
    else %set all to default values
        NN = 1;%Nearest Neighbor value
        level = 0;%default pruning level (0 representing the full, unpruned tree)
        trees = 100;%trees number for ensemble classifier
    end

    %%Classification step
    if strcmp(classifier, 'ANN')==1   
        hiddenLayerSize = 10;
        model = patternnet(hiddenLayerSize);

        % Setup Division of Data for Training, Validation, Testing
        model.divideParam.trainRatio = 70/100;
        model.divideParam.valRatio = 15/100;
        model.divideParam.testRatio = 15/100;

        % Train the Network
        tl = double(TrainLabels);
        tl2 = double([tl==1 tl==2]);
        model = train(model,DBTrain',tl2');
        outputs = model(DBTest');
        [~, prediction] = max(outputs);
    else
        switch classifier
            case 'SVMLinear'
                template = templateLinear('Learner','logistic');
                model = fitcecoc(DBTrain, TrainLabels, 'Learners', template, 'OptimizeHyperparameters', 'auto', 'Coding','onevsall','HyperparameterOptimizationOptions',struct('ShowPlots',false));                
            case 'SVMRbf'
                template = templateSVM('KernelFunction','gaussian');
                model = fitcecoc(DBTrain, TrainLabels, 'Learners', template, 'OptimizeHyperparameters', 'auto', 'Coding','onevsall','HyperparameterOptimizationOptions',struct('ShowPlots',false));              
            case 'kNN'
                model = fitcknn(DBTrain, TrainLabels);
            case 'NB'
                template = templateNaiveBayes();
                model = fitcecoc(DBTrain, TrainLabels, 'Learners', template);
            case 'NBkernel'
                template = templateNaiveBayes('DistributionNames','kernel');
                model = fitcecoc(DBTrain, TrainLabels, 'Learners', template);
            case 'tree'
                model = fitctree(DBTrain, TrainLabels);
            case 'RF'
                model = TreeBagger(trees, DBTrain, TrainLabels);
            case 'ADA'
                model = fitensemble(DBTrain, TrainLabels, 'AdaBoostM1', trees, 'tree');
            case 'Robust'
                model = fitensemble(DBTrain, TrainLabels, 'RobustBoost', trees, 'tree');
            case 'Logit'
                model = fitensemble(DBTrain, TrainLabels, 'LogitBoost', trees, 'tree');
            case 'Gentle'
                model = fitensemble(DBTrain, TrainLabels,'GentleBoost',trees, 'tree');
            case 'Bag'
                model = fitensemble(DBTrain, TrainLabels, 'Bag', trees, 'tree', 'classifier', 'classification');
            case 'Subspace'
                model = fitensemble(DBTrain, TrainLabels, 'Subspace', 'AllPredictorCombinations', 'KNN', 'classifier', 'classification');
        end
        prediction = predict(model, DBTest);
        if isa(prediction,'cell')
            prediction = str2double(prediction);
        end
    end
end

[~, ~, wAVG] = computeStats(confusionmat(TestLabels,prediction));