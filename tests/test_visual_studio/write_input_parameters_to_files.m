function [] = write_input_parameters_to_files(varargin)
path = varargin{1};
for i = 2:length(varargin)
    fid = fopen([path, inputname(i), '.txt'],'wt');
    fprintf(fid,'%d\n', size(varargin{i}, 2));
    fprintf(fid,'%.15g ',varargin{i});
    fclose(fid);
end