clear all
close all
clc

p = 100;
q = 25;
h = 2; % a is h-sparse
j = 4;
aware = 0;

data=importdata("task4data.mat");
sensor_data = importdata("task4_sensors_positions.mat");

A=data.A;
D=data.D;
G = [D,eye(q)];
G_norm = normalize(G);
z=zeros(p+q,1);

sigma = 0.2;
nu = randn * sigma;
tau = norm(G_norm,2)^(-2) - 1e-8;
lambda_v = tau*[10*ones(p,1);20*ones(q,1)];

% x_true generation
s1=randperm(p); % support
s1=s1(1:j);
x_true = zeros(p,1); 
for i = 1:j
  x_true(s1(i)) = 1; 
end

% Support of 'a' generation
s=randperm(q); % support
s=s(1:h); % a is a h-sparse vector

T=100; % Stop criterion k

% Graph generation
figure(1)
% x_p and y_p = sensors coordinates
x_p = sensor_data(1,:);
y_p = sensor_data(2,:);
%plot sensors
plot(x_p,y_p,'o', 'Color','green', 'MarkerFaceColor', 'green', 'MarkerSize', 14)
hold on
%plot sensors under attack
plot(x_p(s),y_p(s),'x', 'Color','red', 'MarkerSize', 18)
hold on
grid on

x_y = zeros(4,1);
y_y = zeros(4,1);
x_b = zeros(4,1);
y_b = zeros(4,1);

z_k=zeros(p+q,1);
z_k1=zeros(p+q,1);

% Initialization IST
t=0;   

% IST ALGORITHM
while (t==0 || t<T)
    y = D * x_true + nu;
    a = zeros(q,1); % Allocate space for random values
    if aware == 0 % Unaware attacks
        for i = 1:h
          a(s(i)) = 30; 
        end
    else % Aware attacks
        for i = 1:h
          a(s(i)) = y(s(i))/2;
        end
    end
    % Measurement noise
    y = y + a;

    temp = z_k + tau * G_norm' * (y - G_norm * z_k);
    for i=1:(p+q)
        if(temp(i) > lambda_v(i))
            z_k1(i) = temp(i) - lambda_v(i);
        end
        if(temp(i) < -lambda_v(i))
            z_k1(i) = temp(i) + lambda_v(i);
        end
        if(abs(temp(i)) <= lambda_v(i))
            z_k1(i) = 0;
        end
    end
    x_true = A * x_true;

    z_k(1:p)=A*z_k1(1:p); % calculate x(k+1) = A * x(k)

    % cleaning for the attacks:
    z_k(p+1:end)=z_k1(p+1:end);
    ak=find(abs(z_k(p+1:end))>=2);
    
    if ~isempty(ak) 
        hold on
        %plot estimated attacks
        h3=plot(x_p(ak),y_p(ak),'o', 'Color','blue', 'MarkerSize', 18);
    end

    % take the j = 4 largest components for the estimation
    zm=z_k(1:p);
    z_max = zeros(4,1);
    [M,I]=max(zm);
    z_max(1)=I;
    for l=2:4
        zm(I) = 0;
        [M,I]=max(zm);
        z_max(l)=I;
    end

    z_max=sort(z_max);
    x_tt=find(x_true);

    [find(x_true), z_max]

    % plot target
    x_tt = find(x_true);
    for l=1:length(x_tt)
        x_tm = mod(x_tt(l),10);
        if x_tm>0 && x_tm<5
            y_t = 1000 - (round(x_tt(l)/10) + 1)*100 + 50;
            x_t = (x_tm - 1)*100 + 50;
        else
            if x_tm == 0
                x_t = 950; 
            else 
                x_t = (x_tm - 1)*100 + 50;
            end
            y_t = 1000 - (round(x_tt(l)/10))*100 + 50;
        end
        x_y(l)=x_t;
        y_y(l)=y_t;
    end
    % plot estimated target
    for l=1:length(z_max)
        x_tm = mod(z_max(l),10);
        if x_tm>0 && x_tm<5
            y_t = 1000 - (round(z_max(l)/10) + 1)*100 + 50;
            x_t = (x_tm - 1)*100 + 50;
        else
            if x_tm == 0
                x_t = 950; 
            else 
                x_t = (x_tm - 1)*100 + 50;
            end
            y_t = 1000 - (round(z_max(l)/10))*100 + 50;
        end
        x_b(l)=x_t;
        y_b(l)=y_t;
    end
    h1=plot(x_y,y_y,'square', 'Color','yellow', 'MarkerFaceColor', 'yellow', 'MarkerSize', 18);
    h2=plot(x_b,y_b,'square', 'Color','blue', 'MarkerSize', 22);

    %legend({'Sensors', 'Sensors under attack', 'Estimated attacks', 'Target', 'Estimated targets'})

    pause(1)
    delete(h1)
    delete(h2)
    if ~isempty(ak)
        delete(h3)
    end

    t=t+1;
end