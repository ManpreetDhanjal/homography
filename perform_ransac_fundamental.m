function [F_mat_opt, inlier_opt] = perform_ransac_fundamental(r1,c1,r2,c2,match1, match2)

    match_size = numel(match1);
    % Get random 8 matches
    iterations = 6000; 
    i = 0;
    F_mat_opt = [];
    thresh = 0.05;
    max_ratio = 0;
    
    while i < iterations
        rand_num = 8;
        randInd = randperm(match_size, rand_num);
        x1 = c1(match1);
        y1 = r1(match1);
        x2 = c2(match2);
        y2 = r2(match2);
        matches = [x1(randInd), y1(randInd), x2(randInd), y2(randInd)];
        F_mat = fit_fundamental(matches,0);
        
        %inliers
        res = abs(diag([x1, y1, ones(size(match1,1),1)] * F_mat * [x2, y2, ones(size(match2,1),1)]'));
        %aa = find(abs(res)>thresh);
        inlier = find(res<thresh);
        inlier_count = size(inlier,1);
        
        if inlier_count/match_size > max_ratio
            max_inlier_count = inlier_count;
            F_mat_opt = F_mat;
            max_ratio = inlier_count/match_size;
            inlier_opt = inlier;
        end
        i = i+1;
    end
    
    %print inlier count & average residual
    disp("Inlier count:");
    disp(max_inlier_count(1,1));
end