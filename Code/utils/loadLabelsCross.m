function [labels, stringSplit, idx] = loadLabelsCross( datasetName, labelsPath, splits, sourceSplit, targetSplit)

    idxDestination = fullfile( labelsPath, strcat( datasetName, '___idx' ) );
    load(idxDestination, 'idx');
    stringSplit = [splits{sourceSplit} 'TO' splits{targetSplit} '___'];

    labelDestination = fullfile( labelsPath, strcat(datasetName, '___', splits{targetSplit}) );
    load(labelDestination, 'labels');       
end

