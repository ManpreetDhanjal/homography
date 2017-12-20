function result = stitch_image()

% 1, 0.5, 2, 21
sigma = 1;
thresh_harris = 0.01;
radius = 1;
neigh_size = 18;

% load image
img1 = imread('../data/part1/uttower/left.jpg');
img2 = imread('../data/part1/uttower/right.jpg');

% to grayscale
img1_gray = rgb2gray(img1);
img2_gray = rgb2gray(img2);

img1_db = im2double(img1_gray);
img2_db = im2double(img2_gray);

% extract features
% x goes down
% y goes sideways
[cim1, r1, c1] = harris(img1_db, sigma, thresh_harris, radius);
[cim2, r2, c2] = harris(img2_db, sigma, thresh_harris, radius);

widthImg1 = size(img1_gray,2);

% display matches
figure; imshow([img1_gray img2_gray]); 
hold on; 
title('Harris Corner detector');
hold on; 
plot(c1,r1,'ys'); 
plot(c2 + widthImg1, r2, 'ys');

% get 5x5 neighbours
n_vector1 = get_neighbour_vector(img1_db, neigh_size, r1, c1);
n_vector2 = get_neighbour_vector(img2_db, neigh_size, r2, c2);

% dist_mat is r1 x r2 mat
% get row vector of min dist
dist_mat = dist2(n_vector1, n_vector2);
%dist_mat = sqrt(dist_mat);
min(min(dist_mat))
% threshold 
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

% display matches
figure; imshow([img1_gray img2_gray]); 
hold on; 
title('Matching featues');
hold on; 
plot(x1,y1,'ys'); 
plot(x2 + widthImg1, y2, 'ys');

%% start of RANSAC
[homo_mat, inlier] = perform_ransac(r1,c1,r2,c2,match1,match2);
%% end of RANSAC iterationss

% display inliers in both images
widthImg1 = size(img1_gray,2);
x1 = c1(match1(inlier));
y1 = r1(match1(inlier));
x2 = c2(match2(inlier));
y2 = r2(match2(inlier));

figure; imshow([img1_gray img2_gray]); 
hold on; 
title('Inliers');
hold on; 
plot(x1,y1,'ys'); 
plot(x2 + widthImg1, y2,'ys');
line([x1,x2+widthImg1]', [y1,y2]');


T = maketform('projective', homo_mat');
trans_img = imtransform(img1_gray,T);
imshow(trans_img);

result = align_image(img1, img2, homo_mat);

end

% size - size of neighbour matrix, should be odd
function neighbours = get_neighbour_vector(img, sz, rows, cols)

    padHelper = zeros(2 * sz + 1); 
    padHelper(sz + 1, sz + 1) = 1;

    % use the pad Helper matrix to pad the img such that the border values
    % extend out by the radius
    paddedImg = imfilter(img, padHelper, 'replicate', 'full');
   
    neighbours = zeros(size(rows,1), sz*sz);

    % use replicate instead
    img_pad = padarray(img, [sz, sz], 'both');
    %mat = zeros(sz,sz);
    for i = 1:size(rows,1)
        if rows(i) < 0 || cols(i) < 0
            neighbours(i,:) = zeros(sz*sz,1);
            continue;
        end
        % change coords coz of padding
        x = rows(i)+floor(sz/2);
        y = cols(i)+floor(sz/2);
        mat = double(paddedImg(x : x + sz-1, y : y + sz-1));
        %mat = img_pad(x : x + sz-1, y : y + sz-1);
        feat = mat(:)';
        neighbours(i,:) = zscore(feat);
        %neighbours(i,:) = mat(:)';
    end
end