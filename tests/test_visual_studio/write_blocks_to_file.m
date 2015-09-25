function [] = write_blocks_to_file(blocks)

path = 'C:\Users\tkach\OneDrive\EPFL\Code\HandModel\_cpp\Input\';
fid = fopen([path, 'blocks.txt'],'wt');

for i = 1:length(blocks)
    for j = 1:length(blocks{i})
        fprintf(fid,'%d ', blocks{i}(j));
    end    
    fprintf(fid,'\n');
end
fclose(fid);