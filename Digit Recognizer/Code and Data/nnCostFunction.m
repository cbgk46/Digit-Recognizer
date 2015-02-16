function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));
X = [ones(m,1) X];

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%

activation_one = sigmoid(X*Theta1');

activation_one = [ones(m,1) activation_one];

hypothesis = sigmoid(activation_one*Theta2');

% Recoding y. Initially y is m*1. Now we are making it m*k. 
% For each row, we assign value of 1 to new matrix by using the old matrix value as index

new_y = zeros(m,num_labels);

for i = 1:m
	j = y(i);
	new_y(i,j) = 1;
endfor


%% Computing Cost

temp_J = sum( log(hypothesis) .* (new_y) + log(1-hypothesis).*(1-new_y));

J = (-1/m) * sum(temp_J);

reg_J = (lambda/(2*m))*(
						sum(sum(Theta1(:,2:input_layer_size+1).^2)) 
						+ 
						sum(sum(Theta2(:,2:hidden_layer_size+1).^2))
						);

J = J + reg_J;

%%-----------------------------------------------------------------
%%Gradient Computation%%%%%

Delta1 = Delta2 = 0;

for i=1:m
% Step 1
	z_2 = X(i,:)*Theta1';
	a_2 = sigmoid(z_2);
	z_3 = [ones(size(a_2,1),1) a_2]*Theta2';
	a_3 = sigmoid(z_3)';

% Step 2
	d3 = a_3 - (new_y(i,:))';
	%size(a_3)
	%size(new_y(i,:))
% Step 3
	d2 = (Theta2'*d3).*sigmoidGradient([ones(size(z_2,1),1) z_2]');

% Step 4
	d2 = d2(2:end);
	Delta2 = Delta2+d3*([ones(size(a_2,1),1) a_2]);
	Delta1 = Delta1+d2*(X(i,:));
endfor

Delta2 = (1/m)*Delta2;
Delta1 = (1/m)*Delta1;

Theta1_grad = Delta1;
Theta2_grad = Delta2;

Theta1_grad(:,2:end) = Theta1_grad(:,2:end) + (lambda/m)*Theta1(:,2:end);
Theta2_grad(:,2:end) = Theta2_grad(:,2:end) + (lambda/m)*Theta2(:,2:end);

% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];

end
