trainNets = 0;
computeFeatures = 0;
computeCNNFeaturesTrained = 1; % reti addestrate, modelli custom
savePerfFeaturesTrained = 0;   % per filename tabelle performance
computePerformances = 1;
computePerformancesCross = 1;
saveTables = 0;
saveTablesCross = 1;
saveTablesALL = 0;

warning off;
codeFolder = pwd;
addpath('utils');

[sourcePath, labelsPath, featsPath, modelsPath, classifPath, perfPath, confPath] = getPaths();

[datasets,datasetsname,splits,training_splits,...
    descriptors_sets, descriptors_sets_names, aug, ...
    graylevel, colour, cl, prepro, postpro, featselector, ...
    selection, classifier] = getInfo();

%try

if trainNets == 1
    
    trainMultipleCNNs( sourcePath, modelsPath, confPath, datasets, training_splits, aug, descriptors_sets );
    
end

if computeFeatures == 1
    
    computeFeaturesExec( datasets, datasetsname, training_splits, splits, ...
        labelsPath, descriptors_sets, perfPath, sourcePath, modelsPath, featsPath,...
        computeCNNFeaturesTrained, aug, graylevel, prepro, colour, cl, featselector );
    
end

%------------------------------------------------------------------------------------------------------------

if computePerformances == 1
    
    computePerformancesExec( datasets, datasetsname, training_splits, splits, ...
        labelsPath, perfPath, featsPath, classifPath, modelsPath, ...
        descriptors_sets, prepro, featselector, selection, graylevel, classifier, postpro, computeCNNFeaturesTrained);
    
end

%------------------------------------------------------------------------------------------------------------

if computePerformancesCross == 1

    computePerformancesCrossExec( datasets, datasetsname, training_splits, splits, ...
        labelsPath, perfPath, featsPath, classifPath, modelsPath, ...
        descriptors_sets, prepro, featselector, selection, graylevel, classifier, postpro, computeCNNFeaturesTrained);
    
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
            
            destinationPerf = fullfile(perfPath,...
                strcat('Performances___',...
                datasetsname{dt}, '___',...
                string_split, '___', ft, '.tex'));
            
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
                                        destinationResult = fullfile( classifPath,...
                                            strcat(datasetsname{dt}, '___',...
                                            string_split, '___',...
                                            descriptors_sets{dsc_set}, '___',...
                                            string_selection,...
                                            num2str(graylevel(gl)), '___',...
                                            prepro{pp}, '___',...
                                            postpro{pop}, '___',...
                                            classifier{cla}, '.mat') );
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
    
    %datasets       = {'ALL_IDB/ALL_IDB2','Raabin'};
    %datasetsname   = {'ALLIDB2','Raabin'};
    %splits = {{'img','img_tCrop','img_wrongCrop','img_wrongCrop2'},{'img','img_tCrop','img_wrongCrop','img_wrongCrop2'}};
    
    for dt = 1:numel(datasets)
        for sourcesp = 1:numel(training_splits{dt})%source split
            for targetsp = 1:numel(splits{dt})%target split
                if sourcesp ~= targetsp
                    string_split = [training_splits{dt}{sourcesp} 'TO' splits{dt}{targetsp} '___'];
                    if( savePerfFeaturesTrained == 1)
                        ft = '';
                    else
                        ft = 'fine_tuning';
                    end
                    destinationPerf = fullfile(perfPath,...
                        strcat('PerformancesCross___',...
                        datasetsname{dt}, '___',...
                        string_split, '___', ft, '.tex'));
                    
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
    
    %datasets       = {'ALL_IDB/ALL_IDB2','Raabin'};
    %datasetsname   = {'ALLIDB2','Raabin'};
    %splits = {{'img','img_tCrop','img_wrongCrop','img_wrongCrop2'},{'img','img_tCrop','img_wrongCrop','img_wrongCrop2'}};
    
    for dt = 1:numel(datasets)
        for sourcesp = 1:numel(training_splits{dt})%source split
            string_split = [training_splits{dt}{sourcesp} 'TOothers___'];
            destinationPerf = fullfile(perfPath,...
                strcat('PerformancesAll___',...
                datasetsname{dt}, '___',...
                string_split, '.tex'));
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
