function im_opened = asymmetric_opening(im, erode_radius, dilate_radius)
    % opening is erosion followed by dilation
    % this differs from imopen() by using different radii for each inner process
    im_eroded = imerode(im, strel('disk', erode_radius));   % erode image
    im_opened = imdilate(im_eroded, strel('disk', dilate_radius));  % dilate eroded image
end