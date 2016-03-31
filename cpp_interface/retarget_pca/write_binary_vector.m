function [] = write_binary_vector(V, path)

fileID = fopen(path, 'w');
fwrite(fileID, length(V), 'int64'); 
fileID = fopen(path, 'a');
fwrite(fileID, V, 'float');