function [] = calculate_residuals(F, matches, image_num, I)

    N = size(matches,1);
    % display values for first image
    if image_num == 1
        known_match = matches(:,3:4);
        plot_match = matches(:,1:2);
    else
        known_match = matches(:,1:2);
        plot_match = matches(:,3:4);
    end
    
    % transform points from the first image to get epipolar lines in the second image
    L = (F * [known_match ones(N,1)]')'; 

    % find points on epipolar lines L closest to matches(:,3:4)
    L = L ./ repmat(sqrt(L(:,1).^2 + L(:,2).^2), 1, 3); % rescale the line
    pt_line_dist = sum(L .* [plot_match ones(N,1)],2);
    closest_pt = plot_match - L(:,1:2) .* repmat(pt_line_dist, 1, 2);

    % find endpoints of segment on epipolar line (for display purposes)
    pt1 = closest_pt - [L(:,2) -L(:,1)] * 10; % offset from the closest point is 10 pixels
    pt2 = closest_pt + [L(:,2) -L(:,1)] * 10;

    % display points and segments of corresponding epipolar lines
    clf;
    imshow(I); hold on;
    plot(plot_match(:,1), plot_match(:,2), '+r');
    line([plot_match(:,1) closest_pt(:,1)]', [plot_match(:,2) closest_pt(:,2)]', 'Color', 'r');
    line([pt1(:,1) pt2(:,1)]', [pt1(:,2) pt2(:,2)]', 'Color', 'g');

    % calculate average residuals
    avg_residual = sum(sum((closest_pt - plot_match).^2))/N;
    disp("Average Residual for image:");
    disp(avg_residual);

end