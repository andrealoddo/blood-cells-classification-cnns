function sortedImages = sortImages(images)

numbers = zeros(1,length(images));
for ii = 1:length(images)
    C = strsplit(images{ii}, '\');    
    C = strsplit(C{end}, '.');
    numbers(ii) = str2num(C{1});
end
[~, a_order] = sort(numbers);
sortedImages = images(a_order);