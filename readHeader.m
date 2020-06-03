%{
% Function name - Short description
% Long description
%
% Inputs: 
%   var1 - description
%
% Outputs:
%   rtn1 - description
%
% Other m-files required: 
% Subfunctions: 
% MAT-files required: 
%
% See also: fcn2
%
% Author: Freddie Sherratt
% University of Bath
% email: F.W.Sherratt@bath.ac.uk
% Website: fsherratt.dev
% Sep 2018; Last revision: 22-Jan-2020
%}
function [struct] = readHeader(file)

    if nargin < 1 || isempty(file)
        warning('readHeader: No header file specified, using default header file');
        input('Press Enter to continue')
        file = 'data_structure.json';
    end

    fileData = fileread( file );
    struct = jsondecode( fileData );
    
    
    % Print command window header
    fprintf('--------------------------------------------------------------------------------\n');
    fprintf('Loading header file\n');
    fprintf( "%s\n", reduceTextLength(file, 66) );
    fprintf('--------------------------------------------------------------------------------\n');
    
    fields = fieldnames( struct.datafields );
    fieldName = pad( fields, 25 );
    
    % Generate data position vectors
    struct.int32.Bytes   = []; struct.int32.Elements   = [];
    struct.uint32.Bytes  = []; struct.uint32.Elements  = [];
    struct.int16.Bytes   = []; struct.int16.Elements   = [];
    struct.uint16.Bytes  = []; struct.uint16.Elements  = [];
    struct.int8.Bytes    = []; struct.int8.Elements    = [];
    struct.uint8.Bytes   = []; struct.uint8.Elements   = [];
    struct.single.Bytes  = []; struct.single.Elements  = [];
    
    % Generate byte location vectors for each variable type and mark the
    % location of data elements pertaining to each field
    byteCount = 1;
    elementCount = 1;
    for i = 1:numel(fields)
        dataType = struct.datafields.(fields{i}).type;
        numFields = struct.datafields.(fields{i}).fields;

        fprintf( "%s (%2d x %6s )\n", fieldName{i}, numFields, dataType );

        arrayStart = byteCount;
        elementStart = elementCount;
        elementCount = elementCount + numFields;
        
        switch dataType
            case 'single'
                byteCount = byteCount + 4 * numFields;
                struct.single.Bytes = [struct.single.Bytes, arrayStart:byteCount-1];
                struct.single.Elements = [struct.single.Elements, elementStart:(elementCount-1)];
                
            case 'int32'
                byteCount = byteCount + 4 * numFields;
                struct.uint32.Bytes = [struct.int32.Bytes, arrayStart:byteCount-1];
                struct.uint32.Elements = [struct.int32.Elements, elementStart:(elementCount-1)];
                
            case 'uint32'
                byteCount = byteCount + 4 * numFields;
                struct.uint32.Bytes = [struct.uint32.Bytes, arrayStart:byteCount-1];
                struct.uint32.Elements = [struct.uint32.Elements, elementStart:(elementCount-1)];

            case 'int16'
                byteCount = byteCount + 2 * numFields;
                struct.int16.Bytes = [struct.int16.Bytes, arrayStart:byteCount-1];
                struct.int16.Elements = [struct.int16.Elements, elementStart:(elementCount-1)];
                
            case 'uint16'
                 byteCount = byteCount + 2 * numFields;
                 struct.uint16.Bytes = [struct.uint16.Bytes, arrayStart:byteCount-1];
                 struct.uint16.Elements = [struct.uint16.Elements, elementStart:(elementCount-1)];
                 
            case 'int8'
                byteCount = byteCount + 1 * numFields;
                struct.int8.Bytes = [struct.int8.Bytes, arrayStart:byteCount-1];
                struct.int8.Elements = [struct.int8.Elements, elementStart:(elementCount-1)];
                
            case 'uint8'
                 byteCount = byteCount + 1 * numFields;
                 struct.uint8.Bytes = [struct.uint8.Bytes, arrayStart:byteCount-1];
                 struct.uint8.Elements = [struct.uint8.Elements, elementStart:(elementCount-1)];
                
        end

        struct.datafields.(fields{i}).elements = elementStart:elementCount-1;
    end
    
    struct.numElements = elementCount - 1;
    
    fprintf('--------------------------------------------------------------------------------\n');
end

function [name] = reduceTextLength(text, maxLength)
    
    if ( length(text) < maxLength )
        name = text;
    else
        split = floor(maxLength/2)-2;
        name = [text(1:split), '...', text(end-split:end)];
        
%         name = ['...', text(end-maxLength+4:end)];
    end

end

% EOF
