function idx = imgDatastore2DatasetIDX(imds, split)

m = size(split.Files,1);
idx = zeros(m,1);

for k=1:m
    idx(k) = find(strcmp(imds.Files,split.Files{k}));    
end