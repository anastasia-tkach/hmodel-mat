function [] = write_blocks_to_file(path, blocks)

fid = fopen([path, 'blocks.txt'],'wt');

for i = 1:length(blocks)
    for j = 1:length(blocks{i})
        fprintf(fid,'%d ', blocks{i}(j));
    end    
    fprintf(fid,'\n');
end
fclose(fid);