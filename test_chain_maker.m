function test_chain_maker()
    dominos = [1, 0, 2;
               2, 2, 5;
               3, 4, 2;
               4, 0, 3;
               5, 0, 3;
               6, 0, 2];
    start_region = 1;

    start_index = dominos(:,1) == start_region;
    start = dominos(start_index, :);
    unused = dominos;
    unused(start_index, :) = [];
    chain = recurse_domino_chain([start(2), start(3)], unused, [], [start(1), false]);
end