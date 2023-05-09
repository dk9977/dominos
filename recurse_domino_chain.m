function full_chain = recurse_domino_chain(ends, unused_dominos, used_nums, part_chain)

    if isempty(unused_dominos)      % if no more dominos to try to add
        full_chain = part_chain;    % then great, we've used them all,
    else                            % but otherwise,
        options = {};
        for di = 1:size(unused_dominos, 1)                      % for each remaining domino,
            domino = unused_dominos(di, :);
            if ~ismember(domino(2), used_nums)
                if domino(2) == ends(1)                         % if the left side matches the left end
                    new_ends = [domino(3), ends(2)];
                    new_unused_dominos = unused_dominos;
                    new_unused_dominos(di, :) = [];
                    new_used_nums = [used_nums, ends(1)];
                    new_part_chain = [domino(1), true; part_chain];
                    option = recurse_domino_chain(new_ends, new_unused_dominos, new_used_nums, new_part_chain);
                    options(length(options) + 1) = {option};    % then consider the best resulting chain from its entry,
                end
                if domino(2) == ends(2)                         % or if the left side matches the right end
                    new_ends = [ends(1), domino(3)];
                    new_unused_dominos = unused_dominos;
                    new_unused_dominos(di, :) = [];
                    new_used_nums = [used_nums, ends(2)];
                    new_part_chain = [part_chain; domino(1), false];
                    option = recurse_domino_chain(new_ends, new_unused_dominos, new_used_nums, new_part_chain);
                    options(length(options) + 1) = {option};    % then consider the best resulting chain from its entry,
                end
            end
            if ~ismember(domino(3), used_nums)
                if domino(3) == ends(1)                         % or if the right side matches the left end
                    new_ends = [domino(2), ends(2)];
                    new_unused_dominos = unused_dominos;
                    new_unused_dominos(di, :) = [];
                    new_used_nums = [used_nums, ends(1)];
                    new_part_chain = [domino(1), false; part_chain];
                    option = recurse_domino_chain(new_ends, new_unused_dominos, new_used_nums, new_part_chain);
                    options(length(options) + 1) = {option};    % then consider the best resulting chain from its entry,
                end
                if domino(3) == ends(2)                         % or if the right side matches the right end
                    new_ends = [ends(1), domino(2)];
                    new_unused_dominos = unused_dominos;
                    new_unused_dominos(di, :) = [];
                    new_used_nums = [used_nums, ends(2)];
                    new_part_chain = [part_chain; domino(1), true];
                    option = recurse_domino_chain(new_ends, new_unused_dominos, new_used_nums, new_part_chain);
                    options(length(options) + 1) = {option};    % then consider the best resulting chain from its entry
                end
            end
        end
        if isempty(options)                     % no remaining dominos can be added to the chain
            full_chain = part_chain;
        elseif length(options) == 1             % only 1 domino can be added in 1 way in this step
            full_chain = cell2mat(options);
        else                                    % build the longest chain from the options
            chain_lengths = cellfun('size', options, 1);
            full_chain = cell2mat(options(find(chain_lengths == max(chain_lengths), 1)));
        end
    end

end