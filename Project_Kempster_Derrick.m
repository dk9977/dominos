function Project_Kempster_Derrick()

    HOLE_AREA_WEIGHT = 0.1; % weight of dark region area, in comparison to largest dimension of enclosing box

    close all;
    
    % Specify image file to test
    im_file_name = 'IMG_2073.JPG';
    fprintf('\n*** Working on "%s" ***\n', im_file_name);
    im = im2double(imread(im_file_name));

    % Binarize the image
    fprintf('\nBinarizing image...\n');
    im_bw = dominos_binarize(im);
    figure;
    imshow(im_bw);

    % Determine bright and dark regions in binary image
    fprintf('Determining regions...\n');
    [B,L,n,A] = bwboundaries(im_bw);

    % Separate dominos and bright noise
    fprintf('Classifying bright regions...\n');
    obj_sizes = zeros(n, 1);                                % using object size,
    for ri = 1:n
        obj_sizes(ri) = sqrt(sum(L == ri, 'all'));
    end
    [cid, cntrs] = kmeans(obj_sizes, 2);                    % classify with kmeans
    all_dominos = find(cid == find(cntrs == max(cntrs)));   % to find dominos

    % Separate lines, large pips, small pips, and dark noise
    fprintf('Classifying dark regions...\n');
    hole_areas = zeros(length(B) - n, 1);                   % using object area
    hole_max_dims = zeros(length(B) - n, 1);                % and maximum dimension of a minimal enclosing box,
    for ri = n+1:length(B)
        select_region = L == ri;
        hole_areas(ri) = sum(select_region, 'all') * HOLE_AREA_WEIGHT;
        [rows, cols] = find(select_region);
        hole_max_dims(ri) = max(max(rows) - min(rows), max(cols) - min(cols)) + 1;
    end
    [cid, cntrs] = kmeans([hole_areas, hole_max_dims], 4);  % classify with kmeans
    line_loc = cntrs(:, 2) == max(cntrs(:, 2));
    all_lines = find(cid == find(line_loc));                % to find lines,
    cntrs(line_loc, 2) = 0;
    large_pip_loc = cntrs(:, 2) == max(cntrs(:, 2));
    all_large_pips = find(cid == find(large_pip_loc));      % large pips,
    cntrs(large_pip_loc, 2) = 0;
    small_pip_loc = cntrs(:, 2) == max(cntrs(:, 2));
    all_small_pips = find(cid == find(small_pip_loc));      % and small pips
    all_pips = union(all_large_pips, all_small_pips);

    % Determine values of dominos by knowing which lines and pips are enclosed
    fprintf('Assigning lines and pips to dominos...\n');
    dominos = [];
    for di = 1:length(all_dominos)                  % for every found domino
        holes = find(A(:, all_dominos(di)));        % find all enclosed dark regions
        if isempty(holes)
            fprintf('  - Rejected domino #%u for being blank.\n', di);
            continue;
        end
        lines = intersect(holes, all_lines);        % find its midline from the dark regions
        if length(lines) ~= 1
            fprintf('  - Rejected domino #%u for lacking a middle line.\n', di);
            continue;
        end
        domino_values = [all_dominos(di), 0, 0];
        pips = intersect(holes, all_pips);          % find its pips from the dark regions
        if isempty(pips)
            fprintf('  - Rejected domino #%u for being a double-0.\n', di);
            continue;
        end
        [rows, cols] = find(L == lines(1));         % determine the location and angle of the line in the image
        y0 = min(rows);
        y1 = max(rows);
        x0 = min(cols(rows == y0));
        x1 = max(cols(rows == y1));
        dy = y1 - y0;
        dx = x1 - x0;
        if dx == 0
            dx = 1;
        end
        slope = dy / dx;
        intercept = y0 - slope * x0;
        for pi = 1:length(pips)                     % determine the domino side that holds each pip
            [py, px] = find(L == pips(pi), 1);
            if py > slope * px + intercept
                domino_values(2) = domino_values(2) + 1;
            else
                domino_values(3) = domino_values(3) + 1;
            end
        end
        if domino_values(2) == domino_values(3)
            fprintf('  - Rejected domino #%u for being a double-%u.\n', di, domino_values(2));
            continue;
        end
        fprintf('  - Accepted domino #%u with a value of [%u|%u].\n', di, domino_values(2), domino_values(3));
        dominos = [dominos; domino_values];         % and record the values
    end

    % Find the domino that is closest to the bottom-left corner
    blcr = [size(L, 1), 1]; % bottom-left corner
    bldi = 0;               % bottom-left domino index
    bldd = length(L) ^ 2;   % bottom-left domino distance (squared, from corner)
    for di = 1:size(dominos, 1)
        center = region_center(L == dominos(di, 1));
        dist = (blcr(1) - center(1)) ^ 2 + (center(2) - blcr(2)) ^ 2;
        if dist < bldd
            bldi = di;
            bldd = dist;
        end
    end


    % Build the chain of dominos
    start = dominos(bldi, :);
    unused = dominos;
    unused(bldi, :) = [];
    fprintf('Building the domino chain from [%u|%u]...\n', start(2), start(3));
    chain = recurse_domino_chain([start(2), start(3)], unused, [], [start(1), false]);

    % Display resulting chain
    fprintf('\nLongest chain without repeated values:\n');
    for ci = 1:size(chain, 1)
        domino = dominos(dominos(:, 1) == chain(ci, 1), :);
        if chain(ci, 2)
            fprintf('[%u|%u]', domino(3), domino(2));
        else
            fprintf('[%u|%u]', domino(2), domino(3));
        end
    end
    fprintf('\n\n');

end