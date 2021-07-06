function trainMultipleCNNs( rootPath, modelsPath, confsPath, datasets, training_splits, aug, descriptors_sets )

    % ----------------------- GLOBAL SETTINGS -----------------------
    
    [cnns, cnnNames] = getCNNsFromDescriptorsSets( descriptors_sets );
    
    checkPath = 'Checkpoints';
    saveCheckpoints = 0;


    %----------------------- TRAINING CNNS -----------------------
    for ds = 1:numel(datasets)
        
        classNumber = getClassNumber( datasets{ds} );
                
        for bb = 1:numel(training_splits)

            trainingPath = fullfile(rootPath, datasets{ds}, training_splits{bb});
            modelPath = fullfile(modelsPath, datasets{ds}, strcat('aug', num2str(aug)), training_splits{bb});
            confPath = fullfile(confsPath, datasets{ds}, strcat('aug', num2str(aug)), training_splits{bb});
            
            %perfFilename = ['results__', training_splits{bb}, '__aug__', num2str(aug), '.tex'];
            
            if( isfolder( modelPath ) == 0 )
                mkdir(modelPath)
            end
            if( isfolder( confPath ) == 0 )
                mkdir(confPath)
            end

            %----------------------- DATASET ACQUISITION and OVERSAMPLING -----------------------

            % Train + validation sets with split and augmentation
            if( aug == 1 )
              [imdsTrain, imdsValid, imdsTest] = augmentImages( trainingPath, 0.6, 0.1, 0.3, training_splits{bb});
            elseif( aug == 0 )
              imds = imageDatastore( trainingPath, 'IncludeSubfolders', true, 'LabelSource', 'foldernames' );
              [imdsTrain, imdsValid, imdsTest] = splitEachLabel( imds, 0.6, 0.1, 0.3 );
            end

            % Check label frequency for imbalance
            %labelCount = countEachLabel(imdsTrain);
            %histogram(imdsTrain.Labels);title('label frequency')

            % Perform training set oversampling to avoid class imbalance
            %imdsTrain = overSampling(imdsTrain);

            for i = 1:numel(cnns)

                % Load the network
                net = cnns{i};
                netName = cnnNames{i};
                netCheckPath = fullfile(checkPath, training_splits{bb}, netName);

                trainCNN(net, netName, netCheckPath, modelPath, confPath, ...
                    aug, classNumber, imdsTrain, imdsValid, imdsTest, saveCheckpoints);
            end

            %evalConfusionMatrix(confPath, perfPath, perfFilename);    
        end 
    end
end
