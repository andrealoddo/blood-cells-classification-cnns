function computeFeaturesExec( datasets, datasetsname, training_splits, splits, ...
    labelsPath, descriptors_sets, perfPath, sourcePath, modelsPath, featsPath,...
    computeCNNFeaturesTrained, aug, graylevel, prepro, colour, cl, featselector, selection)
    
    descriptors = getUniqueDescriptorsList(descriptors_sets);
    
    for dt = 1:numel(datasets)
        for ts = 1:numel(training_splits)
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
                
                if contains(datasetsname{dt}, ["ALLIDB2", "Raabin"])
                    idxDestination = fullfile(labelsPath, strcat( datasetsname{dt}, '___idx'));
                    [training, testing] = splitEachLabel(imds,0.7); idx = {imgDatastore2DatasetIDX(imds, training); 
                        imgDatastore2DatasetIDX(imds, testing)};
                    save(idxDestination, 'idx'); 
                end
                
                if contains(datasetsname{dt}, "ALLIDB1")
                    idxDestination = fullfile(labelsPath, strcat( datasetsname{dt}, '___idx'));
                    [training, validation] = splitEachLabel(imds, 0.775, 0.225); % split usato per il training da automatizzare
                    idx = {imgDatastore2DatasetIDX(imds, training); imgDatastore2DatasetIDX(imds, validation)};
                    save(idxDestination, 'idx'); 
                end
                
                for dsc = 1:numel(descriptors)
                    if contains(descriptors{dsc},'CNN') %%%CNN Features
                        if( computeCNNFeaturesTrained == 0 ) %%% CNN untrained architectures
                            
                            convnet = loadUntrainedCNN( descriptors{dsc} );
                            
                        elseif( computeCNNFeaturesTrained == 1 ) %%% CNN pretrained architectures
                            pretrainedModelsPath = fullfile( modelsPath, ...
                                string(datasets(dt)), strcat('aug', num2str(aug)), training_splits{dt}{ts} );

                            models = dir( fullfile(pretrainedModelsPath, '*.mat') );
                            
                            convnet = loadPretrainedCNN( descriptors{dsc}, models );

                        end
                        
                        sizes = convnet.Layers(1).InputSize;
                    end
                    
                    for gl = 1:numel(graylevel)
                        for pp = 1:numel(prepro)
                            
                            if( contains( descriptors{dsc}, 'FT' ) && computeCNNFeaturesTrained == 1 ) % fine-tuned CNN features
                                trainSplitString = [training_splits{dt}{ts}, '___'] ;
                            else% standard CNN features or HC features
                                trainSplitString = [];
                            end
                            featDestination = fullfile(featsPath, ...
                                strcat( datasetsname{dt}, '___',...
                                trainSplitString,...
                                splits{dt}{sp}, '___',...
                                descriptors{dsc}, '___',...
                                num2str(graylevel(gl)), '___',...
                                prepro{pp}, '.mat' ) );
                                
                            %Check if file exists. If not, compute features.
                            if( isfile(featDestination) == 0 )
                                
                                features = zeros(0,0);
                                fprintf('Computing/reading features: %s %s %s %s\n', ...
                                    datasetsname{dt}, descriptors{dsc}, num2str(graylevel(gl)), prepro{pp});
                                
                                tic;
                                if contains(descriptors{dsc}, 'CNN') %%%CNN Features
                                    imds.ReadFcn = @(filename)readAndPreprocessImage(filename,  prepro{pp}, [sizes(1) sizes(2)], graylevel(gl));
                            
                                    features = getActivations( convnet, descriptors{dsc}, imds, computeCNNFeaturesTrained );
                                                                                                        
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
                                
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                %Ho messo qui il calcolo della FS per
                                %efficienza, qui la calcola una sola volta)
                                %correttezza, lo calcola su un solo descrittore  
                                for fs = 1:numel(featselector)
                                    for sel = 1:numel(selection)
                                        if selection(sel) < 100 && size(DBTrain, 2) > 10
                                            %non c'� bisogno del if-else
                                            %utilizzo la stringa trainSplitString
                                            %creata in precedenza
                                            featSelDestination = fullfile(featsPath, ...
                                                strcat( datasetsname{dt}, '___',...
                                                trainSplitString,...
                                                splits{dt}{sp}, '___',...
                                                descriptors{dsc}, '___',...
                                                num2str(graylevel(gl)), '___',...
                                                prepro{pp}, '___',...
                                                featselector{fs}, '___',...
                                                num2str(selection),...
                                                '.mat' ) );
                                            selected = featureSelection(featselector{fs}, features, labels, selection(sel));
                                            save(featSelDestination, 'selected');
                                        end
                                    end
                                end
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                
                            end
                        end
                    end
                end
                save(timeDestination, 'timeExtraction');
            end
        end
    end 
end


