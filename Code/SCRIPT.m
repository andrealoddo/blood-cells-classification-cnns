computeFeatures = 0;
computePerformances = 1;
computePerformancesCross = 1;
saveTables = 1;
saveTablesCross = 1;
saveTablesALL = 1;

warning off;
codeFolder = pwd;

try
    if exist('C:\Users\Lorenzo', 'dir')== 7 %%PATH per il PC di Lorenzo
        sep = '\';
        sourcePath = 'D:\ImmaginiLavoro\Medical\Blood';
        labelsPath = 'D:\DatiEsperimenti\Medical\Blood\ALLClassification\Labels';
        featsPath  = 'D:\DatiEsperimenti\Medical\Blood\ALLClassification\Features';
        modelsPath  = 'D:\DatiEsperimenti\Medical\Blood\ALLClassification\Models';
        classifPath= 'D:\DatiEsperimenti\Medical\Blood\ALLClassification\Classification';
        perfPath   = 'D:\DatiEsperimenti\Medical\Blood\ALLClassification\Performances';  
    elseif exist('/home/lputzu', 'dir')== 7 %%PATH per Castor
        sep = '/';
        base = '/home/lputzu/Workspaces/MATLAB/Esperimenti/Medical/Blood/ALLClassification';
        sourcePath = [base sep 'dataset'];
        labelsPath = [base sep 'Labels']   ;
        featsPath  = [base sep 'Features'];
        modelsPath  = [base sep 'Models'];
        classifPath= [base sep 'Classification'];
        perfPath   = [base sep 'Performances']; 
        addpath(genpath('/home/lputzu/Workspaces/MATLAB/Function'));
    end

    datasets       = {'C-NMC_Leukemia', 'ALL_IDB/ALL_IDB2'};
    datasetsname   = {'CNMC', 'ALLIDB2'};
    splits = {{'C-NMC_training_data','C-NMC_test_prelim_phase_data'},...
              {'img_nmask'}};
          
    datasets       = {'ALL_IDB/ALL_IDB2','Raabin'};
    datasetsname   = {'ALLIDB2','Raabin'};
    splits = {{'img','img_tCrop','img_wrongCrop','img_wrongCrop2'},{'img','img_tCrop','img_wrongCrop','img_wrongCrop2'}};  
    
    descriptors_sets = {'HM','LMGS_5','CHdue_5','CH_5','ZM_5_5',...
                        'HARri','LBP18','LBP212','LBP216','CLBP18','CLBP212','CLBP216',...
                        'hist','shape',...
                        'alexfc7CNN','VGG19CNN','resnet50CNN','googleCNN',...
                        'HARri-LBP18-shape', 'HARri-shape-hist', 'HARri-LBP18-shape-hist',...
                        'HM-LMGS_5','HM-CHdue_5','HM-CH_5','HM-ZM_5_5','HM-HARri','HM-LBP18',...
                        'LMGS_5-CHdue_5','LMGS_5-CH_5','LMGS_5-ZM_5_5','LMGS_5-HARri','LMGS_5-LBP18',...
                        'CHdue_5-ZM_5_5','CHdue_5-HARri','CHdue_5-LBP18',...
                        'CH_5-ZM_5_5','CH_5-HARri','CH_5-LBP18',...
                        'ZM_5_5-HARri','ZM_5_5-LBP18',...
                        'HM-LMGS_5-CHdue_5','HM-LMGS_5-CH_5','HM-LMGS_5-ZM_5_5','HM-LMGS_5-HARri','HM-LMGS_5-LBP18',...
                        'HM-ZM_5_5-CHdue_5','HM-ZM_5_5-CH_5','HM-ZM_5_5-HARri','HM-ZM_5_5-LBP18',...
                        'HM-CHdue_5-HARri','HM-CH_5-LBP18',...
                        'LMGS_5-CHdue_5-ZM_5_5','LMGS_5-CH_5-ZM_5_5','LMGS_5-ZM_5_5-HARri','LMGS_5-ZM_5_5-LBP18',...
                        'LMGS_5-CHdue_5-HARri','LMGS_5-CH_5-LBP18',...
                        'HM-LMGS_5-CHdue_5-ZM_5_5','HM-LMGS_5-CH_5-ZM_5_5',... 
                        'LMGS_5-CHdue_5-ZM_5_5','LMGS_5-CH_5-ZM_5_5'};  
                    
    descriptors_sets = {'HM','LMGS_5','CHdue_5','CH_5','ZM_5_5',...
                'HARri','LBP18','LBP212','LBP216','CLBP18','CLBP212','CLBP216',...
                'hist','cgram',...
                'haar','gabor',...
                'alexfc7CNN','VGG19CNN','resnet50CNN','googleCNN'};
            
    descriptors_sets_names = {'Hu','Legendre','Chebychev2','Chebychev','Zernike',...
                'HARri','LBP18','LBP212','LBP216','CLBP18','CLBP212','CLBP216',...
                'Histogram','Correlogram'...
                'Haar wavelet','Gabor wavelet',...
                'AlexNet','VGGNet-19','ResNet-50','GoogleNet'};
            
    descriptors_sets = {'LMGS_5','ZM_5_5',...
                'HARri','LBP18',...
                'hist','cgram'...
                'haar','gabor'};
        
    descriptors_sets_names = {'Legendre','Zernike',...
                'HARri','LBP18',...
                'Histogram','Correlogram'...
                'Haar wavelet','Gabor wavelet'};
            
    graylevel = [256];
    colour = {'gray','RGB', 'HSV', 'LAB'};
    cl = 1;
    prepro = ["none"];
    postpro = ["none","nfeat","undersample","oversample","nfeat-undersample"];
    postpro = ["undersample"];
    featselector = {'relieff'};
    %selection = [20,60,100];
    selection = [100];
    classifier = {'kNN','SVMRbf','RF'};
    
    if computeFeatures == 1
        descriptors = {};
        for dsc_set = 1:numel(descriptors_sets)
            C = strsplit(descriptors_sets{dsc_set},'-');
            descriptors = [descriptors, C];
        end
        descriptors = unique(descriptors);
        for dt = 1:numel(datasets)
            for sp = 1:numel(splits{dt})
                timeDestination = [perfPath sep,...
                    'timeExtraction___',...
                    datasetsname{dt} '___',...
                    splits{dt}{sp} '.mat'];
                if exist(timeDestination) == 0
                    timeExtraction = struct();
                else
                    load(timeDestination, 'timeExtraction');   
                end
                source = [sourcePath sep datasets{dt} sep splits{dt}{sp}];
                imds = imageDatastore(fullfile(source),'IncludeSubfolders', true,'LabelSource','foldernames');
                images = imds.Files;
                labelDestination = [labelsPath sep datasetsname{dt} '___' splits{dt}{sp}];
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
                if contains(datasetsname{dt} ,["ALLIDB2","Raabin"])
                    idxDestination = [labelsPath sep datasetsname{dt} '___idx'];
                    [training, testing] = splitEachLabel(imds,0.7);
                    idx = {imgDatastore2DatasetIDX(imds, training); imgDatastore2DatasetIDX(imds, testing)};
                    save(idxDestination, 'idx'); 
                end
                for dsc = 1:numel(descriptors)
                    if contains(descriptors{dsc},'CNN') %%%CNN Features
                        if contains(descriptors{dsc},'alex') %%%alexnet CNN Features
                            convnet = alexnet;
                            disp('loaded alexnet neural network')
                        elseif contains(descriptors{dsc},'VGG16') %%%vgg CNN Features
                            convnet = vgg16;
                            disp('loaded vgg16 nerural network')
                        elseif contains(descriptors{dsc},'VGG19') %%%vgg CNN Features
                            convnet = vgg19;
                            disp('loaded vgg19 nerural network')
                        elseif contains(descriptors{dsc},'google') %%%google CNN Features
                            convnet = googlenet;
                            disp('loaded googlenet nerural network')
                        elseif contains(descriptors{dsc},'resnet50') %%%resnet CNN Features
                            convnet = resnet50;
                            disp('loaded resnet nerural network')
                        end
                        sizes = convnet.Layers(1).InputSize;
                    end
                    for gl = 1:numel(graylevel)
                        for pp = 1:numel(prepro)
                            featDestination = [featsPath sep,...
                                datasetsname{dt} '___',...
                                splits{dt}{sp} '___',...
                                descriptors{dsc} '___',...
                                num2str(graylevel(gl)) '___',...
                                prepro{pp} '.mat'];
                            %Check if file exists. If not, compute features.
                            if exist(featDestination) == 0
                                features = zeros(0,0);
                                fprintf('Computing/reading features: %s %s %s %s\n', datasetsname{dt}, descriptors{dsc}, num2str(graylevel(gl)), prepro{pp});
                                tic;
                                if contains(descriptors{dsc},'CNN') %%%CNN Features
                                    imds.ReadFcn = @(filename)readAndPreprocessImage(filename,  prepro{pp}, [sizes(1) sizes(2)], graylevel(gl));
                                    if contains(descriptors{dsc},'alexfc7') %%%alexnet Features                                                            
                                        features = activations(convnet, imds, 'fc7', 'MiniBatchSize', 32);
                                    elseif contains(descriptors{dsc},'VGG19') %%%VGG CNN Features
                                        features = activations(convnet, imds, 'fc7', 'MiniBatchSize', 32);
                                    elseif contains(descriptors{dsc},'google') %%%CNN Features
                                        features = activations(convnet, imds, 'loss3-classifier', 'MiniBatchSize', 32);
                                    elseif contains(descriptors{dsc},'resnet') %%%CNN Features
                                        features = activations(convnet, imds, 'fc1000', 'MiniBatchSize', 32);
                                    end
                                    features = squeeze(features);
                                    features = features';
                                else
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
    
    %------------------------------------------------------------------------------------------------------------
    
    if computePerformances == 1
        for dt = 1:numel(datasets)
            timeDestination = [perfPath sep,...
                'timeClassification___',...
                datasetsname{dt} '.mat'];
            if exist(timeDestination) == 0
                timeClassification = struct();
            else
                load(timeDestination, 'timeClassification');   
            end
            for sp = 1:numel(splits{dt})
                %Load labels
                if strcmp(datasetsname{dt}, 'CNMC')
                    labelDestination = [labelsPath sep datasetsname{dt} '___' splits{dt}{2}];
                    load(labelDestination, 'labels');
                    TestLabels = labels;
                    string_split = '';
                    trainsplit = 1;
                else
                    TestLabels = [];
                    idxDestination = [labelsPath sep datasetsname{dt} '___idx'];
                    load(idxDestination, 'idx');
                    string_split = [splits{dt}{sp} '___'];
                    trainsplit = sp;
                end
                labelDestination = [labelsPath sep datasetsname{dt} '___' splits{dt}{trainsplit}];
                load(labelDestination, 'labels');
                TrainLabels = labels;
                for dsc_set = 1:numel(descriptors_sets)
                    descriptors = strsplit(descriptors_sets{dsc_set},'-');
                    for gl = 1:numel(graylevel)
                        for pp = 1:numel(prepro)
                            %Take train features
                            DBTrain = [];
                            DBTest = [];
                            for dsc = 1:numel(descriptors)  
                                if strcmp(datasetsname{dt}, 'CNMC')
                                    DBTest_one = load([featsPath sep,...
                                        datasetsname{dt} '___',...
                                        splits{dt}{2} '___',...
                                        descriptors{dsc} '___',...
                                        num2str(graylevel(gl)), '___',...
                                        prepro{pp}, '.mat']);
                                    DBTest = [DBTest DBTest_one.features];
                                end
                                DBTrain_one = load([featsPath sep,...
                                    datasetsname{dt} '___',...
                                    splits{dt}{trainsplit} '___',...
                                    descriptors{dsc} '___',...
                                    num2str(graylevel(gl)), '___',...
                                    prepro{pp}, '.mat']);
                                DBTrain = [DBTrain DBTrain_one.features];
                            end
                            for fs = 1:numel(featselector)
                                for sel = 1:numel(selection)
                                    if selection(sel)<100 && size(DBTrain,2) > 10
                                        selected = featureSelection(featselector{fs}, DBTrain, TrainLabels, selection(sel));
                                        string_selection = [featselector{fs} '___' num2str(selection(sel)) '___'];
                                    else
                                        selected = [];
                                        string_selection = '';
                                    end
                                    for cla = 1:numel(classifier)
                                        for pop = 1:numel(postpro)
                                            destinationResult = [classifPath '/',...
                                                datasetsname{dt} '___',...
                                                string_split ,...
                                                descriptors_sets{dsc_set} '___',...
                                                string_selection,...
                                                num2str(graylevel(gl)) '___',...
                                                prepro{pp} '___',...
                                                postpro{pop} '___',...
                                                classifier{cla} '.mat'];

                                            if exist(destinationResult) == 0
                                                fprintf('CLASSIFICATION: %s %s %s %s %s %s %s\n', datasetsname{dt}, descriptors_sets{dsc_set}, string_selection, num2str(graylevel(gl)), prepro{pp}, postpro{pop},  classifier{cla});
                                                destinationModel = [modelsPath '/',...
                                                    datasetsname{dt} '___',...
                                                    string_split ,...
                                                    descriptors_sets{dsc_set} '___',...
                                                    string_selection,...
                                                    num2str(graylevel(gl)) '___',...
                                                    prepro{pp} '___',...
                                                    postpro{pop} '___',...
                                                    classifier{cla} '.mat'];
                                                tic;
                                                [model,wAVG] = EvaluateCrossClassification(DBTrain, TrainLabels, DBTest, TestLabels, postpro{pop}, selected, classifier{cla}, idx);
                                                timeClassification.([erase( descriptors_sets{dsc_set}, '-' )  '___',...
                                                    string_selection,...
                                                    num2str(graylevel(gl)) '___',...
                                                    prepro{pp} '___',...
                                                    postpro{pop} '___',...
                                                    classifier{cla}]) = toc;     
                                                results = struct('ACC', wAVG(1), 'P', wAVG(2), 'R', wAVG(3), 'TNR', wAVG(4), 'F1', wAVG(5));
                                                save(destinationResult, 'results');
                                                save(destinationModel, 'model');
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            save(timeDestination, 'timeClassification');
        end
    end
           
    %------------------------------------------------------------------------------------------------------------
    
    if computePerformancesCross == 1       
        datasets       = {'ALL_IDB/ALL_IDB2','Raabin'};
        datasetsname   = {'ALLIDB2','Raabin'};
        splits = {{'img','img_tCrop','img_wrongCrop','img_wrongCrop2'},{'img','img_tCrop','img_wrongCrop','img_wrongCrop2'}};  
        
        for dt = 1:numel(datasets)
            for sourcesp = 1:numel(splits{dt})%source split
                for targetsp = 1:numel(splits{dt})%target split
                    if sourcesp ~= targetsp
                        TrainLabels = [];
                        idxDestination = [labelsPath sep datasetsname{dt} '___idx'];
                        load(idxDestination, 'idx');
                        string_split = [splits{dt}{sourcesp} 'TO' splits{dt}{targetsp} '___'];
                        labelDestination = [labelsPath sep datasetsname{dt} '___' splits{dt}{targetsp}];
                        load(labelDestination, 'labels');
                        TestLabels = labels;
                        for dsc_set = 1:numel(descriptors_sets)
                            descriptors = strsplit(descriptors_sets{dsc_set},'-');
                            for gl = 1:numel(graylevel)
                                for pp = 1:numel(prepro)
                                    %Take train features
                                    DBTrain = [];
                                    DBTest = [];
                                    for dsc = 1:numel(descriptors)  
                                        DBTest_one = load([featsPath sep,...
                                            datasetsname{dt} '___',...
                                            splits{dt}{targetsp} '___',...
                                            descriptors{dsc} '___',...
                                            num2str(graylevel(gl)), '___',...
                                            prepro{pp}, '.mat']);
                                        DBTest = [DBTest DBTest_one.features];
                                    end
                                    for fs = 1:numel(featselector)
                                        for sel = 1:numel(selection)
                                            if selection(sel)<100 && size(DBTest,2) > 10
                                                selected = featureSelection(featselector{fs}, DBTest, TrainLabels, selection(sel));
                                                string_selection = [featselector{fs} '___' num2str(selection(sel)) '___'];
                                            else
                                                selected = [];
                                                string_selection = '';
                                            end
                                            for cla = 1:numel(classifier)
                                                for pop = 1:numel(postpro)
                                                   destinationResult = [classifPath '/Cross___',...
                                                        datasetsname{dt} '___',...
                                                        string_split ,...
                                                        descriptors_sets{dsc_set} '___',...
                                                        string_selection,...
                                                        num2str(graylevel(gl)) '___',...
                                                        prepro{pp} '___',...
                                                        postpro{pop} '___',...
                                                        classifier{cla} '.mat'];
                                                    if exist(destinationResult) == 0
                                                        fprintf('CLASSIFICATION: %s %s %s %s %s %s %s\n', datasetsname{dt}, descriptors_sets{dsc_set}, string_selection, num2str(graylevel(gl)), prepro{pp}, postpro{pop},  classifier{cla});
                                                        destinationModel = [modelsPath '/',...
                                                            datasetsname{dt} '___',...
                                                            splits{dt}{sourcesp} '___',...
                                                            descriptors_sets{dsc_set} '___',...
                                                            string_selection,...
                                                            num2str(graylevel(gl)) '___',...
                                                            prepro{pp} '___',...
                                                            postpro{pop} '___',...
                                                            classifier{cla} '.mat'];
                                                        if exist(destinationModel) ~= 0
                                                            load(destinationModel, 'model');
                                                            [~,wAVG] = Classification([], [], DBTest(idx{2},:), TestLabels(idx{2}), classifier, model);
                                                            results = struct('ACC', wAVG(1), 'P', wAVG(2), 'R', wAVG(3), 'TNR', wAVG(4), 'F1', wAVG(5));
                                                            save(destinationResult, 'results');
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end     
                end
            end
        end
    end
    
    %------------------------------------------------------------------------------------------------------------

    if saveTables == 1
        headings =  ['\\documentclass[12pt,italian]{article}\n',...
            '\\usepackage{graphicx}\n',...
            '\\usepackage{longtable}\n',...
            '\\parskip 0.1in\n',...
            '\\oddsidemargin -1in\n',...
            '\\evensidemargin -1in\n',...
            '\\topmargin -0.5in\n',...
            '\\textwidth 6.8in\n',...
            '\\textheight 9.9in\n',...
            '\\usepackage{fancyhdr}\n',...
            '\\usepackage{booktabs}\n',...
            '\\usepackage{multirow}\n',...
            '\\usepackage{amsmath}\n',...
            '\\begin{document}\n',...
            '\\begin{tiny}\n'];

        closing = '\\end{tiny} \n \\end{document}';
        %Collect and write results
        for dt = 1:numel(datasets)
            %Write results in a LaTeX table    
            
            for sp = 1:numel(splits{dt})
                %Load labels
                if strcmp(datasetsname{dt}, 'CNMC')
                    string_split = '';
                else
                    string_split = splits{dt}{sp};
                end
                destinationPerf = [perfPath sep,...
                    'Performances___',...
                    datasetsname{dt} '___',...
                    string_split '.tex'];
                pFile = fopen(destinationPerf, 'w');
                fprintf(pFile, headings);
                for fs = 1:numel(featselector)
                    for sel = 1:numel(selection)
                        if selection(sel)<100 && size(DBTrain,2) > 10
                            selected = featureSelection(featselector{fs}, DBTrain, labels, selection(sel));
                            string_selection = [featselector{fs} '___' num2str(selection(sel)) '___'];
                        else
                            selected = [];
                            string_selection = '';
                        end
                        for gl = 1:numel(graylevel)
                            for pp = 1:numel(prepro)
                                for pop = 1:numel(postpro)         
                                    %Write table
                                    fprintf(pFile, '\\begin{longtable}{l');
                                    %fprintf(pFile, '\\begin{tabular}{l');
                                    for cla = 1:(numel(classifier)*5 + 1)
                                        fprintf(pFile, 'c');
                                    end
                                    fprintf(pFile, '}\n');
                                    fprintf(pFile, '\\toprule\n');
                                    %Heading
                                    fprintf(pFile, '\\multicolumn{%d}{c}{Dataset=%s selection=%s\\%% prepro= %s postpro= %s, gl= %s} \\\\ \n', numel(classifier)*5+1, datasetsname{dt}, string_selection, prepro{pp}, postpro{pop}, num2str(graylevel(gl)));
                                    fprintf(pFile, '\\toprule\n');
                                    fprintf(pFile, 'Descriptor & \\multicolumn{%d}{c}{Classifier} \\\\ \n', numel(classifier)*5);
                                    for cla = 1:numel(classifier)
                                        fprintf(pFile, '& \\multicolumn{5}{c}{%s} ', classifier{cla});
                                    end
                                    fprintf(pFile, '\\\\ \n');
                                    for ni = 1:numel(classifier)
                                        fprintf(pFile, '& A & P & R & S & F1 ');
                                    end
                                    fprintf(pFile, '\\\\ \n');
                                    fprintf(pFile, '\\midrule\n');

                                    %Data
                                    sumA = zeros(numel(classifier),1);
                                    sumP = zeros(numel(classifier),1);
                                    sumR = zeros(numel(classifier),1);
                                    sumS = zeros(numel(classifier),1);
                                    sumF1 = zeros(numel(classifier),1);
                                    for dsc_set = 1:numel(descriptors_sets)
                                        if contains( descriptors_sets{dsc_set}, '_' )
                                            desc_write = erase( descriptors_sets_names{dsc_set}, '_' );
                                        else
                                            desc_write = descriptors_sets_names{dsc_set};
                                        end
                                        fprintf(pFile, '%s ', desc_write);
                                        for cla = 1:numel(classifier)                     
                                            %load retrieval results
                                            destinationResult = [classifPath '/',...
                                                datasetsname{dt} '___',...
                                                string_split '___',...
                                                descriptors_sets{dsc_set} '___',...
                                                string_selection,...
                                                num2str(graylevel(gl)) '___',...
                                                prepro{pp} '___',...
                                                postpro{pop} '___',...
                                                classifier{cla} '.mat'];
                                            if exist(destinationResult) ~= 0
                                                load(destinationResult, 'results');                       
                                                fprintf(pFile, '& %4.1f ', 100*zeroNaN(results.ACC));
                                                fprintf(pFile, '& %4.1f ', 100*zeroNaN(results.P));
                                                fprintf(pFile, '& %4.1f ', 100*zeroNaN(results.R));    
                                                fprintf(pFile, '& %4.1f ', 100*zeroNaN(results.TNR));
                                                fprintf(pFile, '& %4.1f ', 100*zeroNaN(results.F1)); 
                                                sumA(cla) = sumA(cla)+zeroNaN(results.ACC);
                                                sumP(cla) = sumP(cla)+zeroNaN(results.P);
                                                sumR(cla) = sumR(cla)+zeroNaN(results.R);
                                                sumS(cla) = sumS(cla)+zeroNaN(results.TNR);
                                                sumF1(cla) = sumF1(cla)+zeroNaN(results.F1);
                                            end
                                        end
                                        fprintf(pFile, '\\\\ \n');
                                    end
                                    fprintf(pFile, '\\hline\n');
                                    fprintf(pFile, 'AVG ');
                                    for cla = 1:numel(classifier)
                                        fprintf(pFile, '& %4.1f ', 100*(sumA(cla)/numel(descriptors_sets)));
                                        fprintf(pFile, '& %4.1f ', 100*(sumP(cla)/numel(descriptors_sets)));
                                        fprintf(pFile, '& %4.1f ', 100*(sumR(cla)/numel(descriptors_sets)));  
                                        fprintf(pFile, '& %4.1f ', 100*(sumS(cla)/numel(descriptors_sets)));
                                        fprintf(pFile, '& %4.1f ', 100*(sumF1(cla)/numel(descriptors_sets)));  
                                    end
                                    fprintf(pFile, '\\\\ \n');
                                    fprintf(pFile, '\\hline\n');
                                    fprintf(pFile, '\\bottomrule\n');
                                    fprintf(pFile, '\\end{longtable} \n');
                                    fprintf(pFile, '\n \\pagebreak \n');
                                end
                            end
                        end
                    end
                end
                if pFile ~= -1
                    fprintf(pFile, closing);
                    fclose(pFile);
                end
            end
        end
    end
       
    %------------------------------------------------------------------------------------------------------------

    if saveTablesCross == 1
        headings =  ['\\documentclass[12pt,italian]{article}\n',...
            '\\usepackage{graphicx}\n',...
            '\\usepackage{longtable}\n',...
            '\\parskip 0.1in\n',...
            '\\oddsidemargin -1in\n',...
            '\\evensidemargin -1in\n',...
            '\\topmargin -0.5in\n',...
            '\\textwidth 6.8in\n',...
            '\\textheight 9.9in\n',...
            '\\usepackage{fancyhdr}\n',...
            '\\usepackage{booktabs}\n',...
            '\\usepackage{multirow}\n',...
            '\\usepackage{amsmath}\n',...
            '\\begin{document}\n',...
            '\\begin{tiny}\n'];

        closing = '\\end{tiny} \n \\end{document}';

        datasets       = {'ALL_IDB/ALL_IDB2','Raabin'};
        datasetsname   = {'ALLIDB2','Raabin'};
        splits = {{'img','img_tCrop','img_wrongCrop','img_wrongCrop2'},{'img','img_tCrop','img_wrongCrop','img_wrongCrop2'}};  
        
        for dt = 1:numel(datasets)
            for sourcesp = 1:numel(splits{dt})%source split
                for targetsp = 1:numel(splits{dt})%target split
                    if sourcesp ~= targetsp
                        string_split = [splits{dt}{sourcesp} 'TO' splits{dt}{targetsp} '___'];
                        destinationPerf = [perfPath sep,...
                            'PerformancesCross___',...
                            datasetsname{dt} '___',...
                            string_split '.tex'];
                        pFile = fopen(destinationPerf, 'w');
                        fprintf(pFile, headings);
                        for fs = 1:numel(featselector)
                            for sel = 1:numel(selection)
                                if selection(sel)<100 && size(DBTrain,2) > 10
                                    selected = featureSelection(featselector{fs}, DBTrain, labels, selection(sel));
                                    string_selection = [featselector{fs} '___' num2str(selection(sel)) '___'];
                                else
                                    selected = [];
                                    string_selection = '';
                                end
                                for gl = 1:numel(graylevel)
                                    for pp = 1:numel(prepro)
                                        for pop = 1:numel(postpro)         
                                            %Write table
                                            fprintf(pFile, '\\begin{longtable}{l');
                                            %fprintf(pFile, '\\begin{tabular}{l');
                                            for cla = 1:(numel(classifier)*5 + 1)
                                                fprintf(pFile, 'c');
                                            end
                                            fprintf(pFile, '}\n');
                                            fprintf(pFile, '\\toprule\n');
                                            %Heading
                                            fprintf(pFile, '\\multicolumn{%d}{c}{Dataset=%s selection=%s\\%% prepro= %s postpro= %s, gl= %s} \\\\ \n', numel(classifier)*5+1, datasetsname{dt}, string_selection, prepro{pp}, postpro{pop}, num2str(graylevel(gl)));
                                            fprintf(pFile, '\\toprule\n');
                                            fprintf(pFile, 'Descriptor & \\multicolumn{%d}{c}{Classifier} \\\\ \n', numel(classifier)*5);
                                            for cla = 1:numel(classifier)
                                                fprintf(pFile, '& \\multicolumn{5}{c}{%s} ', classifier{cla});
                                            end
                                            fprintf(pFile, '\\\\ \n');
                                            for ni = 1:numel(classifier)
                                                fprintf(pFile, '& A & P & R & S & F1 ');
                                            end
                                            fprintf(pFile, '\\\\ \n');
                                            fprintf(pFile, '\\midrule\n');

                                            %Data
                                            sumA = zeros(numel(classifier),1);
                                            sumP = zeros(numel(classifier),1);
                                            sumR = zeros(numel(classifier),1);
                                            sumS = zeros(numel(classifier),1);
                                            sumF1 = zeros(numel(classifier),1);
                                            for dsc_set = 1:numel(descriptors_sets)
                                                if contains( descriptors_sets{dsc_set}, '_' )
                                                    desc_write = erase( descriptors_sets_names{dsc_set}, '_' );
                                                else
                                                    desc_write = descriptors_sets_names{dsc_set};
                                                end
                                                fprintf(pFile, '& %s ', desc_write);
                                                for cla = 1:numel(classifier)                     
                                                    %load retrieval results
                                                    destinationResult = [classifPath '/Cross___',...
                                                        datasetsname{dt} '___',...
                                                        string_split ,...
                                                        descriptors_sets{dsc_set} '___',...
                                                        string_selection,...
                                                        num2str(graylevel(gl)) '___',...
                                                        prepro{pp} '___',...
                                                        postpro{pop} '___',...
                                                        classifier{cla} '.mat'];
                                                    if exist(destinationResult) ~= 0
                                                        load(destinationResult, 'results');                       
                                                        fprintf(pFile, '& %4.1f ', 100*zeroNaN(results.ACC));
                                                        fprintf(pFile, '& %4.1f ', 100*zeroNaN(results.P));
                                                        fprintf(pFile, '& %4.1f ', 100*zeroNaN(results.R));    
                                                        fprintf(pFile, '& %4.1f ', 100*zeroNaN(results.TNR));
                                                        fprintf(pFile, '& %4.1f ', 100*zeroNaN(results.F1)); 
                                                        sumA(cla) = sumA(cla)+zeroNaN(results.ACC);
                                                        sumP(cla) = sumP(cla)+zeroNaN(results.P);
                                                        sumR(cla) = sumR(cla)+zeroNaN(results.R);
                                                        sumS(cla) = sumS(cla)+zeroNaN(results.TNR);
                                                        sumF1(cla) = sumF1(cla)+zeroNaN(results.F1);
                                                    end
                                                end
                                                fprintf(pFile, '\\\\ \n');
                                            end
                                            fprintf(pFile, '\\hline\n');
                                            fprintf(pFile, '& AVG ');
                                            for cla = 1:numel(classifier)
                                                fprintf(pFile, '& %4.1f ', 100*(sumA(cla)/numel(descriptors_sets)));
                                                fprintf(pFile, '& %4.1f ', 100*(sumP(cla)/numel(descriptors_sets)));
                                                fprintf(pFile, '& %4.1f ', 100*(sumR(cla)/numel(descriptors_sets)));  
                                                fprintf(pFile, '& %4.1f ', 100*(sumS(cla)/numel(descriptors_sets)));
                                                fprintf(pFile, '& %4.1f ', 100*(sumF1(cla)/numel(descriptors_sets)));  
                                            end
                                            fprintf(pFile, '\\\\ \n');
                                            fprintf(pFile, '\\hline\n');
                                            fprintf(pFile, '\\bottomrule\n');
                                            fprintf(pFile, '\\end{longtable} \n');
                                            fprintf(pFile, '\n \\pagebreak \n');
                                        end
                                    end
                                end
                            end
                        end
                        if pFile ~= -1
                            fprintf(pFile, closing);
                            fclose(pFile);
                        end
                    end
                end
            end
        end
    end
    
    %------------------------------------------------------------------------------------------------------------

    if saveTablesALL == 1
        headings =  ['\\documentclass[12pt,italian]{article}\n',...
            '\\usepackage{graphicx}\n',...
            '\\usepackage{longtable}\n',...
            '\\parskip 0.1in\n',...
            '\\oddsidemargin -1in\n',...
            '\\evensidemargin -1in\n',...
            '\\topmargin -0.5in\n',...
            '\\textwidth 6.8in\n',...
            '\\textheight 9.9in\n',...
            '\\usepackage{fancyhdr}\n',...
            '\\usepackage{booktabs}\n',...
            '\\usepackage{multirow}\n',...
            '\\usepackage{amsmath}\n',...
            '\\begin{document}\n',...
            '\\begin{tiny}\n'];

        closing = '\\end{tiny} \n \\end{document}';

        datasets       = {'ALL_IDB/ALL_IDB2','Raabin'};
        datasetsname   = {'ALLIDB2','Raabin'};
        splits = {{'img','img_tCrop','img_wrongCrop','img_wrongCrop2'},{'img','img_tCrop','img_wrongCrop','img_wrongCrop2'}};  
        
        for dt = 1:numel(datasets)
            for sourcesp = 1:numel(splits{dt})%source split
                string_split = [splits{dt}{sourcesp} 'TOothers___'];
                destinationPerf = [perfPath sep,...
                    'PerformancesAll___',...
                    datasetsname{dt} '___',...
                    string_split '.tex'];
                pFile = fopen(destinationPerf, 'w');
                fprintf(pFile, headings);
                for cla = 1:numel(classifier)  
                    for fs = 1:numel(featselector)
                        for sel = 1:numel(selection)
                            if selection(sel)<100 && size(DBTrain,2) > 10
                                selected = featureSelection(featselector{fs}, DBTrain, labels, selection(sel));
                                string_selection = [featselector{fs} '___' num2str(selection(sel)) '___'];
                            else
                                selected = [];
                                string_selection = '';
                            end
                            for gl = 1:numel(graylevel)
                                for pp = 1:numel(prepro)
                                    for pop = 1:numel(postpro)         
                                        %Write table
                                        fprintf(pFile, '\\begin{longtable}{l');
                                        %fprintf(pFile, '\\begin{tabular}{l');
                                        for targetsp = 1:(numel(splits{dt})*5 + 1)
                                            fprintf(pFile, 'c');
                                        end
                                        fprintf(pFile, '}\n');
                                        fprintf(pFile, '\\toprule\n');
                                        %Heading
                                        fprintf(pFile, '\\multicolumn{%d}{c}{Dataset=%s selection=%s\\%% prepro= %s postpro= %s, gl= %s} \\\\ \n', numel(splits{dt})*5+1, datasetsname{dt}, string_selection, prepro{pp}, postpro{pop}, num2str(graylevel(gl)));
                                        fprintf(pFile, '\\toprule\n');
                                        fprintf(pFile, 'Classifier & Descriptor & \\multicolumn{%d}{c}{Target set} \\\\ \n', numel(splits{dt})*5);
                                        for targetsp = 1:numel(splits{dt})
                                            fprintf(pFile, '& \\multicolumn{5}{c}{%s} ', splits{dt}{targetsp});
                                        end
                                        fprintf(pFile, '\\\\ \n');
                                        for targetsp = 1:numel(splits{dt})
                                            fprintf(pFile, '& A & P & R & S & F1 ');
                                        end
                                        fprintf(pFile, '\\\\ \n');
                                        fprintf(pFile, '\\midrule\n');

                                        %Data
                                        sumA = zeros(numel(splits{dt}),1);
                                        sumP = zeros(numel(splits{dt}),1);
                                        sumR = zeros(numel(splits{dt}),1);
                                        sumS = zeros(numel(splits{dt}),1);
                                        sumF1 = zeros(numel(splits{dt}),1);
                                        fprintf(pFile, '\\multirow{%s}{*}{%s}', numel(descriptors_sets), classifier{cla});
                                        for dsc_set = 1:numel(descriptors_sets)
                                            if contains( descriptors_sets{dsc_set}, '_' )
                                                desc_write = erase( descriptors_sets_names{dsc_set}, '_' );
                                            else
                                                desc_write = descriptors_sets_names{dsc_set};
                                            end
                                            fprintf(pFile, '& %s ', desc_write);
                                            for targetsp = 1:numel(splits{dt})%target split    
                                                if sourcesp ~= targetsp
                                                    string_split = [splits{dt}{sourcesp} 'TO' splits{dt}{targetsp} '___'];
                                                    destinationResult = [classifPath '/Cross___',...
                                                        datasetsname{dt} '___',...
                                                        string_split ,...
                                                        descriptors_sets{dsc_set} '___',...
                                                        string_selection,...
                                                        num2str(graylevel(gl)) '___',...
                                                        prepro{pp} '___',...
                                                        postpro{pop} '___',...
                                                        classifier{cla} '.mat'];
                                                else
                                                    string_split = splits{dt}{sourcesp};
                                                    destinationResult = [classifPath '/',...
                                                        datasetsname{dt} '___',...
                                                        string_split '___',...
                                                        descriptors_sets{dsc_set} '___',...
                                                        string_selection,...
                                                        num2str(graylevel(gl)) '___',...
                                                        prepro{pp} '___',...
                                                        postpro{pop} '___',...
                                                        classifier{cla} '.mat'];
                                                end
                                                if exist(destinationResult) ~= 0
                                                    load(destinationResult, 'results');                       
                                                    fprintf(pFile, '& %4.1f ', 100*zeroNaN(results.ACC));
                                                    fprintf(pFile, '& %4.1f ', 100*zeroNaN(results.P));
                                                    fprintf(pFile, '& %4.1f ', 100*zeroNaN(results.R));    
                                                    fprintf(pFile, '& %4.1f ', 100*zeroNaN(results.TNR));
                                                    fprintf(pFile, '& %4.1f ', 100*zeroNaN(results.F1)); 
                                                    sumA(targetsp) = sumA(targetsp)+zeroNaN(results.ACC);
                                                    sumP(targetsp) = sumP(targetsp)+zeroNaN(results.P);
                                                    sumR(targetsp) = sumR(targetsp)+zeroNaN(results.R);
                                                    sumS(targetsp) = sumS(targetsp)+zeroNaN(results.TNR);
                                                    sumF1(targetsp) = sumF1(targetsp)+zeroNaN(results.F1);
                                                end
                                            end
                                            fprintf(pFile, '\\\\ \n');
                                        end
                                        fprintf(pFile, '\\hline\n');
                                        fprintf(pFile, '& AVG ');
                                        for targetsp = 1:numel(splits{dt})
                                            fprintf(pFile, '& %4.1f ', 100*(sumA(targetsp)/numel(descriptors_sets)));
                                            fprintf(pFile, '& %4.1f ', 100*(sumP(targetsp)/numel(descriptors_sets)));
                                            fprintf(pFile, '& %4.1f ', 100*(sumR(targetsp)/numel(descriptors_sets)));  
                                            fprintf(pFile, '& %4.1f ', 100*(sumS(targetsp)/numel(descriptors_sets)));
                                            fprintf(pFile, '& %4.1f ', 100*(sumF1(targetsp)/numel(descriptors_sets)));  
                                        end
                                        fprintf(pFile, '\\\\ \n');
                                        fprintf(pFile, '\\hline\n');
                                        fprintf(pFile, '\\bottomrule\n');
                                        fprintf(pFile, '\\end{longtable} \n');
                                        fprintf(pFile, '\n \\pagebreak \n');
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if pFile ~= -1
                fprintf(pFile, closing);
                fclose(pFile);
            end
        end
    end
    
catch ME
    disp(ME.message)
    if exist('/home/lputzu', 'dir')== 7, quit, end
end

if exist('/home/lputzu', 'dir')== 7, quit, end

function value = zeroNaN(value)

    if isnan(value)
        value = 0;
    end
end