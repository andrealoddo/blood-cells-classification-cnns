function [DBTrain, DBTest] = getFeatures( datasetsname, featsPath, split, descriptor, graylevel, prepro, trainSplit )

    if strcmp( datasetsname, 'CNMC' )
        DBTest_one = load( fullfile( featsPath, ...
            strcat( datasetsname, '___', ...
            split{2}, '___',...
            descriptor, '___',...
            num2str( graylevel ), '___',...
            prepro{pp}, '.mat') ) );
        DBTest = [DBTest DBTest_one.features];
    end

    if computeCNNFeaturesTrained == 1 % fine-tuned models features
        DBTrain_one = load( fullfile( featsPath, ...
            strcat( datasetsname{dt}, '___', ...
            training_splits{fosp}, '___',...
            split{dt}{sp} , '___',...
            descriptor{dsc}, '___',...
            num2str(graylevel(gl)), '___',...
            prepro{pp}, '.mat') ) );
    elseif computeCNNFeaturesTrained == 0 % standard models features
        DBTrain_one = load( fullfile( featsPath, ...
            strcat( datasetsname{dt}, '___', ...
            split{dt}{trainSplit}, '___',...
            descriptor{dsc}, '___',...
            num2str(graylevel(gl)), '___',...
            prepro{pp}, '.mat') ) );
    end
    
    DBTrain = [DBTrain DBTrain_one.features];
    
end