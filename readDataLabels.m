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
function [timestamp, labels, one_hot] = readDataLabels(filename)
   fileID = fopen(filename,'r');
   
   formatSpec = '%f%C%[^\n\r]';
   dataArray = textscan(fileID, formatSpec, 'Delimiter', ',', 'TextType', 'string',  'ReturnOnError', false);
   
   fclose(fileID);
   
   timestamp = dataArray{:, 1};
   text_label = cellstr(dataArray{:, 2});
   
   % Convert to seconds from starta
   timestamp = timestamp - timestamp(1);
   timestamp = timestamp ./ 1000;
   
   % Convert from to numerical list
   fileData = fileread( "activities.json" );
   activites = jsondecode(fileData);
   activity_number = containers.Map(activites, 1:size(activites, 1));
   
   labels = zeros(size(text_label, 1), 1);
   one_hot = zeros(size(text_label, 1), size(activites, 1));
   
   for i = 2:size(text_label, 1)-1
       labels(i) = activity_number(text_label{i});
       
       one_hot(i, labels(i)) = 1;
   end
end