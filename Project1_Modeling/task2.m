clear all
close all
clc

n = 10;
q = 20;
h = 2; % a is h-sparse
delta = 1e-12; % Stop criterion

n_iterations = 100;
media = 0;
result_a = zeros(4,1);
result_mean = zeros(4,1);
aware = 0:1;
nu_flag = 0:1;

for k=aware
    for l=nu_flag        
        result = ones(n_iterations,1);
        result_m = zeros(n_iterations,1);
        for j=1:n_iterations     
            
            % var generation
            x_true = randn(n,1);
            C = randn(q,n);
            G = [C,eye(q)];
            tau = norm(G,2)^(-2) - 1e-8;
            lambda = 2*1e-3/tau;
            sigma = 1e-2;
            nu = randn * l * sigma;
            y = C * x_true + nu;
            
            lambda_v = 2*1e-3 * [zeros(n,1)',ones(q,1)']';
            
            % Support generation
            s=randperm(q); % support
            s=s(1:h); % a is a h-sparse vector
            a = zeros(q,1); % Allocate space for random values
            if k == 0
                interval = [-2,-1;1,2]; % intervals
                width = interval(:,2)-interval(:,1); % Widths of intervals
                % Unaware attacks:
                for i = 1:h
                  m = randi(2); % Random interval choice
                  a(s(i)) = interval(m,1)+width(m)*rand; % Random position within interval  
                end
            else
                for i = 1:h
                  a(s(i)) = y(s(i))/2; 
                end
            end
            
            % Measurement noise
            y = y + a;
            
            % Initialization IST
            x_t=zeros(n+q,1);
            x_t1=zeros(n+q,1);
            t=0;
        
            %IST ALGORITHM
            while (t==0 || T_max >= delta)
                temp = x_t + tau * G' * (y - G * x_t);
                for i=1:(n+q)
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
            for m=1:q
                if ((x_t(m+n)~=0 && a(m)==0) || (a(m)~=0 && x_t(m+n)==0))
                    result(j)=0;
                end
            end
            result_m(j)=norm(x_t(1:n)-x_true, 2);
        end
        result_a(l+k*2+1) = norm(result,1);
        result_mean(l+k*2+1) = mean(result_m);
     end
end 
[result_a, result_mean]

figure(1)
plot( [0 1 2 3] , result_a );
xticks([0 1 2 3])
xticklabels({'aware=0, nu=0','aware=0, nu=1','aware=1, nu=0', 'aware=1, nu=1'})
ylabel('result a');
hold on
plot([0 1 2 3] , result_a ,'.', 'Color','red', 'MarkerFaceColor', 'red', 'MarkerSize', 8)

figure(2)
plot( [0 1 2 3] , result_mean );
xticks([0 1 2 3])
xticklabels({'aware=0, nu=0','aware=0, nu=1','aware=1, nu=0', 'aware=1, nu=1'})
ylabel('result x norm');
hold on
plot([0 1 2 3] , result_mean ,'.', 'Color','red','MarkerFaceColor', 'red', 'MarkerSize', 8)
