%% TASK 3

clear all
close all
clc

q = 6; %sensors
p = 7; %cells

%Dictionary
D = -[46 58 76 69 67 80 61;
      54 49 72 63 56 65 59;
      52 50 56 58 58 62 42;
      61 62 49 61 60 65 44;
      73 78 65 69 55 57 61;
      72 65 69 47 53 44 62];

% Measurement
y= -[62 58 41 46 64 63]';

D_norm = normalize(D); % to solve the LASSO problem with normalized D
delta = 1e-12; % Stop criterion
tau = norm(D_norm,2)^(-2) - 1e-8;
lambda = 1;
sigma = 1e-2;
lambda_v = lambda * tau * ones(p,1)';

% Initialization IST
x_t=zeros(p,1);
x_t1=zeros(p,1);
t=0;

%IST ALGORITHM to solve LASSO
% x_t is a sparse vector indicating which cells contain targets
while (t==0 || T_max >= delta)
    temp = x_t + tau * D_norm' * (y - D_norm * x_t);
    for i=1:(p)
        if(temp(i) > lambda_v(i))
            x_t1(i) = temp(i) - lambda_v(i);
        end
        if(temp(i) < -lambda_v(i))
            x_t1(i) = temp(i) + lambda_v(i);
        end
        if(abs(temp(i)) <= lambda_v(i))
            x_t1(i) = 0;
        end
    end
    T_max=norm(x_t1-x_t , 2);
    x_t=x_t1;
    t=t+1;
end

tol_x = max(x_t)/2 - 1; % tolerance to not consider false positives

x_t_NoAttack = x_t;
for i=1:p
    if abs(x_t_NoAttack(i)) < tol_x %set to zero values lower than tol_x
        x_t_NoAttack(i)=0;
    end
end

%there is a value >> others -> that cell contains the target
%comparison between vector containing false positive and not
[x_t x_t_NoAttack]

% Number and positions of the targets
target_positions = find(x_t_NoAttack); %returns the linear indices corresponding to the nonzero entries of the array x
number_targets = length(target_positions); % or nnz(target_indices) -> Number of nonzero matrix elements.

fprintf('Number of targets without attacks: %d in position ', number_targets);
disp(mat2str(target_positions));

%% Solve the LASSO problem with attack

I = eye(size(D, 1));
G = [D_norm, I];
G_norm = normalize(G); % Normalize G

tau = norm(G_norm,2)^(-2) - 1e-8;

tol_a = 2; %tolerance for a_estimate

correct_targets = 0;
correct_sensor_est = 0;
wrong = [];

%Place attack on each sensor
for num=1:q
    
    h=num; %position of attack
    fprintf("\nAttack on sensor %d:\n", h);

    % Apply an attack and solve the LASSO problem with normalized G
    y_attack = y;
    a=zeros(q,1);
        
    a(h)=1/5*y_attack(h);
    y_attack(h) = y_attack(h) + a(h);
    
    lambda_v = lambda * tau * ones(p+q,1)';
    
    % Initialization IST
    x_t=zeros(p+q,1);
    x_t1=zeros(p+q,1);
    t=0;
    
    %IST ALGORITHM
    while (t==0 || T_max >= delta)
        temp = x_t + tau * G_norm' * (y_attack - G_norm * x_t);
        for i=1:(p+q)
            if(temp(i) > lambda_v(i))
                x_t1(i) = temp(i) - lambda_v(i);
            end
            if(temp(i) < -lambda_v(i))
                x_t1(i) = temp(i) + lambda_v(i);
            end
            if(abs(temp(i)) <= lambda_v(i))
                x_t1(i) = 0;
            end
        end
        T_max=norm(x_t1-x_t , 2);
        x_t=x_t1;
        t=t+1;
    end    
    
    x_t_Attack = x_t;
    tol_x = max(x_t)/2 - 1; % tolerance to not consider false positives
    
    for i=1:p
        if abs(x_t_Attack(i)) < tol_x %set to zero values lower than tol_x
            x_t_Attack(i)=0;
        end
    end

    % Extract the indices of the non-zero entries of x_t
    %x_t contains x and a
    target_indices_attack = find(x_t_Attack(1:p));
    a_est = x_t_Attack(p+1:end);
    
    a_no_tol = a_est;
    
    for i=1:q
        if abs(a_est(i)) < tol_a %set to zero values lower than tol
            a_est(i)=0;
        end
    end
    
    %there is a value >> others -> that is the sensor attached
    aa = [a a_no_tol a_est] %comparison between vector without attack and vectors with attack containing false positive and not
    
    if find(a_est) == find(a)
        correct_sensor_est = correct_sensor_est + 1;
    else
        wrong = [wrong h];
    end
    
    % number and positions of the targets in the presence of the attack
    number_targets_attack = length(target_indices_attack);
    target_positions_attack = target_indices_attack;
    
    %there is a value >> others -> that cell contains the target
    %comparison between vector without attack and vectors with attack containing false positive and not
    x = [x_t_NoAttack x_t(1:p) x_t_Attack(1:p)]

    if length(x_t_NoAttack) == length(x_t_Attack(1:p) )
        correct_targets = correct_targets + 1;
    end
    
    fprintf('Number of targets with attack on sensor %d: %d in position ', h, number_targets_attack);
    disp(mat2str(target_positions_attack));     
end

perc_success = correct_targets/q * 100;

% Results
fprintf('\nNumber of targets successfully found: %d/%d \n', correct_targets, q);
fprintf('Number of sensors detected successfully: %d/%d \n', correct_sensor_est, q);
fprintf('Sensors not detected correctly: ');
disp(mat2str(wrong));


