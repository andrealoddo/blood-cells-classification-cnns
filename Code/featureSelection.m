function selected = featureSelection(featSel, features, labels, sel_perc)

featnum = size(features,2)*(sel_perc/100);

switch featSel
    case 'kNN'
        c2 = cvpartition(labels,'k',10);% Create a cvpartition object that defined the folds
        opts = statset('display','iter');% Set options
        fun = @(Xtrain,Ytrain,Xtest,Ytest) sum(Ytest~=predict(ClassificationKNN.fit(Xtrain,Ytrain,'NumNeighbors',1),Xtest));
        selected = sequentialfs(fun,features,labels,'cv',c2,'options',opts,'nfeatures',featnum,'direction','forward');
    case 'NB'
        c2 = cvpartition(labels,'k',10);% Create a cvpartition object that defined the folds
        opts = statset('display','iter');% Set options
        fun = @(Xtrain,Ytrain,Xtest,Ytest) sum(Ytest~=predict(NaiveBayes.fit(Xtrain,Ytrain,'Distribution','kernel'),Xtest));
        selected = sequentialfs(fun,features,labels,'cv',c2,'options',opts,'nfeatures',featnum,'direction','forward');
    case 'tree'
        c2 = cvpartition(labels,'k',10);% Create a cvpartition object that defined the folds
        opts = statset('display','iter');% Set options
        fun = @(Xtrain,Ytrain,Xtest,Ytest) sum(Ytest~=predict(ClassificationTree.fit(Xtrain,Ytrain),Xtest));
        selected = sequentialfs(fun,features,labels,'cv',c2,'options',opts,'nfeatures',featnum,'direction','forward');
    case 'RF'
        c2 = cvpartition(labels,'k',10);% Create a cvpartition object that defined the folds
        opts = statset('display','iter');% Set options
        fun = @(Xtrain,Ytrain,Xtest,Ytest) sum(Ytest~=str2double(predict(TreeBagger(10,Xtrain,Ytrain),Xtest)));
        selected = sequentialfs(fun,features,labels,'cv',c2,'options',opts,'nfeatures',featnum,'direction','forward');
    case 'rank' %fast process
        selected = rankfeatures(features',labels','Criterion','ttest','NumberOfIndices', featnum);
    case 'relieff' %fast process
        [rank,~] = relieff(features,labels,10,'method','classification');
        selected = rank(1:featnum);
end