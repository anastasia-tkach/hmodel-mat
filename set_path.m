w = warning ('off','all');

absolute_path = ['C:\Users\', getenv('USERNAME'), '\OneDrive\EPFL\Code\'];
%addpath(genpath([absolute_path, 'External']));
absolute_path = [absolute_path, 'HModel\'];
addpath(genpath(absolute_path));

cd(absolute_path);