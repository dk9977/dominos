function center = region_center(bw_reg_mat)
    [reg_rows, reg_cols] = find(bw_reg_mat);                                        % all pixels in region
    center = [max(reg_rows) + min(reg_rows), max(reg_cols) + min(reg_cols)] ./ 2;   % center of minimal enclosing box
end