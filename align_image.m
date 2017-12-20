function aligned_img = align_image(img1, img2, homo_mat)
    
    % get the corners of the image
    [h1, w1, c1] = size(img1);
    [h2, w2, c2] = size(img2);
    corners1 = [ 1 1 1; w1 1 1; w1 h1 1; 1 h1 1]; 
    
    % get the estimated values of corners in the tranformed image
    trans_corners = homo_mat * corners1';
    trans_corners = floor(trans_corners ./ repmat(trans_corners(3,:),3,1));

    % the minimum & maximum values give the size of panorama
    minX = min(min(trans_corners(1,:)),1);
    maxX = max(max(trans_corners(1,:)),w2);
    minY = min(min(trans_corners(2,:)),1);
    maxY = max(max(trans_corners(2,:)),h2);
    
    [row,col] = meshgrid(minX : maxX, minY : maxY);
    
    % transform the image1 using homo_mat
    T = maketform('projective', homo_mat');
    trans_img = imtransform(img1,T);
    
    %right_img = interp2(im2double(img2, row, col, 'cubic'));
    right_img_r = interp2(im2double(img2(:,:,1)), row, col, 'cubic');
    right_img_g = interp2(im2double(img2(:,:,2)), row, col, 'cubic');
    right_img_b = interp2(im2double(img2(:,:,3)), row, col, 'cubic');
    right_img = cat(3, right_img_r, right_img_g, right_img_b);
    right_img(isnan(right_img)) = 0;
    
    x_offset = size(right_img_r,2) - size(trans_img,2);
    y_offset = size(right_img_r,1) - size(trans_img,1);
    
    left_img = im2double(padarray(trans_img, [y_offset,x_offset], 'post'));
    
    aligned_img = left_img + right_img;
    overlap = left_img & right_img;
    aligned_img(overlap) = aligned_img(overlap)/2;
    
    imshow(aligned_img);
end