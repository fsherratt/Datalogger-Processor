%% read_data
% Read data and converts data saved in a hexadecimal format
function [data, split, struct] = readData( fileName )
tic

% Import data from file
fileData_full = fileread( [fileName, '.txt'] );
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

clear fileData dim strPairs


%% Typecast all data back to original form
% Read JSON header file to determine which bytes form each element
fileName = 'test-data';
[singleArray, uint32Array, int16Array, struct] = readHeader( [fileName, '.json'] );

[uint32s] = typecastBytes( bytes( :, uint32Array.Bytes ), 'uint32' );
[singles] = typecastBytes( bytes( :, singleArray.Bytes ), 'single' );
[int16s]  = typecastBytes( bytes( :, int16Array.Bytes  ), 'int16'  );


% Combine into single matrix
data = zeros( length(bytes), struct.numElements );
data( :, uint32Array.Elements ) = double( uint32s );
data( :, singleArray.Elements ) = double( singles );
data( :, int16Array.Elements ) = double( int16s );

clear fileName bytes int16Array singleArray uint32Array singles int16s uint32s


%% Sort data into seperate vectors for each data field
split = [];
fields = fieldnames( struct.datafields );

for i = 1:numel(fields)
    elements = struct.datafields.(fields{i}).elements;
    split.(fields{i}) = data( :, elements );
end

split.androidTime = android_timestamp;
split.device = device;
split.characteristic = characteristic;

clear fields i elements


%% Print results
fprintf( "Succesfully imported %d data rows\n", length(data) );
fprintf( "In %0.2f seconds \n", toc );
fprintf('----------------------------------------\n');

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
