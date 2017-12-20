function x = estimate_fundamental_matrix()

    % picked form sample_code.m
    I1 = imread('../data/part2/house1.jpg');
    I2 = imread('../data/part2/house2.jpg');
    matches = load('../data/part2/house_matches.txt'); 
    
    %I1 = imread('../data/part2/library1.jpg');
    %I2 = imread('../data/part2/library2.jpg');
    %matches = load('../data/part2/library_matches.txt');
    
    N = size(matches,1);
    
    imshow([I1 I2]); hold on;
    plot(matches(:,1), matches(:,2), '+r');
    plot(matches(:,3)+size(I1,2), matches(:,4), '+r');
    line([matches(:,1) matches(:,3) + size(I1,2)]', matches(:,[2 4])', 'Color', 'r');

    % first, fit fundamental matrix to the matches
    [F, matches] = fit_fundamental_ransac();
    %F = fit_fundamental(matches, 1); 

    %img2
    calculate_residuals(F, matches, 2, I2);
    
    %img1
    calculate_residuals(F', matches, 1, I1);
    
end

