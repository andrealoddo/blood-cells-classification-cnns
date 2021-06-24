function [outputArg1,outputArg2] = getPaths()

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
    elseif exist('C:\Users\loand', 'dir')== 7 %%PATH per Castor
        sep = '\';
        base = 'C:\Users\loand\Documents\MATLAB\ALLClassification';
        sourcePath = [base sep 'dataset'];
        labelsPath = [base sep 'Labels']   ;
        featsPath  = [base sep 'Features'];
        modelsPath  = [base sep 'Models'];
        classifPath= [base sep 'Classification'];
        perfPath   = [base sep 'Performances']; 
    end

end

