function [singles, int32s, uint32s, int16s, uint16s, int8s, uint8s, struct] = readHeader(file)

    fileData = fileread( file );
    struct = jsondecode( fileData );
    
    
    % Print command window header
    date = datetime(struct.date,'InputFormat',struct.dateformat, ...
                                'Format','MMMM d, yyyy HH:mm:SS');
    description = wrapText( struct.description, 40 ); 
    
    fprintf('----------------------------------------\n');
    fprintf( "%s\n", pad(struct.filename) );
    fprintf( "%s\n", date );
    fprintf( "%s\n", description );
    fprintf('----------------------------------------\n');
    
    fields = fieldnames( struct.datafields );
    fieldName = pad( fields, 25 );
    
    
    % Generate data position vectors
    int32s.Bytes   = []; int32s.Elements   = [];
    uint32s.Bytes  = []; uint32s.Elements  = [];
    int16s.Bytes   = []; int16s.Elements   = [];
    uint16s.Bytes  = []; uint16s.Elements  = [];
    int8s.Bytes    = []; int8s.Elements    = [];
    uint8s.Bytes   = []; uint8s.Elements   = [];
    singles.Bytes  = []; singles.Elements  = [];
    
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
                singles.Bytes = [singles.Bytes, arrayStart:byteCount-1];
                singles.Elements = [singles.Elements, elementStart:(elementCount-1)];
                
            case 'int32'
                byteCount = byteCount + 4 * numFields;
                uint32s.Bytes = [int32s.Bytes, arrayStart:byteCount-1];
                uint32s.Elements = [int32s.Elements, elementStart:(elementCount-1)];
                
            case 'uint32'
                byteCount = byteCount + 4 * numFields;
                uint32s.Bytes = [uint32s.Bytes, arrayStart:byteCount-1];
                uint32s.Elements = [uint32s.Elements, elementStart:(elementCount-1)];

            case 'int16'
                byteCount = byteCount + 2 * numFields;
                int16s.Bytes = [int16s.Bytes, arrayStart:byteCount-1];
                int16s.Elements = [int16s.Elements, elementStart:(elementCount-1)];
                
            case 'uint16'
                 byteCount = byteCount + 2 * numFields;
                 uint16s.Bytes = [uint16s.Bytes, arrayStart:byteCount-1];
                 uint16s.Elements = [uint16s.Elements, elementStart:(elementCount-1)];
                 
            case 'int8'
                byteCount = byteCount + 1 * numFields;
                int8s.Bytes = [int8s.Bytes, arrayStart:byteCount-1];
                int8s.Elements = [int8s.Elements, elementStart:(elementCount-1)];
                
            case 'uint8'
                 byteCount = byteCount + 1 * numFields;
                 uint8s.Bytes = [uint8s.Bytes, arrayStart:byteCount-1];
                 uint8s.Elements = [uint8s.Elements, elementStart:(elementCount-1)];
                
        end

        struct.datafields.(fields{i}).elements = elementStart:elementCount-1;
    end
    
    struct.numElements = elementCount - 1;
    
    fprintf('----------------------------------------\n');
end

% Utility function to wrap text after x characters
function [newStr] = wrapText( str, width )
    newStr = [];
    
    for i = 1:length(str)
        if mod( i, width+1 ) == 0
            newStr = [newStr, newline];
        end
        
        newStr = [newStr, str(i)];
    end
end
