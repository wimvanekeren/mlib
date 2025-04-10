function s = array(matrix, format)
% latex array from numerical array
%
% Wim van Ekeren, 2016

s = '';

width = size(matrix, 2);
height = size(matrix, 1);

if isnumeric(matrix)
    matrix = num2cell(matrix);
    for h=1:height
        for w=1:width
            matrix{h, w} = num2str(matrix{h, w},format);
        end
    end
end


for h=1:height
    for w=1:width-1
        if isnumeric(matrix{h, w})
            matrix{h, w} = num2str(matrix{h, w},format);
        end
        s = [s,sprintf('%s\t&', matrix{h, w})];
    end
    if isnumeric(matrix{h, width})
        matrix{h, width} = num2str(matrix{h, width},format);
    end
    s = [s,sprintf('%s\\\\\r\n', matrix{h, width})];
end
