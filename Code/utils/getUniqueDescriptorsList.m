function [descriptors] = getUniqueDescriptorsList(descriptors_sets)
    
    % In case of descriptors combinations, returns the list of single
    % descriptors to compute further.
    % INPUT: 'HM-LMGS_5-CHdue_5'
    % OUTPUT: 'HM', 'LMGS_5', 'CHdue_5'
    descriptors = {};
    for dsc_set = 1:numel(descriptors_sets)
        C = strsplit(descriptors_sets{dsc_set},'-');
        descriptors = [descriptors, C];
    end
    
    descriptors = unique(descriptors);

end

