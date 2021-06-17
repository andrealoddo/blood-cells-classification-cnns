function [TP,TN,FP,FN] = avgCF(confusion)
    confusion = confusion';
    confusion = double(confusion);
    % The input 'confusion' is the the output of the Matlab function
    % 'confusionmat'

    % confusion: 3x3 confusion matrix
    TP = 0;
    FP = 0;
    FN = 0;
    TN = 0;
    disp("conf matrix size")
    len = size(confusion, 1)
    
    if len == 2 %nel caso di problema binario prendiamo solo la prima classe
        disp("ciao")
        len = 1;
    end
    for k = 1:len
        % True positives                           % | x o o |
        tp_value = confusion(k,k);                 % | o o o |
        TP = TP + tp_value;                        % | o o o |

        % False positives                          % | o x x |
        fp_value = sum(confusion(k,:)) - tp_value; % | o o o |
        FP = FP + fp_value;                        % | o o o |

        % False negatives                          % | o o o |
        fn_value = sum(confusion(:,k)) - tp_value; % | x o o |
        FN = FN + fn_value;                        % | x o o |

        % True negatives (all the rest)                                    % | o o o |
        tn_value = sum(sum(confusion)) - (tp_value + fp_value + fn_value); % | o x x |
        TN = TN + tn_value;                                                % | o x x |
    end    
end