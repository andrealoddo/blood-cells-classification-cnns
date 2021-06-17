function [model,wAVG] = EvaluateCrossClassification(DBTrain, TrainLabels, DBTest, TestLabels, postpro, selected, classifier, fold)

if size(DBTrain,1)~=size(TrainLabels,1)
    error('Error. Features and labels lenght must be equal')
end
if ~isempty(DBTest)
    if size(DBTest,1)~=size(TestLabels,1)
        error('Error. Features and labels lenght must be equal')
    end
end

size(DBTrain)
if nargin < 8
    fold = 10;
end
if nargin == 6
    classifier = 'kNN';
end

if ~isempty(selected)
    DBTrain = DBTrain(:,selected);  
    if ~isempty(DBTest)
        DBTest = DBTest(:,selected);  
    end
end

if contains(postpro,'nfeat') %normalize features
    DBTrain = normalize(DBTrain, 'range');
    if ~isempty(DBTest)
        DBTest = normalize(DBTest, 'range');
    end
end

if isempty(DBTest) && isempty(TestLabels) 
    if isa(fold,'cell') 
        [sDBTrain, sTrainLabels] = sampling(DBTrain(fold{1},:), TrainLabels(fold{1}), postpro);
        [model,wAVG] = Classification(sDBTrain, sTrainLabels, DBTrain(fold{2},:), TrainLabels(fold{2}), classifier);
    else
        CVO = cvpartition(TrainLabels,'k',fold);
        wAVG = zeros(5,CVO.NumTestSets);
        for i = 1:CVO.NumTestSets
            trIdx = CVO.training(i);
            teIdx = CVO.test(i);
            [sDBTrain, sTrainLabels] = sampling(DBTrain(trIdx,:), TrainLabels(trIdx,:), postpro);
            [model,wAVG(:,i)] = Classification(sDBTrain, sTrainLabels, DBTrain(teIdx,:), TrainLabels(teIdx), classifier);
        end
    end
else
    [sDBTrain, sTrainLabels] = sampling(DBTrain, TrainLabels, postpro);
    [model,wAVG] = Classification(sDBTrain, sTrainLabels, DBTest, TestLabels, classifier);
end

%--------------------------------------------------------------------------

function [DBTrain, TrainLabels] = sampling(DBTrain, TrainLabels, postpro)

if contains(postpro,'undersample') %undersample 
    index = underSampling(TrainLabels);
    DBTrain = DBTrain(index,:);
    TrainLabels = TrainLabels(index,:);
elseif contains(postpro,'oversample') %undersample 
    index = overSampling(TrainLabels);
    DBTrain = DBTrain(index,:);
    TrainLabels = TrainLabels(index,:);
end
size(DBTrain)
