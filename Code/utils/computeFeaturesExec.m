function computeFeaturesExec( datasets, datasetsname, folders_split, splits, labelsPath, descriptors_sets )

    descriptors = getUniqueDescriptorsList(descriptors_sets);
    
    for dt = 1:numel(datasets)
        for fs = 1:numel(folders_split)
            for sp = 1:numel(splits{dt})
                
                timeDestination = fullfile(perfPath, ...
                    strcat( 'timeExtraction___', datasetsname{dt}, ...
                    '___', splits{dt}{sp}, '.mat') );
                
                timeExtraction = setOrLoadFile( timeDestination, 'timeExtraction' );
                
                source = fullfile( sourcePath, datasets{dt}, splits{dt}{sp} );
                
                imds = imageDatastore(fullfile(source), 'IncludeSubfolders',true, 'LabelSource','foldernames');
                images = imds.Files;
                labelDestination = fullfile(labelsPath, strcat( datasetsname{dt}, '___', splits{dt}{sp} ));
                labels = imds.Labels;

                if strcmp(datasetsname{dt}, 'CNMC') && strcmp(splits{dt}{sp}, 'C-NMC_test_prelim_phase_data')
                    images = sortImages(images);
                    filename = [source '/C-NMC_test_prelim_phase_data_labels.csv'];
                    labels = getLabelsFromCsv(filename);
                elseif strcmp(datasetsname{dt}, 'ALLIDB2')
                    labels = [ones(ceil(size(labels)/2)); zeros(ceil(size(labels)/2))];
                    imds.Labels=labels;
                end
                
                labels = double(labels);
                save(labelDestination, 'labels'); 
                
                if contains(datasetsname{dt} ,["ALLIDB2", "Raabin"])
                    idxDestination = [labelsPath sep datasetsname{dt} '___idx'];
                    [training, testing] = splitEachLabel(imds,0.7);
                    idx = {imgDatastore2DatasetIDX(imds, training); imgDatastore2DatasetIDX(imds, testing)};
                    save(idxDestination, 'idx'); 
                end
                
                for dsc = 1:numel(descriptors)
                    if contains(descriptors{dsc},'CNN') %%%CNN Features
                        if( computeCNNFeaturesTrained == 0 ) %%% CNN untrained architectures
                            
                            convnet = loadUntrainedCNN( descriptors{dsc} );
                            
                        elseif( computeCNNFeaturesTrained == 1 ) %%% CNN pretrained architectures
                            pretrainedModelsPath = fullfile( modelsPath, ...
                                string(datasetsname(dt)), aug, string(folders_split(fs)), '*.mat' );
                            models = dir( pretrainedModelsPath );
                            
                            convnet_ind = loadPretrainedCNN( models, descriptors{dsc} );
                            
                            convnet = trainedNet;
                            clear trainedNet;
                        end
                        
                        sizes = convnet.Layers(1).InputSize;
                    end
                    
                    for gl = 1:numel(graylevel)
                        for pp = 1:numel(prepro)
                            
                            timeDestination = fullfile(featsPath, ...
                                strcat( datasetsname{dt}, '___',...
                                folders_split{fs}, '___',...
                                splits{dt}{sp}, '___',...
                                descriptors{dsc}, '___',...
                                num2str(graylevel(gl)), '___',...
                                prepro{pp}, '.mat' ) );
                            
                            %Check if file exists. If not, compute features.
                            if isfile(featDestination)
                                
                                features = zeros(0,0);
                                fprintf('Computing/reading features: %s %s %s %s\n', ...
                                    datasetsname{dt}, descriptors{dsc}, num2str(graylevel(gl)), prepro{pp});
                                
                                tic;
                                if contains(descriptors{dsc}, 'CNN') %%%CNN Features
                                    imds.ReadFcn = @(filename)readAndPreprocessImage(filename,  prepro{pp}, [sizes(1) sizes(2)], graylevel(gl));
                            
                                    features = getActivations( descriptors{dsc}, computeCNNFeaturesTrained );
                                                                                                        
                                    features = squeeze(features);
                                    features = features';
                                else                                %%% HC features
                                    for i = 1:size(images,1)
                                        img = imread(images{i});
                                        fprintf('%s -- %s\n', descriptors{dsc}, colour{cl}, images{i});
                                        features = [features; featureExtraction(img, descriptors{dsc}, colour{cl}, graylevel(gl), prepro{pp})'];
                                    end
                                end
                                [dim1, dim2] = size(features);
                                fprintf('Extracted features size: %s %s', num2str(dim1),num2str(dim2));
                                timeExtraction.([descriptors{dsc} '___',...
                                                   num2str(graylevel(gl)) '___',...
                                                   prepro{pp}]) = toc/dim1;
                                fprintf('--- DONE ---\n');
                                save(featDestination, 'features');
                            end
                        end
                    end
                end
                save(timeDestination, 'timeExtraction');
            end
        end
    end 
end

