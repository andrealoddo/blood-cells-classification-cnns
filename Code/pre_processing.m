function pre_processing(datasetName, operation)

    if nargin == 1
        operation = 'tight'; % tight, eroded, dilated, mask, maskEroded, maskDilated, tightMask, tightMaskEroded, tightMaskDilated, 
    end

    if strcmp(operation, 'tight')==1 
        op_name = '\img_tCrop\';
    elseif strcmp(operation, 'eroded')==1 
        op_name = '\img_wrongCrop\';
    elseif strcmp(operation, 'dilated')==1 
        op_name = '\img_wrongCrop2\';
    elseif strcmp(operation, 'mask')==1 
        op_name = '\img_mask\';
    elseif strcmp(operation, 'maskEroded')==1 
        op_name = '\img_wrongMask\';
    elseif strcmp(operation, 'maskDilated')==1 
        op_name = '\img_wrongMask2\';
    elseif strcmp(operation, 'tightMask')==1 
        op_name = '\img_tMask\';
    elseif strcmp(operation, 'tightMaskEroded')==1 
        op_name = '\img_tWrongMask\';
    elseif strcmp(operation, 'tightMaskDilated')==1 
        op_name = '\img_tWrongMask2\';
    end

    if strcmp(datasetName, 'ALL-IDB2')==1 % ALL-IDB2
        base = 'D:\ImmaginiLavoro\Medical\Blood\ALL_IDB\ALL_IDB2';
        img_path = [base '\img'];
        imgmasked_path = [base op_name];
        gt_path = [base '\gt_s']; 
        run_one(img_path, gt_path, imgmasked_path, datasetName, operation);
    else %Raabin
        subdirs = {'Basophil','Eosinophil','Lymphocyte','Monocyte','Neutrophil'};    
        base = 'D:\ImmaginiLavoro\Medical\Blood\Raabin\';
        for sd = 1:numel(subdirs)
            cell = subdirs{sd};
            img_path = [base '\img\' cell];
            imgmasked_path = [base op_name];
            if exist(imgmasked_path, 'dir')== 7
                mkdir(imgmasked_path);
            end
            imgmasked_path = [base op_name cell];
            gt_path = [base '\GT\' cell];
            run_one(img_path, gt_path, imgmasked_path, datasetName, operation);
        end
    end
    
end

%--------------------------------------------------------------------------
function run_one(img_path, gt_path, imgmasked_path, datasetName, operation)

    mkdir(imgmasked_path);
    imds = imageDatastore(fullfile(img_path));
    images = imds.Files;

    for i = 1:size(images,1)
        img = imread(images{i});
        fprintf('%s\n', images{i});
        imgPathSplit = strsplit(images{i},'\\');
        if strcmp(datasetName, 'ALL-IDB2')==1 % ALL-IDB2
            imgNameExt = strsplit(imgPathSplit{end},'.');
            gt = imread([gt_path '\' imgNameExt{1} '_WBC.tif']);
        else %Raabin
            gt = imread([gt_path '\' imgPathSplit{end}]);
        end
        gt = gt(:,:,1);
        gt(gt<10)=0;
        
        if contains(operation,'mask', 'IgnoreCase', true)
            [img, gt] = maskImage(img, gt,  datasetName, operation);
        end
        
        %verifica se l'operazione (non è una di quelle tre) richiede il recrop  
        if sum(strcmp(operation, {'mask', 'maskEroded', 'maskDilated'}))==0
            [up, down, left, right] = getCropCoordinates(gt, datasetName, operation);
            img = img(up:down,left:right,:);
        end
        
        if strcmp(datasetName, 'ALL-IDB2')==1 % ALL-IDB2
            imwrite(img, [imgmasked_path '\' imgNameExt{1} '.png'])
        else %Raabin
            imwrite(img, [imgmasked_path '\' imgPathSplit{end}])
        end
    end
end

%--------------------------------------------------------------------------

function [img, gt] = maskImage(img, gt, datasetName, operation)
    if sum(strcmp(operation, {'mask', 'tightMask'}))==0
        [x,y,~]= size(gt);
        %calcolo un angolo random e creo un SE opportuno
        angle = randi(359);
        if strcmp(datasetName, 'ALL-IDB2')==1 % ALL-IDB2
            dim = 15;
        else %Raabin
            dim = 30;
        end
        se = strel('line',dim,angle);
        se2 = strel('disk',dim);
        %calcolo la porzione di immagine alla quale applicare le modifiche
        slope = angle+90;
        [columnsInImage,rowsInImage] = meshgrid(1:x, 1:y);
        bw = (rowsInImage - (y/2)) + tan(slope) * (columnsInImage - (x/2)) >= 1;
        if contains(operation,'eroded', 'IgnoreCase', true)
            gt2 = imerode(gt,se);
        elseif contains(operation,'dilated', 'IgnoreCase', true)
            gt2 = imdilate(gt,se);
        end
        gt(bw)=gt2(bw);
        gt = imclose(gt,se2);
    end
    img(repmat(gt==0,1,1,3))=0;
end

%--------------------------------------------------------------------------

function [up, down, left, right]= getCropCoordinates(gt, datasetName, operation)

    [x,y,~]= size(gt);
    [m,n] = find(gt>0);

    up = min(m)-2;
    left = min(n)-2;
    down = max(m)+2; 
    right = max(n)+2;

    %se diverso da tight
    if ~contains(operation ,'tight')
        error = num2str(randi(4));
        if strcmp(operation, 'eroded')==1 
            op = 1;
        elseif strcmp(operation, 'dilated')==1 
            op = -1;
        end
        
        if strcmp(datasetName, 'ALL-IDB2')==1 % ALL-IDB2
            op = op * 30;
        else %Raabin
            op = op * 60;
        end
        
         switch error
            case '1'
                up = up + (30*op);
            case '2'
                left = left + (30*op);
            case '3'
                down = down - (30*op);
            case '4'
                right = right - (30*op);
        end
    end
    
    if up < 1
        up = 1;
    end
    if down > y
        down = y;
    end
    if right > x
        right = x;
    end
    if left < 1
        left = 1;
    end
end