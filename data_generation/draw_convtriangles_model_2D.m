function [centers, blocks, radii] = draw_convtriangles_model_2D(num_blocks)
blocks = cell(num_blocks, 1);
k = 1;
for b = 1:num_blocks
   
    disp('SELECT PRIMITIVE');
    waitforbuttonpress;
    block_type = get(gcf,'CurrentCharacter');
    if (block_type == 't')
        
        blocks{b} = zeros(3, 1);
        keys = zeros(3, 1);
        
        %% Frontal 
        for i = 1:3
            [x, y, key] = ginput(1);
            keys(i)  = key;
            if key == 1
                centers{k} = [x; y];
                blocks{b}(i) = k;
                hold on; mypoint(centers{k}, 'm');
                [xr, yr] = ginput(1);
                r = norm([x - xr, y - yr]);
                radii{k} = r;
                draw_circle(centers{k}, radii{k}, [1, 0.7, 0]);
                k = k + 1;
            end
            if key == 3
                min_index = -1;
                min_distance = Inf;
                for c = 1:length(centers)
                    d = norm([x; y] - centers{c}(1:2));
                    if (d < min_distance)
                        min_distance = d;
                        min_index = c;
                    end
                end
                blocks{b}(i) = min_index;
                mypoint(centers{min_index}, 'r');
                draw_circle(centers{min_index}, radii{min_index}, 'r');
            end
        end
        myline(centers{blocks{b}(1)}(1:2), centers{blocks{b}(2)}(1:2), 'm');
        myline(centers{blocks{b}(1)}(1:2), centers{blocks{b}(3)}(1:2), 'm');
        myline(centers{blocks{b}(2)}(1:2), centers{blocks{b}(3)}(1:2), 'm');  
    end
    
    if (block_type == 'c')
        
        blocks{b} = zeros(2, 1);
        keys = zeros(2, 1);
        
        %% Frontal projection
        for i = 1:2
            [x, y, key] = ginput(1);
            keys(i)  = key;
            if key == 1
                centers{k} = [x; y];
                blocks{b}(i) = k;
                hold on; mypoint(centers{k}, 'm');
                [xr, yr] = ginput(1);
                r = norm([x - xr, y - yr]);
                radii{k} = r;
                draw_circle(centers{k}, radii{k}, [1, 0.7, 0]);
                k = k + 1;
            end
            if key == 3
                min_index = -1;
                min_distance = Inf;
                for c = 1:length(centers)
                    d = norm([x; y] - centers{c}(1:2));
                    if (d < min_distance)
                        min_distance = d;
                        min_index = c;
                    end
                end
                blocks{b}(i) = min_index;
                mypoint(centers{min_index}, 'r');
                draw_circle(centers{min_index}, radii{min_index}, 'r');
            end
        end
        myline(centers{blocks{b}(1)}(1:2), centers{blocks{b}(2)}(1:2), [1 0.3 0]);       
    end
    
end

centers = centers';
radii = radii';
