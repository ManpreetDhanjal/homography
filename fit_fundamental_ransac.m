function [F_mat, matches] = fit_fundamental_ransac()

    sigma = 1;
    thresh_harris = 0.05;
    radius = 1;
    neigh_size = 6;
    
    img1 = imread('../data/part2/house1.jpg');
    img2 = imread('../data/part2/house2.jpg');
    
    %img1 = imread('../data/part2/library1.jpg');
    %img2 = imread('../data/part2/library2.jpg');
    
    img1_gray = rgb2gray(img1);
    img2_gray = rgb2gray(img2);

    img1_db = im2double(img1_gray);
    img2_db = im2double(img2_gray);

    [cim1, r1, c1] = harris(img1_db, sigma, thresh_harris, radius);
    [cim2, r2, c2] = harris(img2_db, sigma, thresh_harris, radius);

    % get 5x5 neighbours
    n_vector1 = get_neighbour_vector(img1_db, neigh_size, r1, c1);
    n_vector2 = get_neighbour_vector(img2_db, neigh_size, r2, c2);

    % dist_mat is r1 x r2 mat
    % get row vector of min dist
    dist_mat = dist2(n_vector1, n_vector2);
    %dist_mat = sqrt(dist_mat);
    min(min(dist_mat))
    
    [~,distance_idx] = sort(dist_mat(:), 'ascend');
    %[match1, match2] = find(dist_mat < thresh);
    bestMatches = distance_idx(1:200);
    [match1, match2] = ind2sub(size(dist_mat), bestMatches);
    %[match1, match2] = find(dist_mat<thresh);
    
    widthImg1 = size(img1_gray,2);
    x1 = c1(match1);
    y1 = r1(match1);
    x2 = c2(match2);
    y2 = r2(match2);

    %display an overlay of the features ontop of the image
    figure; imshow([img1_gray img2_gray]); 
    hold on; 
    title('Overlay detected features (corners)');
    hold on; 
    plot(x1,y1,'ys'); 
    plot(x2 + widthImg1, y2, 'ys');

    [F_mat, inlier] = perform_ransac_fundamental(r1,c1,r2,c2,match1,match2);
    matches = [c1(match1(inlier)), r1(match1(inlier)), c2(match2(inlier)), r2(match2(inlier))];
end