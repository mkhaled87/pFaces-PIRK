%% Check if the provided system with sign-stable Jacobian satisfies the continuous-time monotonicity property
% and return the corresponding partial orders on the state and input spaces
% This function first defines the monotonicity conditions to be satisfied
% as a linear system of binary equations, which is then solved in the
% Gaussian Field 2 (GF(2): all elements equal to 0 or 1, and 1+1=0).

% Source paper 1 (conditions in Corollary III.3)
% D. Angeli and E. D. Sontag, "Monotone control systems". IEEE Transactions
% on automatic control, v. 48(10), pp. 1684-1698, 2003.
% DOI:  10.1109/TAC.2003.817920

% Source paper 2 (alternative graphical conditions for monotonicity)
% D. Angeli and E. D. Sontag, "Multi-stability in monotone input/output 
% systems". Systems & Control Letters, v. 51(3-4), pp. 185-202, 2004.
% DOI: 10.1016/j.sysconle.2003.08.003

% List of inputs
%   J_x_signs: sign matrix of the Jacobian with respect to the state
%   J_p_signs: sign matrix of the Jacobian with respect to the input

% List of outputs
%   monotonicity_satisfaction: boolean equal to 1 if the system is monotone
%   partial_order_x, partial_order_p: binary vector representing partial 
%       orders on the state and input spaces for which the system is
%       monotone (0 elements corresponds to using classical inequalities, 
%       1 elements corresponds to using reversed inequalities)
%       Return empty vectors [] when the system is not monotone

% Authors:  
%   Alex Devonport, <alex_devonport -AT- berkeley.edu>, EECS, UC Berkeley
%   Pierre-Jean Meyer, <pjmeyer -AT- berkeley.edu>, EECS, UC Berkeley
% Date: 13th of October 2018

function [monotonicity_satisfaction,partial_order_x,partial_order_p] = Monotonicity_sign_conditions(J_x_signs,J_p_signs)
% State and input dimensions
[n_x,n_p] = size(J_p_signs);

%% Check the format of the provided sign matrices
% Consistent dimensions
assert(size(J_x_signs,1) == size(J_x_signs,2), 'State Jacobian sign matrix must be square.')
assert(size(J_x_signs,1) == size(J_p_signs,1), 'Inconsistent dimensions of the state and input Jacobian sign matrices.')

% Make sure that they are sign matrices (elements equal to 0, 1, -1 only)
J_x_signs = sign(J_x_signs);
J_p_signs = sign(J_p_signs);

%% Define a linear system of binary equations A*z=b representing the sign conditions for monotonicity
A = zeros(n_x*(n_x+n_p),n_x+n_p);
b = zeros(n_x*(n_x+n_p),1);

