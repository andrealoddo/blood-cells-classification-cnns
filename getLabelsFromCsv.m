function [labels] = getLabelsFromCsv(path)

    % labels: 1 ALL, 0 HEM
    data = readtable(path, 'Delimiter', ',');
    labelsDouble = data{:, 3};
    
    labels = categorical( zeros(size(labelsDouble)) );
    labels(labelsDouble == 1) = 'all';
    labels(labelsDouble == 0) = 'hem';   
    
end

