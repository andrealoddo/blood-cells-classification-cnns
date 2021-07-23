function [model,wAVG] = EvaluateCrossClassification(DBTrain, TrainLabels, DBTest, TestLabels, postpro, selected, classifier, fold)

if size(DBTrain,1)~=size(TrainLabels,1)
    error('Error. Features and labels lenght must be equal')
end
if ~isempty(DBTest)
    if size(DBTest,1)~=size(TestLabels,1)
        error('Error. Features and labels lenght must be equal')
    end
end

[r1, c1]=size(DBTrain);
disp(['Original Train set size: ' num2str(r1) 'x' num2str(c1)])
if ~isempty(DBTest)
    [r2, c2]=size(DBTest);
    disp(['Original Test set size: ' num2str(r2) 'x' num2str(c2)])
end

if nargin < 8
    fold = 10;
end
if nargin == 6
    classifier = 'kNN';
end

if ~isempty(selected)
    DBTrain = DBTrain(:,selected);  
    [r1, c1]=size(DBTrain);
    disp(['Train set size after selection: ' num2str(r1) 'x' num2str(c1)])
    if ~isempty(DBTest)
        DBTest = DBTest(:,selected);  
        [r2, c2]=size(DBTest);
        disp(['Test set size after selection: ' num2str(r2) 'x' num2str(c2)])
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


[r1, c1]=size(DBTrain);
disp(['Fold set size before sampling: ' num2str(r1) 'x' num2str(c1)])
if contains(postpro,'undersample') %undersample 
    index = underSampling(TrainLabels);
    DBTrain = DBTrain(index,:);
    TrainLabels = TrainLabels(index,:);
elseif contains(postpro,'oversample') %undersample 
    index = overSampling(TrainLabels);
    DBTrain = DBTrain(index,:);
    TrainLabels = TrainLabels(index,:);
end
[r1, c1]=size(DBTrain);
disp(['Fold set size after sampling: ' num2str(r1) 'x' num2str(c1)])
