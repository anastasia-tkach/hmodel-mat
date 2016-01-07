function [] = display_edge_stretching(poses, blocks, history)

%% Display change in length by pose
for p = 1:length(poses)
    poses{p}.edges_length = [];
    poses{p}.restpose_edges_length = [];
    count = 1;
    for b = 1:length(blocks)
        indices = nchoosek(blocks{b}, 2);
        index1 = indices(:, 1);
        index2 = indices(:, 2);
        for l = 1:length(index1)
            i = index1(l);
            j = index2(l);
            poses{p}.edges_length(count) = norm(poses{p}.centers{i} -  poses{p}.centers{j});
            poses{p}.restpose_edges_length(count) = norm(poses{p}.initial_centers{i} -  poses{p}.initial_centers{j});
            count = count + 1;
        end
    end
    figure; hold on;
    stem(poses{p}.edges_length, 'filled', 'lineWidth', 2);
    stem(poses{p}.restpose_edges_length, 'filled', 'lineWidth', 2);
    ylim([0, 3]); drawnow;
end

%% Color code length change
v = 0.6;
for p = 1:length(poses)
    
    ratio = poses{p}.restpose_edges_length ./ poses{p}.edges_length;
    difference = ratio - 1;
    difference = difference / max(abs(difference));
    figure; hold on; axis equal; axis off;
    count = 1;
    for b = 1:length(blocks)        
 
        indices = nchoosek(blocks{b}, 2);
        index1 = indices(:, 1);
        index2 = indices(:, 2);
        
        for l = 1:length(index1),
            i = index1(l);
            j = index2(l);
            c1 = poses{p}.centers{i};
            c2 = poses{p}.centers{j};
            
            if difference(count) < 0
                t = -difference(count);
                R = v + (1 - v) * t;
                G = v * (1 - t);
                B = v * (1 - t);
            else
                t = difference(count);
                B = v + (1 - v) * t;
                G = v * (1 - t);
                R = v * (1 - t);
            end
            count = count + 1;
            if length(blocks{b}) == 2 && b > 15, continue; end
            line([c1(1), c2(1)], [c1(2), c2(2)], [c1(3), c2(3)], 'color', [R, G, B], 'lineWidth', 7);            
        end
    end
end

%% Display change dynamics
for h = 1:length(history)
    for p = 1:length(poses)
        history{h}.poses{p}.edges_length = [];
        history{h}.poses{p}.restpose_edges_length = [];
        count = 1;
        for b = 1:length(blocks)
            indices = nchoosek(blocks{b}, 2);
            index1 = indices(:, 1);
            index2 = indices(:, 2);
            for l = 1:length(index1)
                i = index1(l);
                j = index2(l);
                history{h}.poses{p}.edges_length(count) = norm(history{h}.poses{p}.centers{i} -  history{h}.poses{p}.centers{j});
                history{h}.poses{p}.restpose_edges_length(count) = norm(history{h}.poses{p}.initial_centers{i} -  history{h}.poses{p}.initial_centers{j});
                count = count + 1;
            end
        end
    end
end
for p = 1:length(poses)
    M = zeros(length(poses{p}.restpose_edges_length), length(history));
    for h = 1:length(history)
        M(:, h) = history{h}.poses{p}.restpose_edges_length ./ history{h}.poses{p}.edges_length;
    end
    figure; hold on; plot(M', 'lineWidth', 2);
end