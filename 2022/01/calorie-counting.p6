#!raku 

my @calorie-groups = 'input'.IO.slurp.split("\n\n");

# part1 
# 1. compute calorie count for each subgroup 
# 2. find the maximum calorie count
say max @calorie-groups.map({ [+] .split("\n") });

# part 2
# 1. compute calorie count for each subgroup 
# 2. sort calorie counts numerically in descending order
# 3. collect the first 3 elements (3 highest calorie counts)
# 4. sum the 3 highest calorie counts
say [+] @calorie-groups.map({ [+] .split("\n") }).sort({ $^b <=> $^a })[0..2]