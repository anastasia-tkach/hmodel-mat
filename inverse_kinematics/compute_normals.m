function normals = compute_normals(points, settings)

num_neighbors = 10;

%if settings.skeleton == true, points = points(:, 1:2); end

points_tree = KDTreeSearcher(points); % kd-tree data structure
neighs = points_tree.knnsearch(points,'k', num_neighbors); % local neighbors query
neighs = num2cell(neighs,2); % cell contains neighbors
demeaned = cellfun(@(X)( points(X,:)-repmat(mean(points(X,:)),[numel(X),1]) ), neighs, 'UniformOutput',false);
covs = cellfun(@(X)( X'*X ), demeaned, 'UniformOutput',false); %covariance matrixes
[Us,~,~] = cellfun(@(X)( svd(X) ), covs, 'UniformOutput',false); % eigenvectors
normals = cellfun(@(X)(X(:,end)'), Us, 'UniformOutput', false); % normals
normals = cell2mat(normals); % convert cell back to array

if settings.D == 2, normals(:, 3) = 0; end