function [] = write_binary_matrix(M, path)

fileID = fopen(path, 'w');
fwrite(fileID, size(M), 'int64'); 
fileID = fopen(path, 'a');
fwrite(fileID, M(:)', 'float');