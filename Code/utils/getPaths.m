function [sourcePath, labelsPath, featsPath, modelsPath, classifPath, perfPath, confPath] = getPaths()

    if exist('C:\Users\Lorenzo', 'dir')== 7 %%PATH per il PC di Lorenzo
        sep = '\';
        base = 'D:\Repositories\MATLAB\Blood\blood-cells-classification-cnns';
        sourcePath = 'D:\ImmaginiLavoro\Medical\Blood';
    elseif exist('/home/lputzu', 'dir')== 7 %%PATH per Castor
        sep = '/';
        base = '/home/lputzu/Workspaces/MATLAB/Esperimenti/Medical/Blood/blood-cells-classification-cnns';
        sourcePath = '/home/lputzu/Workspaces/MATLAB/Esperimenti/Medical/Blood/dataset';
        addpath(genpath('/home/lputzu/Workspaces/MATLAB/Function'));    
    elseif exist('C:\Users\loand', 'dir')== 7 %%PATH per il PC di Andrea
        sep = '\';
        %base = 'C:\Users\loand\Documents\MATLAB\ALLClassification';
        base = 'C:\Users\loand\Documents\GitHub\Blood\blood-cells-classification-cnns';
        sourcePath = 'C:\Users\loand\Documents\GitHub\Blood\dataset';
    end
    
    labelsPath = [base sep 'Labels'];
    featsPath  = [base sep 'Features'];
    modelsPath = [base sep 'Models'];
    classifPath= [base sep 'Classification'];
    perfPath   = [base sep 'Performances']; 
    confPath   = [base sep 'ConfusionMatrices']; 
    
	if( isfolder(labelsPath) == 0)
        mkdir(labelsPath);
	end    
	if( isfolder(featsPath) == 0)
        mkdir(featsPath);
	end    
	if( isfolder(modelsPath) == 0)
        mkdir(modelsPath);
	end    
	if( isfolder(classifPath) == 0)
        mkdir(classifPath);
	end    
	if( isfolder(perfPath) == 0)
        mkdir(perfPath);
	end
	if( isfolder(confPath) == 0)
        mkdir(confPath);
	end
    
end

