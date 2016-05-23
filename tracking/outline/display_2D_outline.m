function [] = display_2D_outline(segments, circles, outline)

set(gcf,'color','w');
line_width = 4;
for i = 1:length(segments)
    myline(segments{i}.t1, segments{i}.t2, [124, 190, 184]/255, line_width);
end
for i = 1:length(circles)
    if ~isstruct(circles{i}), continue; end
    draw_circle(circles{i}.center, circles{i}.radius, [62, 127, 130]/210, line_width);
end


for i = 1:length(outline)
    if length(outline{i}.indices) == 2
        myline(outline{i}.start, outline{i}.end, [179, 81, 109]/255, line_width);
    else
        draw_circle_sector(circles{outline{i}.indices}.center, circles{outline{i}.indices}.radius, outline{i}.start, outline{i}.end, [179, 81, 109]/255, line_width)
    end
end