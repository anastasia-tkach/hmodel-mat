function [] = write_input_parameters_to_files(varargin)

path = 'C:\Users\tkach\OneDrive\EPFL\Code\HandModel\_cpp\Input\';

for i = 1:length(varargin)
    fid = fopen([path, inputname(i), '.txt'],'wt');
    fprintf(fid,'%d %d\n', size(varargin{i}, 1), size(varargin{i}, 2));
    fprintf(fid,'%.15g ',varargin{i});
    fclose(fid);
end