% Create matrix A and vector b by blocs (for each state dimension)
for i = 1:n_x
    % Conditions for each row 'i' of the state Jacobian signs J_x_signs
    % For J_x_signs(i,j), we fill rows 'n_x*(i-1)+j' of both A and b:
    % columns i and j of A are set to 1 iff i~=j and J_x_signs(i,j)~=0
    A(n_x*(i-1)+1:n_x*i,1:n_x) = xor(eye(n_x),Column_of_ones_in_zero_matrix(n_x,i)).*repmat(abs(J_x_signs(i,:)'),1,n_x);
    % element j of b is set to 1 iff i~=j and J_x_signs(i,j)<0
    b(n_x*(i-1)+1:n_x*i) = (J_x_signs(i,:)<0)' & Single_zero_in_column_of_ones(n_x,i);

    % Conditions for each row 'i' of the input Jacobian signs J_p_signs
    % For J_p_signs(i,j), we fill rows 'n_x^2+n_p*(i-1)+j' of both A and b:
    % columns i and n_x+j of A are set to 1 iff J_p_signs(i,j)~=0
    A(n_x^2+n_p*(i-1)+1:n_x^2+n_p*i,:) = [Column_of_ones_in_zero_matrix([n_p,n_x],i),eye(n_p)].*repmat(abs(J_p_signs(i,:)'),1,n_x+n_p);
    % element j of b is set to 1 iff J_p_signs(i,j)<0
    b(n_x^2+n_p*(i-1)+1:n_x^2+n_p*i) = (J_p_signs(i,:)<0)';
end

%% Solve the linear system of binary equations A*z=b
% Its solution 'z' is a n_x+n_p binary column vector representing the
% partial orders for both the state space and the input space.

% z(i)=0 implies that we use the classical inequalities on dimension i
%   (x(i) is "larger" (w.r.t. the partial order) than y(i) if x(i)>=y(i))
% z(i)=1 implies that we use the reversed inequalities on dimension i
%   (x(i) is "larger" (w.r.t. the partial order) than y(i) if x(i)<=y(i))

try
    % Try to solve the system using Matlab solver 'gflineq',
    % which requires the Matlab Communication toolbox.
    % If it isn't licensed and installed, an error will be thrown.
    warning('OFF','comm:gflineq:NoSolution')
    partial_order_stacked = gflineq(A,b);
catch ME
    if contains(ME.message, 'Undefined function')
        % An alternative function is provided if the toolbox is unavailable
        partial_order_stacked = gf2linsolve(A,b);
    else
        % If the error is unrelated to the toolbox, rethrow it
        rethrow(ME)
    end
end 

%% Define the function outputs based on the success of the solver
if ~isempty(partial_order_stacked)
    % If a solution to A*z=b was found
    monotonicity_satisfaction = true;
    partial_order_x = partial_order_stacked(1:n_x);
    partial_order_p = partial_order_stacked(n_x+1:n_x+n_p);
    
    %% Sanity check to ensure that the obtained partial orders are correct
    % n_x*n_x matrix with elements (-1)^(partial_order_x(i)+partial_order_x(j))
    result_matrix_x = ((-1).^partial_order_x)*((-1).^partial_order_x');

    % Replace diagonal by the signs in the diagonal of J_x_signs 
    % (continuous-time monotonicity has no constraint on the diagonal 
    % of the state Jacobian sign)
    result_matrix_x = result_matrix_x - diag(diag(result_matrix_x)) + diag(diag(J_x_signs));

    % n_x*n_p matrix with elements (-1)^(partial_order_x(i)+partial_order_p(j))
    result_matrix_p = ((-1).^partial_order_x)*((-1).^partial_order_p');

    % Check consistency of these matrices with the provided Jacobian signs
    assert(all(all(result_matrix_x.*J_x_signs >= 0)),'State partial order inconsistent with state Jacobian signs')
    assert(all(all(result_matrix_p.*J_p_signs >= 0)),'Partial orders inconsistent with input Jacobian signs')

else
    % If no solution to A*z=b was found
    monotonicity_satisfaction = false;
    partial_order_x = [];
    partial_order_p = [];
end

end

%% Matrix filled with zeros, with a single column filled with ones
% Function called during the creation of matrix A of the linear system of 
% binary equations A*z=b representing the sign conditions for monotonicity
% List of inputs:
%   matrix_size: 2D vector for rectangular matrix, scalar for square matrix
%   column_index: scalar between 1 and matrix_size(2)
% List of outputs:
%   matrix: zero matrix with column 'column_index' filled with ones
function matrix = Column_of_ones_in_zero_matrix(matrix_size,column_index)
matrix = zeros(matrix_size);
matrix(:,column_index) = 1;
end

%% Column vector filled with ones, with a single zero element
% Function called during the creation of vector b of the linear system of 
% binary equations A*z=b representing the sign conditions for monotonicity
% List of inputs:
%   vector_size: scalar of the desired length for the output vector
%   row_index: scalar between 1 and vector_size
% List of outputs:
%   vector: column vector filled with ones, with a 0 on row 'row_index'
function vector = Single_zero_in_column_of_ones(vector_size,row_index)
vector = ones(vector_size,1);
vector(row_index) = 0;
end

%% Solver of a linear system of binary equations A*sol=b 
% in the Galois Field 2 (GF(2): all elements equal to 0 or 1, and 1+1=0)
% List of inputs:
%   A: a binary matrix
%   b: a binary column vector with as many rows as matrix A
% List of outputs:
%   sol: a binary column vector solving A*sol=b 
%       or the empty set if no solution is found
function sol = gf2linsolve(A, b)
% Size of the problem
[dim1,dim2] = size(A);

% Check if provided inputs are indeed binary matrices
if ~isequal(A,mod(A,2)) || ~isequal(b,mod(b,2))
    error('Non-binary elements provided.')
end

% Check if b has the correct dimension
if size(b,2)>1 || size(b,1)~=dim1
    error('Inconsistent dimensions of provided matrix and vector.')
end

% Save initial values of A and b (which will be modified)
A_init = A;
b_init = b;

% If A has more columns than rows, make it square by appending zeros
if(dim2 > dim1)
    A = [A;zeros(dim2-dim1,dim2)];
    b = [b; zeros(dim2-dim1,1)];
    [dim1,dim2] = size(A);
end

% First step of Gaussian elimination:
% Forward substitution to convert A to a reduced row echelon form (rref)
[A, b] = gf2rref(A, b);

% Set indeterminate variables to 0 by adding a new row in A and b
for k=1:dim2
    % Check if variable k is indeterminate (since A is in rref)
    if A(k,k) == 0
        % Define the row corresponding to the new equation to be added
        A_new_row = zeros(1,dim2);
        A_new_row(k) = 1;
        b_new_row = 0;
        
        % Add new row in row k (and shift down all rows from k to dim1)
        A = [A(1:k-1,:);A_new_row;A(k:end,:)];
        b = [b(1:k-1);b_new_row;b(k:end)];
        [dim1,dim2] = size(A);
        
        % Update matrix A to put it back in reduced row echelon form
        [A, b] = gf2rref(A, b);
    end
end

% Look for inconsistent rows (infeasible equations)
for k=1:dim1
    % Inconsistent if the whole row in A is 0, but b(k) is non-zero
    if all(A(k, :) == 0) && b(k) ~= 0
        % The system cannot be solved: return and empty solution
        sol = [];
        return
    end
end

% Second step of Gaussian elimination: 
% back-substitution (from row dim2 to row 1) until the problem is solved
for k=dim2:-1:1
    for w=k+1:dim2
        if A(k, w) == 1
            A(k,:) = xor(A(k,:),A(w,:));
            b(k) = xor(b(k),b(w));
        end
    end
end
sol = b(1:dim2);

% Sanity check that sol satisfies A*sol=b
if isempty(sol) || ~isequal(mod(A_init*sol,2),b_init)
    disp('There was a GF(2) solver error.')
end
end

%% Convert a matrix to reduced row echelon form using forward substitution
% and adapt accordingly the vector b from linear binary system A*sol=b 
% List of inputs:
%   A: a binary matrix
%   b: a binary column vector with as many rows as matrix A
% List of outputs:
%   A: matrix A converted to reduced row echelon form
%   b: vector b adapted alongside the modifications applied to A
function [A, b] = gf2rref(A, b)
% Size of the problem
[dim1,dim2] = size(A);

% Forward substitution
for k=1:min(dim2, dim1)
    % Initialization for row k
    pivot_row = k;
    do_pivot = 0;
    
    % Look if we need to pivot
    if A(k, k) == 0
        % Look for a pivot row
        for w=k:dim1
            % Need to pivot only if a non-zero element is in the column
            if A(w,k) == 1
                pivot_row = w;
                do_pivot = 1;
                break
            end
        end
    end
    
    % Pivot if needed
    if do_pivot
        % Swap rows 'k' and 'pivot_row' in matrix A
        row_k = A(k,:);
        A(k,:) = A(pivot_row,:);
        A(pivot_row,:) = row_k;
        
        % Swap rows 'k' and 'pivot_row' in vector b
        row_k = b(k);
        b(k) = b(pivot_row);
        b(pivot_row) = row_k;
    end
    
    % Add the pivot row to the rows below it
    for j=k+1:dim1
        % Only if the k-th element of this row is non-zero
        if A(j, k) == 1
            A(j,:) = xor(A(j, :),A(k,:));
            b(j) = xor(b(j),b(k));
        end
    end
end

% Move all equations '0=0' to the bottom of the matrix
k = 1;
while k < dim1
    % Check if the current row needs to be moved to the bottom
    if all(A(k,:)==0) && b(k) == 0
        % Stop while loop if all rows below k are zeros
        if all(all(A(k:end,:)==0)) && all(b(k:end) == 0)
            break
        end
        
        % Else, move current row to the bottom of A and shift up other rows
        A = [A(1:k-1,:);A(k+1:end,:);zeros(1,dim2)];
        b = [b(1:k-1);b(k+1:end);0];
    else
        % Only increment the row index if the row was not moved
        k = k+1;
    end
end
end