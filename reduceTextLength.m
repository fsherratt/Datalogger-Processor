function [name] = reduceTextLength(text, maxLength)
    
    if ( length(text) < maxLength )
        name = text;
    else
        split = floor(maxLength/2)-2;
        name = [text(1:split), '...', text(end-split:end)];
        
%         name = ['...', text(end-maxLength+4:end)];
    end

end