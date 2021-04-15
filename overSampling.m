function [imds] = overSampling(imds)
    %Oversamples the image data which belongs to minor classes.

    % Extract files and labels information in training dataset
    files = imds.Files;
    labels = imds.Labels;

    %convert categorical labels into numerical ones
    [G,~] = findgroups(labels);

    %extract the number of observation per class
    numObservations = splitapply(@numel,labels,G);

    % Calculate the number of images comprising the majority class.
    desiredNumObservationsPerClass = max(numObservations);

    % Use splitandapply to random oversample the minor class
    ind = splitapply(@(x){randReplicateFiles(x,desiredNumObservationsPerClass)}, imds.Files, G);
    ind = horzcat(ind{:});
    imds.Files = files(ind);
    imds.Labels = labels(ind);
end

%--------------------------------------------------------------------------

function ind = randReplicateFiles(files,numDesired)
    if numel(files) == numDesired
        ind = 1:numDesired;
    else
        n = numel(files);
        ind = [1:n randi(n,1,numDesired-n)];
    end
end
