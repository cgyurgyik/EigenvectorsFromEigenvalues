function v_j = GEFE_optimized(varargin)
% This version is looking to optimize the loss in precision, and then compare it to the original GEFE.

     if nargin < 3 || nargin > 4
         error('GetEigenvectorFromEigenvalues accepts 3 or 4 arguments: H, ii, j, (optional) H_eigenvalues.');
     end
     
     H = varargin{1};
     [M,N] = size(H);
     if ~ismatrix(H) || M ~= N
         error('H must be a N x N matrix.');
     end
     
     ii = varargin{2};
     
     if ~isvector(ii)
         error('ii must be a vector containing the rows of column j for which you want the eigenvector values.');
     end
     
     greater_than_N = ii > N;
     if sum(greater_than_N) ~= 0
        error('Each i in ii must be a row of the matrix H. For each i, 1 <= i <= N.');
     end
     
     j = varargin{3};
     if ~isvector(j) || length(j) ~= 1
         error('j must be an integer representing the column of the desired eigenvector values, such that 1 <= j <= N.')
     end
    
     if nargin == 3
         % Calculate the eigenvalues of λi(H).
         H_eigenvalues = eig(H);
     else
         % Eigenvalues provided by the client.
         H_eigenvalues = varargin{4};
     end
     
     assert(length(H_eigenvalues) == N, 'Number of eigenvalues must be equivalent to the number of rows and columns in the matrix.');
    
     H(:, j) = []; % Remove jth column.
     H(j, :) = []; % Remove jth row.
     Hj_eigenvalues = eig(H);
     
     num_i = numel(ii);
     v_j = zeros(num_i,1);
     
     for k = 1:num_i
         ei = H_eigenvalues(ii(k));
         H_ii = H_eigenvalues;
         H_ii(ii(k)) = [];
         
         % One way to help defeat overflow/underflow, we can sort the values from smallest to largest, and divide
         % those respectively. This allows for each [a1, a2, ..., an] /. [b1, b2, ..., bn] to be as close to 1 as possible.
         v_j(k) = prod( sort(ei - Hj_eigenvalues) ./ sort(ei - H_ii) );
     end
end
