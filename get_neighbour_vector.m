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