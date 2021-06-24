computeFeatures = 0;
computeCNNFeaturesTrained = 1; % reti addestrate, modelli custom
savePerfFeaturesTrained = 1;   % per filename tabelle performance
computePerformances = 0;
computePerformancesCross = 0;
saveTables = 0;
saveTablesCross = 0;
saveTablesALL = 1;

warning off;
codeFolder = pwd;
addpath('utils');

[sourcePath, labelsPath, featsPath, modelsPath, classifPath, perfPath] = getPaths();
[datasets,datasetsname,splits,...
    descriptors_sets,descriptors_sets_names, aug, folders_split, ...
    graylevel, colour, cl, prepro, postpro, featselector, ...
    selection, classifier] = getInfo()
%try
    
    
if computeFeatures == 1
    computeFeatures();
    
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
            for fosp = 1:numel(folders_split) % training split
                for sp = 1:numel(splits{dt}) % all splits
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
                                    
                                    if computeCNNFeaturesTrained == 1
                                        DBTrain_one = load([featsPath sep,...
                                            datasetsname{dt} '___',...
                                            folders_split{fosp} '___',...
                                            splits{dt}{sp} '___',...
                                            descriptors{dsc} '___',...
                                            num2str(graylevel(gl)) '___',...
                                            prepro{pp} '.mat']);
                                    else
                                        DBTrain_one = load([featsPath sep,...
                                            datasetsname{dt} '___',...
                                            splits{dt}{trainsplit} '___',...
                                            descriptors{dsc} '___',...
                                            num2str(graylevel(gl)), '___',...
                                            prepro{pp}, '.mat']);
                                    end
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
                                                destinationResult = [classifPath sep,...
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
                                                    destinationModel = [modelsPath sep,...
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
            for sourcesp = 1:numel(folders_split) %source split             
                for targetsp = 1:numel(splits{dt}) %target split
                    if true%sourcesp ~= targetsp
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
                                        if computeCNNFeaturesTrained == 1
                                            DBTest_one = load([featsPath sep,...
                                                datasetsname{dt} '___',...
                                                folders_split{sourcesp} '___',...
                                                splits{dt}{targetsp} '___',...
                                                descriptors{dsc} '___',...
                                                num2str(graylevel(gl)) '___',...
                                                prepro{pp} '.mat']);
                                        else
                                            DBTest_one = load([featsPath sep,...
                                                datasetsname{dt} '___',...
                                                splits{dt}{targetsp} '___',...
                                                descriptors{dsc} '___',...
                                                num2str(graylevel(gl)), '___',...
                                                prepro{pp}, '.mat']);
                                        end
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
                                                   destinationResult = [classifPath sep 'Cross___',...
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
                                                        destinationModel = [modelsPath sep,...
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
        disp('saveTables');
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
                
                if( savePerfFeaturesTrained == 1)
                    ft = '';
                else
                    ft = 'fine_tuning';
                end
                
                destinationPerf = [perfPath sep,...
                    'Performances___',...
                    datasetsname{dt} '___',...
                    string_split '___' ft '.tex'];
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
                                            destinationResult = [classifPath sep,...
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
        disp('saveTablesCross');
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
                        if( savePerfFeaturesTrained == 1)
                            ft = '';
                        else
                            ft = 'fine_tuning';
                        end
                        destinationPerf = [perfPath sep,...
                            'PerformancesCross___',...
                            datasetsname{dt} '___',...
                            string_split '___' ft '.tex'];
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
                                            
                                            % aggiunto per stampare tabelle
                                            % combinate classic - CNN
                                            % extracted
                                            %if contains( descriptors_sets{dsc_set}, 'CNN' )
                                            %    pop = 2;
                                            %else
                                            %    pop = 1;
                                            %end
                                            
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
    
%catch ME
%    disp(ME.message)
%    if exist('/home/lputzu', 'dir')== 7, quit, end
%end

%if exist('/home/lputzu', 'dir')== 7, quit, end

function value = zeroNaN(value)

    if isnan(value)
        value = 0;
    end
end