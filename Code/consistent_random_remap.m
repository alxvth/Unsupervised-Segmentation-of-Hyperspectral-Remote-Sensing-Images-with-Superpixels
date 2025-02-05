function remapped_matrix = consistent_random_remap(input_matrix)
    % Get unique values from the input matrix
    unique_vals = unique(input_matrix);
    n_unique = length(unique_vals);
    
    % Create a random permutation of the unique values
    random_vals = randperm(n_unique);
    
    % Initialize output matrix
    remapped_matrix = zeros(size(input_matrix), 'like', input_matrix);
    
    % Create the mapping and apply it
    for i = 1:n_unique
        remapped_matrix(input_matrix == unique_vals(i)) = random_vals(i);
    end
end
