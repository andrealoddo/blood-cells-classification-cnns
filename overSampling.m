function [imds] = overSampling(imds)

    if ispc
        sep = '\';
    else
        sep = '/';
    end

    % Oversampling function.
    % It oversamples the image data which belongs to minor classes.
    % Use splitandapply function to loop the same process for each class.
    % Ref: https://it.mathworks.com/help/vision/ug/point-cloud-classification-using-pointnet-deep-learning.html

    % Extract label information in training dataset
    labels=imds.Labels;

    % Use findgroups function to obtain group index which corresponds to each class.
    % For example, you have the category of dog, cat, and sheep. The index of 1, 2 and 3 was assigned to dog, cat and sheep, respectively.
    % Namely, if you have 5 training images of dog, dog, cat, sheep and dog, the index will be [1 1 2 3 1], corresponding to variable G.
    [G,classes] = findgroups(labels);


    % The splitandapply finction apply a certain function to each class.
    % The code below uses numel function to count the dimension of the variable labels at each class.
    % The size of labels and G is identical so that the group index at each label in the variable label can be easily confirmed.
    numObservations = splitapply(@numel,labels,G);

    % Calculate the number of images comprising the majority class.
    desiredNumObservationsPerClass = max(numObservations);

    % Use splitandapply function again. The function to use is
    % randReplicateFiles function.
    % It returns a random integer and the number of integer to sample
    % is defined by the variable desiredNumObservationsPerClass.
    % desiredNumObservationsPerClass corresponds to the number of images included in most frequent class.
    files = splitapply(@(x){randReplicateFiles(x,desiredNumObservationsPerClass)}, imds.Files, G);
    files = vertcat(files{:});

    % Collect label data.
    labels = [];
    info = strfind(files, sep);

    for i = 1:numel(files)
        idx = info{i};
        dirName = files{i};
        targetStr = dirName(idx(end-1)+1:idx(end)-1);
        targetStr2 = cellstr(targetStr);
        labels = [labels;categorical(targetStr2)];
    end

    imds.Files = files;
    imds.Labels = labels;

    % For visualization purposes only
    %labelCount_oversampled = countEachLabel(imds)
    %histogram(imds.Labels)

end
