function [labels, stringSplit, idx, trainSplit] = loadLabels( datasetName, labelsPath, splits, targetsp, sourcesp)
    if nargin == 4
        stringSplit = [splits{targetsp} '___'];
    else
        stringSplit = [splits{sourcesp} 'TO' splits{targetsp} '___'];
    end
    idxDestination = fullfile( labelsPath, strcat(datasetName, '___idx' ) );
    load(idxDestination, 'idx');

    trainSplit = targetsp;
    
    labelDestination = fullfile( labelsPath, strcat(datasetName, '___', splits{trainSplit}) );
    load(labelDestination, 'labels');
end