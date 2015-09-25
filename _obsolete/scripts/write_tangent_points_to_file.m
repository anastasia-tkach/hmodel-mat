function [] = write_tangent_points_to_file(tangent_points)
path = 'C:\Users\tkach\OneDrive\EPFL\Code\HandModel\_cpp\Input\';
fid = fopen([path, 'tangent_points.txt'],'wt');

for i = 1:length(tangent_points) 
    if (~isempty(tangent_points{i}))       
        fprintf(fid,'%.15g ', tangent_points{i}.v1);
        fprintf(fid,'%.15g ', tangent_points{i}.v2);
        fprintf(fid,'%.15g ', tangent_points{i}.v3);
        fprintf(fid,'%.15g ', tangent_points{i}.u1);
        fprintf(fid,'%.15g ', tangent_points{i}.u2);
        fprintf(fid,'%.15g ', tangent_points{i}.u3);        
    end
    fprintf(fid,'\n');
end
fclose(fid);