function [trainLabels, testLabels, trainSplit, stringSplit, idx] = loadLabels( datasetName, labelsPath, splits, sp)

    if strcmp(datasetName, 'CNMC')
        labelDestination = fullfile( labelsPath, strcat(datasetName, '___', splits{2}) );
        load(labelDestination, 'labels');
        testLabels = labels;
        stringSplit = '';
        trainSplit = 1;
    else
        testLabels = [];
        idxDestination = fullfile( labelsPath, strcat(datasetName, '___idx' ) );
        load(idxDestination, 'idx');
        stringSplit = [splits{sp} '___'];
        trainSplit = sp;
    end
    
    labelDestination = fullfile( labelsPath, strcat(datasetName, '___', splits{trainSplit}) );
    load(labelDestination, 'labels');
    trainLabels = labels;

end

