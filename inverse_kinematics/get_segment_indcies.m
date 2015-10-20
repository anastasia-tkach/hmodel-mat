function [segment_indices] = get_segment_indcies(block_indices, mode)

switch mode
    case 'finger'
        block_to_segment(1) = 1;
        block_to_segment(2) = 2;
        block_to_segment(3) = 3;
    case 'hand'
        
        block_to_segment(1) = 7;
        block_to_segment(2) = 6;
        block_to_segment(3) = 5;
        block_to_segment(4) = 10;
        block_to_segment(5) = 9;
        block_to_segment(6) = 8;
        block_to_segment(7) = 13;
        block_to_segment(8) = 12;
        block_to_segment(9) = 11;
        block_to_segment(10) = 16;
        block_to_segment(11) = 15;
        block_to_segment(12) = 14;
        block_to_segment(13) = 4;
        block_to_segment(14) = 3;
        block_to_segment(15) = 2;
        block_to_segment(16) = 1;
        block_to_segment(17) = 1;
        block_to_segment(18) = 1;
        block_to_segment(19) = 1;
        block_to_segment(20) = 1;
        block_to_segment(21) = 1;
        block_to_segment(22) = 1;
end

segment_indices = zeros(length(block_indices), 1);
for i = 1:length(block_indices)
    segment_indices(i) = block_to_segment(block_indices{i});
end


