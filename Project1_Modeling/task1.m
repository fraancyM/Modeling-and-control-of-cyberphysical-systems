%% TASK 1 RESULT 1 - 2 - 3
clear all
close all
clc

p = 20;
qq = 10; 
k = 2; % xtrue is k-sparse (it has 2 over 20 zero values)
delta = 1e-12; % Stop criterion

% result var generation
n_iterations = 100;
result_q = zeros(p-qq, 1);
interval_q = qq:(p-1);
result_t_mean = zeros(p-qq,1);
result_t_min = zeros(p-qq,1);
result_t_max = zeros(p-qq,1);

for q=interval_q

    result = ones(n_iterations,1); 
    result_t = zeros(n_iterations,1);
    for j=1:n_iterations

        % x_true generation
        s=randperm(p); % support
        s=s(1:k); % xtrue is a k-sparse vector
        interval = [-2,-1;1,2]; % intervals
        width = interval(:,2)-interval(:,1); % Widths of intervals
        x_true = zeros(p,1); % Allocate space for random values
        for i = 1:k
          m = randi(2); % Random interval choice
          x_true(s(i)) = interval(m,1)+width(m)*rand; % Random position within interval
        end

        % var generation
        C = randn(q,p);
        tau = norm(C,2)^(-2) - 1e-8;      
        lambda = 1/(100*tau);
        lambda_v = 0.01 * ones(p,1);
        sigma = 1e-2;
        nu = randn*sigma;
        y = C * x_true + nu; % I add small noise

        % Initialization IST
        x_t=zeros(p,1);
        x_t1=zeros(p,1);
        t=0;

        %IST ALGORITHM
        while (t==0 || T_max >= delta)
            temp = x_t + tau * C' * (y - C * x_t);
            for i=1:p
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

        % results generation
        for m=1:p
            if ( (x_t(m)~=0 && x_true(m)==0)||(x_true(m)~=0 && x_t(m)==0) ) && norm(x_t(m)-x_true(m))>0.01
                result(j)=0;
            end
        end
        result_t(j,1) = t; 

    end
    result_q(q-qq+1,1)=norm(result,1);    
    result_t_mean(q-qq+1,1)=mean(result_t);
    result_t_min(q-qq+1,1)=min(result_t);
    result_t_max(q-qq+1,1)=max(result_t);

end

figure(1);
plot( interval_q , result_q, 'b-', interval_q, result_q, 'r*' );
grid on
xlabel('q');
ylabel('result');

figure(2)
plot( interval_q , result_t_mean );
title('IST iterations')
xlabel('q');
ylabel('mean');

figure(3)
plot( interval_q , result_t_max );
title('IST iterations')
xlabel('q');
ylabel('max');

figure(4)
plot( interval_q , result_t_min );
title('IST iterations')
xlabel('q');
ylabel('min');

figure(5)
subplot(3,1,1);
plot( interval_q , result_t_mean );
title('IST iterations')
xlabel('q');
ylabel('mean');
grid on
subplot(3,1,2);
plot( interval_q , result_t_max );
title('IST iterations')
xlabel('q');
ylabel('max');
grid on
subplot(3,1,3);
plot( interval_q , result_t_min );
title('IST iterations')
xlabel('q');
ylabel('min');
grid on

result_q
return

%% TASK 1 RESULT 4 - 5 
clear all
close all
clc

p = 20;
q = 10; 
k = 2; % xtrue is k-sparse (it has 2 over 20 zero values)
delta = 1e-12; % Stop criterion

% result var generation
n_iterations = 100;

%FLAG == 1 => decrease tau -- FLAG == 2 => incerase lambda
TASK1_FLAG = 2;
if TASK1_FLAG == 1
    txt=' tau';
    interval_multiplier = 0.01:0.02:1; %decrease tau
else
    txt=' lambda';
    interval_multiplier = 1:5:100; %increase lambda
end
result_lambda = zeros(length(interval_multiplier),1);
result_t_mean = zeros(length(interval_multiplier),1);
result_t_min = zeros(length(interval_multiplier),1);
result_t_max = zeros(length(interval_multiplier),1);
multiplier=1;
tt=1;

for multiplier=interval_multiplier  
    result = ones(n_iterations,1); 
    result_t = zeros(n_iterations,1);
    for j=1:n_iterations

        % x_true generation
        s=randperm(p); % support
        s=s(1:k); % xtrue is a k-sparse vector
        interval = [-2,-1;1,2]; % intervals
        width = interval(:,2)-interval(:,1); % Widths of intervals
        x_true = zeros(p,1); % Allocate space for random values
        for i = 1:k
          m = randi(2); % Random interval choice
          x_true(s(i)) = interval(m,1)+width(m)*rand; % Random position within interval
        end

        % var generation
        C = randn(q,p);
        tau = norm(C,2)^(-2) - 1e-8;   
        sigma = 1e-2;
        nu = randn*sigma;
        y = C * x_true + nu; % I add small noise
        lambda_v = 0.01 * ones(p,1);
        
        %TAU MULTIPLIER
        if TASK1_FLAG == 1
            tau=tau*multiplier;
        end
        lambda = 1/(100*tau);
        
        %LAMBDA MULTIPLIER
        if TASK1_FLAG == 2
            lambda = lambda * multiplier;
            lambda_v = lambda_v * lambda;
        end
 
        % Initialization IST
        x_t=zeros(p,1);
        x_t1=zeros(p,1);
        t=0;

        %IST ALGORITHM
        while (t==0 || T_max >= delta)
            temp = x_t + tau * C' * (y - C * x_t);
            for i=1:p
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

        % results generation
        for m=1:p
            if ( (x_t(m)~=0 && x_true(m)==0)||(x_true(m)~=0 && x_t(m)==0) ) && norm(x_t(m)-x_true(m))>0.01
                result(j)=0;
            end
        end
        result_t(j) = t; 
    end
    result_lambda(tt,1)=norm(result,1);  
    result_t_mean(tt,1)=mean(result_t);
    result_t_min(tt,1)=min(result_t);
    result_t_max(tt,1)=max(result_t);   
    tt=tt+1;
end
    
figure(1);
plot( interval_multiplier , result_lambda);
xlabel(txt);
ylabel('result');
grid on


if TASK1_FLAG == 1
    interval_multiplier=interval_multiplier*tau;
else
    interval_multiplier=interval_multiplier*lambda;
end

figure(2)
subplot(3,1,1);
plot( interval_multiplier , result_t_mean );
title('IST iterations mean')
xlabel(txt);
ylabel('mean');
grid on
subplot(3,1,2);
plot( interval_multiplier , result_t_max );
title('IST iterations max')
xlabel(txt);
ylabel('max');
grid on
subplot(3,1,3);
plot( interval_multiplier , result_t_min );
title('IST iterations min')
xlabel(txt);
ylabel('min');
grid on