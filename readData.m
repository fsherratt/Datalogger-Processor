%{
% Function name - Read data and converts data saved in a hexadecimal format
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
function [data, split] = readData( dataFile, headerStruct )
tic

fprintf( "Opening file: %s\n", reduceTextLength(dataFile, 66) );

% Import data from file
fileData_full = fileread( dataFile );
fileData_full = strsplit(fileData_full, {'-', '\n'});
fileData_full = reshape(fileData_full(1:end-1), 8, [])';

android_timestamp = str2num(cell2mat( fileData_full(:, 1)));
device = convertCharsToStrings( fileData_full(:, 2));
characteristic = str2double( fileData_full(:,3));

fileData = cell2mat( fileData_full(:, end ));

% Split into Timestamp, Device, UUID, Data
fileData = fileData(:, 1:end );

% Split data file into individual hex pairs matrix
dim = size( fileData );
strPairs = reshape( fileData, dim(1), 2, dim(2)/2);
strPairs = permute( strPairs, [1, 3, 2] );

% Reshape hex pairs into 2d matrix
dim = size( strPairs );
strPairs = reshape( strPairs, dim(1) * dim(2), 2 );

% Convert hex chars to bytes and reshape back to original form
bytes = hex2dec( strPairs );
bytes = uint8( reshape( bytes, dim(1), dim(2) ) );


%% Typecast all data back to original form
[int32s] = typecastBytes( bytes( :, headerStruct.int32.Bytes ), 'int32' );
[uint32s] = typecastBytes( bytes( :, headerStruct.uint32.Bytes ), 'uint32' );
[singles] = typecastBytes( bytes( :, headerStruct.single.Bytes ), 'single' );
[int16s]  = typecastBytes( bytes( :, headerStruct.int16.Bytes  ), 'int16'  );
[uint16s]  = typecastBytes( bytes( :, headerStruct.uint16.Bytes  ), 'uint16'  );
[int8s]  = typecastBytes( bytes( :, headerStruct.int8.Bytes  ), 'int8'  );
[uint8s]  = typecastBytes( bytes( :, headerStruct.uint8.Bytes  ), 'uint8'  );

% Combine into single matrix
data = zeros( length(bytes), headerStruct.numElements );
data( :, headerStruct.int32.Elements ) = double( int32s );
data( :, headerStruct.uint32.Elements ) = double( uint32s );
data( :, headerStruct.single.Elements ) = double( singles );
data( :, headerStruct.int16.Elements ) = double( int16s );
data( :, headerStruct.uint16.Elements ) = double( uint16s );
data( :, headerStruct.int8.Elements ) = double( int8s );
data( :, headerStruct.uint8.Elements ) = double( uint8s );


%% Sort data into seperate vectors for each data field
split = [];
fields = fieldnames( headerStruct.datafields );

for i = 1:numel(fields)
    elements = headerStruct.datafields.(fields{i}).elements;
    split.(fields{i}) = data( :, elements );
end

split.androidTime = android_timestamp;
split.device = device;
split.characteristic = characteristic;


%% Print results
fprintf( "Succesfully imported %d rows of data in %0.2f seconds\n", length(data), toc );
fprintf('--------------------------------------------------------------------------------\n');


end


%% convertBytes - Rapid typecast function
function [data] = typecastBytes( bytes, type )
    % Repeat for unsigned int elements
    dim = size( bytes );
%     bytes = fliplr(bytes);
    bytes = reshape( bytes', 1, dim(1) * dim(2) );
    
    data = typecast( bytes, type );
    data = reshape( data, [], dim(1) )';
%     data = swapbytes( data );
end


%% EOF
