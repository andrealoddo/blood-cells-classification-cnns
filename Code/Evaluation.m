function [ACC,P,R,TNR,F1] = Evaluation(TP,TN,FP,FN)

ACC = (TP + TN)/(TP + FP+ TN + FN);
P = TP/(TP+FP+eps);%Positive Predicte Value (PPV)
R = TP/(TP+FN+eps);%sensitivity, TPR
TNR = TN/(TN+FP+eps);%specificity, TNR
F1 = (2*P*R)/(P+R+eps);