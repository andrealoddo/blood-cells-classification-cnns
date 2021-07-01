function [sourcePath, labelsPath, featsPath, modelsPath, classifPath, perfPath] = getPaths()

    if exist('C:\Users\Lorenzo', 'dir')== 7 %%PATH per il PC di Lorenzo
        sep = '\';
        base = 'D:\Repositories\MATLAB\Blood\blood-cells-classification-cnns';
        sourcePath = 'D:\ImmaginiLavoro\Medical\Blood';
    elseif exist('/home/lputzu', 'dir')== 7 %%PATH per Castor
        sep = '/';
        base = '/home/lputzu/Workspaces/MATLAB/Esperimenti/Medical/Blood/blood-cells-classification-cnns';
        sourcePath = '/home/lputzu/Workspaces/MATLAB/Esperimenti/Medical/Blood/dataset';
        addpath(genpath('/home/lputzu/Workspaces/MATLAB/Function'));    
    elseif exist('C:\Users\loand', 'dir')== 7 %%PATH per Castor
        sep = '\';
        base = 'C:\Users\loand\Documents\MATLAB\ALLClassification';
        sourcePath = [base sep 'dataset'];
    end
    labelsPath = [base sep 'Labels']   ;
    featsPath  = [base sep 'Features'];
    modelsPath  = [base sep 'Models'];
    classifPath= [base sep 'Classification'];
    perfPath   = [base sep 'Performances']; 
end

