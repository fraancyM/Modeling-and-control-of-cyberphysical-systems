clear all
close all
clc

n = 10;
q = 20;
h = 2; % a is h-sparse

delta = 1e-12; % Stop criterion
delta1 = 1e-7;

data=importdata("stochasticmatrices.mat");
Q1=data.Q1;
Q2=data.Q2;
Q3=data.Q3;
Q4=data.Q4;

% var generation
x_true = randn(n,1);
C = randn(q,n);
G = [C,eye(q)];
tau = 0.03;
lambda = 2*1e-4/tau;
sigma = 1e-2;
nu = randn *  sigma;
y = C * x_true + nu;

lambda_v = tau * lambda * [zeros(n,1)',ones(q,1)']';

% Support generation
s=randperm(q); % support
s=s(1:h); % a is a h-sparse vector
a = zeros(q,1); % Allocate space for random values

interval = [-2,-1;1,2]; % intervals
width = interval(:,2)-interval(:,1); % Widths of intervals
% Unaware attacks:
for i = 1:h
  m = randi(2); % Random interval choice
  a(s(i)) = interval(m,1)+width(m)*rand; % Random position within interval  
end

% Measurement noise
y = y + a;

time=zeros(4,1);
time2=zeros(4,1);
esr=zeros(4,1);
diff1=zeros(4,1);

for c=1:4
 eigen_flag=0;
    switch c
        case 1
            Q=Q1;
        case 2
            Q=Q2;
        case 3
            Q=Q3;
        case 4
            Q=Q4;
    end
    
    % CHECK CONSENSUS
    v = abs(eig(Q));
    if (length(find(v>0.999)) == 1)
        disp(['Q' mat2str(c) ' Consensus: YES'])
    else
        disp(['Q' mat2str(c) ' Consensus: NO'])
    end

    % SPECTRAL RADIUS
    for w=1:length(v)
        if v(w)>0.999
            v(w)=0;
        end
    end
    esr(c)=max(v);

    z_t=zeros(q,n+q);
    z_tt=zeros(q, n+q);
    z_t1=zeros(q, n+q);
    T=0;
    
    while (T==0 || T_n > delta1)
        if T==1e5
            break
        end
        z_tt = z_t;
        for i = 1:q
            % Initialization IST
            t=0;
            %IST ALGORITHM
            while (t==0 || T_max >= delta)
                temp=0;
                for j = 1:q
                    temp = temp + Q(i,j) .* z_t(j,:);
                end
                temp = temp + tau * G(i,:) * ( y(i) - G(i,:) * z_t(i,:)' );
                
                for m=1:(n+q)
                    if(temp(m) > lambda_v(m))
                        z_t1(i,m) = temp(m) - lambda_v(m);
                    end
                    if(temp(m) < -lambda_v(m))
                        z_t1(i,m) = temp(m) + lambda_v(m);
                    end
                    if(abs(temp(m)) <= lambda_v(m))
                        z_t1(i,m) = 0;
                    end
                end
                T_max=norm(z_t1-z_t , 2);
                z_t=z_t1;
                t=t+1;
            end
        end
        T_n=0;
        for j=1:q
            T_n = T_n + norm(z_tt(:,j)-z_t(:,j), 2);
        end
        T=T+1;
    end
    time(c)=T;

    %estimate mean
    x_tilde = zeros(1,n);
    for i=1:n
        x_tilde(i)=mean(z_t(:,i));
    end
    diff1(c) = norm(x_tilde'-x_true)^2;
	
    disp('    x_true    x_tilde');
    [x_true, x_tilde']
    disp(['||x_tilde - x_true||2 = ' mat2str(norm(x_tilde'-x_true,2)^2)])
    


end

%%
close all

figure(1)
subplot(3,1,1);
plot([1 2 3 4],time,'r*');
xticks([1 2 3 4]);
xticklabels({ 'Q1','Q2','Q3','Q4'});
title('numero di iterazioni')

subplot(3,1,2);
plot([1 2 3 4],esr,'r*');
xticks([1 2 3 4]);
xticklabels({ 'Q1','Q2','Q3','Q4'});
title('esr')


subplot(3,1,3);
plot([1 2 3 4],diff1,'r*');
xticks([1 2 3 4]);
xticklabels({ 'Q1','Q2','Q3','Q4'});
title('||x tilde - x true||2')




