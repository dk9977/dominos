function im_bw = dominos_binarize(im_rgb)

    % Values to alter the binarization process
    CYAN_BOOST = 200;               % weight for darkening the grayscale image at cyan
    BIN_NUM = 64;                   % bins to use in the histogram to find peaks
    PROMINENCE_FRACTION = 0.01;     % smallest fraction of the highest peak that can still register as a peak
    LITE_DARK_SPLIT = 1/3;          % required distance between the light and dark peaks
    THRESH_PART_A = -1.7227;        % y = Ax^2 + Bx + C, formula for binary threshold
    THRESH_PART_B = 3.9242;
    THRESH_PART_C = -1.3993;

    % All of the matrices derived from the image
    im_lab = rgb2lab(im_rgb);                                               % image in L*a*b* colorspace
    im_lum = im_lab(:,:,1);                                                 % L*
    im_ach = im_lab(:,:,2);                                                 % a*
    im_bch = im_lab(:,:,3);                                                 % b*
    im_rad = (im_ach .^ 2 + im_bch .^ 2) .^ 0.5;                            % difference from grayscale
    im_ang = atand(im_bch ./ im_ach);                                       % angle of color in L*a*b*
    im_ang(isnan(im_ang)) = 0;
    im_nir = (1 - rescale(abs(45 - im_ang))) .* rescale(im_rad);            % closeness to a* = b* or a* = -b*, and the sphere surface
    cyan_booster = (im_ach < 0) .* (im_bch < 0) .* im_nir .* CYAN_BOOST;    % cyan-ness
    im_gre = rescale(max(im_lum - im_rad - cyan_booster, 0));               % resultant grayscale image

    % Determine threshold for the binary image
    while true
        bin_freq = imhist(im_gre, BIN_NUM);                                 % make a histogram
        ys = [0; bin_freq; 0];
        xs = (-1:BIN_NUM) ./ BIN_NUM;
        [~, locs] = findpeaks(ys, xs, 'SortStr', 'descend', ...
            'MinPeakProminence', max(bin_freq) * PROMINENCE_FRACTION, ...
            'MinPeakDistance', LITE_DARK_SPLIT);                            % find the peaks
        if length(locs) > 1
            break;
        end
        im_gre = im_gre .^ 0.5;                                             % try again with brighter image
    end
    hilite = max(locs);                                                     % most significant bright peak (domino faces)
    thresh = THRESH_PART_A * hilite ^ 2 + THRESH_PART_B * hilite + THRESH_PART_C;   % quadratic threshold formula
    im_bw = im_gre >= thresh;                                               % binary image from threshold

end