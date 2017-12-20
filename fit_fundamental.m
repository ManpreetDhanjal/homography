function F_mat = fit_fundamental(matches, normalise)
    
    num_matches = 8;
    
    % normalise the points
    if normalise == 1
        matches(:,1:2) = zscore(matches(:,1:2));
        matches(:,3:4) = zscore(matches(:,3:4));
    end
    
    pts_1 = [matches(:,1:2) ones(size(matches,1),1)];
    pts_2 = [matches(:,3:4) ones(size(matches,1),1)];
    
    % un normalised
    prod_mat = zeros(num_matches, 9);
    for i = 1:num_matches
        prod_mat(i,:) = [pts_2(i,1)*pts_1(i,:), pts_2(i,2)*pts_1(i,:), pts_1(i,:)];
    end
    
    [U S V] = svd(prod_mat);
    F_mat = V(:,end);
    F_mat = reshape(F_mat,[3,3]);
    
    % rank 2 constraint
    [Uf Sf Vf] = svd(F_mat);
    Sf(3,3) = 0;
    F_mat = Uf*Sf*Vf';
    
end
