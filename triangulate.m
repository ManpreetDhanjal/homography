function x = triangulate()
    
    matches = load('../data/part2/house_matches.txt'); 
    
    P1 = load('../data/part2/house1_camera.txt');
    P2 = load('../data/part2/house2_camera.txt');
    
    % calculate centers
    [U, S, V] = svd(P1);
    c1 = V(:,end);
    c1 = c1/c1(4,1);
    c1 = c1(1:3,:);
    
    [U, S, V] = svd(P2);
    c2 = V(:,end);
    c2 = c2/c2(4,1);
    c2 = c2(1:3,:);
    
    pts_3D = zeros(size(matches,1), 3);
    A_mat = zeros(4,4);
    for i=1:size(matches,1)
        A_mat(1,:) = matches(i,1) * P1(3,:) - P1(1,:);
        A_mat(2,:) = matches(i,2) * P1(3,:) - P1(2,:);
        A_mat(3,:) = matches(i,3) * P2(3,:) - P2(1,:);
        A_mat(4,:) = matches(i,4) * P2(3,:) - P2(2,:);
        
        [U S V] = svd(A_mat);
        temp = V(:,end)';
        temp = temp/temp(1,4);
        temp = temp(1,1:3);
        pts_3D(i,:) = temp;
    end
    
    c1t = c1';
    c2t = c2';
    for i=1:size(matches,1)
        X = [c1t(1,1); pts_3D(i,1)];
        Y = [c1t(1,2); pts_3D(i,2)];
        Z = [c1t(1,3); pts_3D(i,3)];
        plot3(X, Y, Z, '-+');
        hold on;
        
        X = [c2t(1,1); pts_3D(i,1)];
        Y = [c2t(1,2); pts_3D(i,2)];
        Z = [c2t(1,3); pts_3D(i,3)];
        plot3(X, Y, Z,'-+');
        hold on;
    end
    
    % residual for camera1
    match1 = [matches(:,1:2), ones(size(matches,1),1)];
    match2 = [matches(:,3:4), ones(size(matches,1),1)];
    
    res1 = sum(sum((match1 - pts_3D).^2))/size(matches,1);
    res2 = sum(sum((match2 - pts_3D).^2))/size(matches,1);
    
    disp("Average residual for camera 1:");
    disp(res1);
    disp("Average residual for camera 2:");
    disp(res2);
    disp("Camera Center 1:");
    disp(c1);
    disp("Camera Center 2:");
    disp(c2);
end