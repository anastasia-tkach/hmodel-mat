function [v] = pick_closest_direction(u, v, mode)

alpha = myatan2(u);
beta1 = myatan2(v);
beta2 =  myatan2(-v);

switch mode
    case 'clockwise'
        alpha_before = alpha;
        while alpha < beta1
            alpha = alpha + 2 * pi;
        end
        delta1 =  alpha - beta1;
        alpha = alpha_before;
        while alpha < beta2
            alpha = alpha + 2 * pi;
        end        
        delta2 =  alpha - beta2;
        if delta2 < delta1            
            v = -v;
        end
    case 'counter'
        while beta1 < alpha
            beta1 = beta1 + 2 * pi;
        end
        while beta2 < alpha
            beta2 = beta2 + 2 * pi;
        end
        delta1 =  beta1 - alpha;
        delta2 =  beta2 - alpha;
        if delta2 < delta1            
            v = -v;
        end
end

