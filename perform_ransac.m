function [homo_mat_opt, inlier_opt] = perform_ransac(r1,c1,r2,c2,match1, match2)
    
    % total number of matches
    match_size = numel(match1);
    
    % optimal values
    max_ratio = 0;
    max_inlier_count = 0;
    inlier_opt = [];
    homo_mat_opt = [];
    max_avg_residual = 0;
    
    % iterations
    max_iter = 1000;
    iter = 0;
    
    while iter < max_iter
        % get 4 random points
        rand_num = 4;
        randInd = randperm(match_size, rand_num);

        % create input matrix 2n x 9 = 8 x 9 (n = 4)
        input_mat = zeros(2*rand_num, 9);
        for i=1:rand_num

            x1 = c1(match1(randInd(i)));
            y1 = r1(match1(randInd(i)));
            x2 = c2(match2(randInd(i)));
            y2 = r2(match2(randInd(i)));

           input_mat((2*i)-1,:) = [x1, y1, 1, 0, 0, 0, -x2 * x1, -x2 * y1, -x2];
           input_mat((2*i),:) = [0, 0, 0, x1, y1, 1, -y2 * x1, -y2 * y1, -y2];

        end

        [U, S, V] = svd(input_mat);

        % reshape to 3x3 matrix & set (3,3) = 1
        homo_mat = reshape(V(:,end), [3,3]);
        homo_mat = homo_mat' ./ homo_mat(3,3);

        % stack corresponding points of matches in 2 matrices
        match_mat_1 = zeros(size(match1,1),3);
        match_mat_2 = zeros(size(match2,1),3);

        match_mat_1(:,1) = c1(match1);
        match_mat_1(:,2) = r1(match1);
        match_mat_1(:,3) = ones(size(match1,1),1);

        match_mat_2(:,1) = c2(match2);
        match_mat_2(:,2) = r2(match2);
        match_mat_2(:,3) = ones(size(match2,1),1);

        % estimated output
        est_output = homo_mat * match_mat_1';

        % divide by weight component
        for i=1:size(est_output,2)
            est_output(:,i) = round(est_output(:,i)./est_output(3,i));
        end

        %calculate distance
        dist = sqrt(diag(dist2(est_output', match_mat_2)));
        
        % threshold to get outliers
        thresh_outliers = 5;
        inlier = find(dist <= thresh_outliers);
        inlier_count = size(inlier);
        ratio = size(inlier,1)/size(match_mat_1,1)
        
        if ratio > max_ratio
            max_inlier_count = inlier_count;
            max_ratio = ratio;
            homo_mat_opt = homo_mat;
            inlier_opt = inlier;
            est_output = est_output';
            dist = diag(dist2(est_output(inlier,:), match_mat_2(inlier,:)));
            max_avg_residual = sum(dist(:))./max_inlier_count(1,1);
        end
        
        iter = iter + 1;
        
    end
    
    disp("Inlier Count:");
    disp(max_inlier_count(1,1));
    disp("Ratio:");
    disp(max_ratio);
    disp("Average Residual:");
    disp(max_avg_residual);
end
