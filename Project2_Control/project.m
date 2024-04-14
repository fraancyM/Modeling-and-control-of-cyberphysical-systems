clear all
close all
clc

% Parameters
A = [0 1; 880.87 0]; 
B = [0 -9.9453]';
C = [708.27 0; 0 0];
n = length(B);
N = 6; %num agents

local_obs = 1;

% Initial condition
X0=[10 0]';

% Topology
topology = 0; % Change number to change topology

if topology == 0
    % Linear topology (originale)
    Ad = [0 0 0 0 0 0; 2 0 0 0 0 0; 0 6 0 0 0 0; 0 0 1 0 0 0; 0 0 0 1 0 0; 0 0 0 0 3 0]; % adjacency matrix
    D=diag([0 2 6 1 1 3]); %in-degree matrix
    G = diag([1 0 0 0 0 0]); % c = 5

    % Ad senza pesi 
%     Ad = [0 0 0 0 0 0; 1 0 0 0 0 0; 0 1 0 0 0 0; 0 0 1 0 0 0; 0 0 0 1 0 0; 0 0 0 0 1 0];
%     D=diag([0 1 1 1 1 1]);
%     G = diag([1 0 0 0 0 0]); % c = 5

elseif topology == 1
    % Tree topology (Leader node: root)
    Ad = [0 0 0 0 0 0; 2 0 0 0 0 0; 6 0 0 0 0 0; 0 1 0 0 0 0; 0 1 0 0 0 0; 0 0 3 0 0 0];
    D=diag([0 2 6 1 1 3]); 
    G = diag([1 0 0 0 0 0]); %c = 5
    
    % Ad senza pesi
%     Ad = [0 0 0 0 0 0; 1 0 0 0 0 0; 1 0 0 0 0 0; 0 1 0 0 0 0; 0 1 0 0 0 0; 0 0 1 0 0 0];
%     D=diag([0 1 1 1 1 1]); 
%     G = diag([1 0 0 0 0 0]); %c = 5

elseif topology == 2
    % Star topology (star center leader)
    Ad = [0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0]; % Ogni nodo riceve informazioni solo dal leader, nessun collegamento tra followers
    D=diag([0 0 0 0 0 0]);
    G = diag([1 1 1 1 1 1]); % leader connected with all nodes
%     G = diag([5 5 5 5 5 5]); % G pesata c= 5

elseif topology == 3
    % Ring topology + leader centrale connesso a tutti
    Ad = [0 0 0 0 0 1; 2 0 0 0 0 0; 0 6 0 0 0 0; 0 0 1 0 0 0; 0 0 0 1 0 0; 0 0 0 0 3 0];
    D=diag([1 2 6 1 1 3]);
    G = diag([1 1 1 1 1 1]); %c=5
%     G = diag([1 4 3 2 5 4]); %G pesata %c è circa 2,5

    % Ad senza pesi
%     Ad = [0 0 0 0 0 1; 1 0 0 0 0 0; 0 1 0 0 0 0; 0 0 1 0 0 0; 0 0 0 1 0 0; 0 0 0 0 1 0];
%     D=diag([1 1 1 1 1 1]);
%     G = diag([1 1 1 1 1 1]); %c = 5
% %     G = diag([1 4 3 2 5 4]); %G pesata, c è circa 2,5

elseif topology == 4
    % Anello collegato a nodo leader
    Ad = [0 0 0 0 0 1; 2 0 0 0 0 0; 0 6 0 0 0 0; 0 0 1 0 0 0; 0 0 0 3 0 0; 0 0 0 0 1 0];
    D=diag([1 2 6 1 3 1]);
    G = diag([1 0 0 0 0 0]); % c è circa 27

    % Ad Senza pesi
%     Ad = [0 0 0 0 0 1; 1 0 0 0 0 0; 0 1 0 0 0 0; 0 0 1 0 0 0; 0 0 0 1 0 0; 0 0 0 0 1 0];
%     D=diag([1 1 1 1 1 1]);
%     G = diag([1 0 0 0 0 0]); % c è circa 42
% %     G = diag([1 4 3 2 5 4]); %G pesata, c è circa 2,5
    
elseif topology == 5
    % Mesh topology
    Ad = [0 0 0 0 0 0; 1 0 2 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 6 0 0; 0 0 0 1 3 0];
    D=diag([0 3 0 0 6 4]);
    G = diag([1 0 1 1 0 0]);
%     G = diag([1 0 3 2 0 0]); % G pesata

    % Ad senza pesi
%     Ad = [0 0 0 0 0 0; 1 0 1 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 1 0 0; 0 0 0 1 1 0];
%     D=diag([0 2 0 0 1 2]);
%     G = diag([1 0 1 1 0 0]);

elseif topology == 6
    % Full mesh topology
    Ad = [0 0 0 0 0 0; 1 0 0 0 0 0; 2 1 0 0 0 0; 3 1 6 0 0 0; 1 2 1 3 0 0; 1 1 1 4 1 0];
    D=diag([0 1 3 10 7 8]);
    G = diag([1 1 1 1 1 1]); %Leader node connesso a tutti
%     G = diag([1 5 3 2 5 4]); % G pesata

    %Ad Senza pesi
%     Ad = [0 0 0 0 0 0; 1 0 0 0 0 0; 1 1 0 0 0 0; 1 1 1 0 0 0; 1 1 1 1 0 0; 1 1 1 1 1 0];
%     D=diag([0 1 2 3 4 5]);
%     G = diag([1 1 1 1 1 1]);
end

L = D - Ad; % Laplacian matrix

eig_L = sort(eig(L));
eig_L(2); % Fiedler eigenvalue -> a large value is better for achieving convergence

% Observer y0
Aob = obsv(A,C);
rank(Aob);
Lun = place(A',C',[-10 -20]);
Lun=Lun';

% Controller
Actr=ctrb(A,B);
rank(Actr);

% OUTPUT
output = 0; %Change number to have different output

if output == 0
    % Output zero
    lam_ctrl = [-1 -2];
    Kctrl = place(A,B,lam_ctrl);

elseif output == 1
    % Constant
    lam_ctrl = [-1 0];
    Kctrl = place(A,B,lam_ctrl);

elseif output == 2
    % Sinusoidal signal
    lam_ctrl = [5*j -5*j];
    Kctrl = place(A,B,lam_ctrl);

elseif output == 3
    % Ramp
    % Change initial condition
    X0=[10 2]';
    lam_ctrl = [0 0];
    Kctrl = acker(A,B,lam_ctrl); % Molteplicità > 1
end

% Design of parameter c
lam_g = eig(L+G);
c = 10/(2*min(real(lam_g))); % Coupling gain
%c=c*10;

A=A-B*Kctrl;
eig(A);

% LQ controller design
q = 1;
r = q/10;
Q = q*eye(n);
R = r;
Pc = are(A,B*R^-1*B', Q);
K = R^-1*B'*Pc;
Pf = are(A',C'*R^-1*C, Q);

% noise on y
noise = randn;

if local_obs==0
    F = Pf*C'*R^-1;
    open('sim_project1.slx');
    out=sim('sim_project1.slx');
else
%     F = - Pf*C'*R^-1;
    Fc=place(A',C',[-1 -2]); % Fc = c*F
    F=Fc/c;
    F=-F';
    open('sim_project2.slx');
    sim('sim_project2.slx');
end


%%
y0=out.Y.Data(:,1);
y1=out.Y.Data(:,2);
y2=out.Y.Data(:,3);
y3=out.Y.Data(:,4);
y4=out.Y.Data(:,5);
y5=out.Y.Data(:,6);
y6=out.Y.Data(:,7);
time=out.Y.Time;
%%
Tconv=10;
Tconsensus=10;

for t=10:length(time)
    %Tconvergenza : media distanza da S0
    m=mean([norm(y1(t)-y0(t)),norm(y2(t)-y0(t)),norm(y3(t)-y0(t)),norm(y4(t)-y0(t)),norm(y5(t)-y0(t)),norm(y6(t)-y0(t))]);
    if( m < 50 && Tconv == 10 )
        Tconv = time(t);
    end
    
    %Tconsensus : distanza fra i due agenti più diversi
    yy=sort([y1(t) y2(t) y3(t) y4(t) y5(t) y6(t)]);    
    if( norm(yy(1)-yy(6)) < 50 && Tconsensus==10 )
        Tconsensus = time(t);
    end      
   
    %altro metodo per Tcons, media distanza fra due agenti vicini
%     sum2=0;
%     for i=1:5
%         sum2 = sum2 + norm(yy(i)-yy(i+1));
%     end
%     if( sum2/6 < 10 && Tconsensus==10 )
%         Tconsensus = time(t);
%     end      

end

disp(['tempo di convergenza = ' mat2str(Tconv)]);
disp(['tempo di consensus = ' mat2str(Tconsensus)]);
disp(' ');

% Ac is hurwitz
%  Ac=kron(eye(6),A)-c*kron((L+G),B*K);
%  eig(Ac);

% Ao is hurwitz
% Ao=kron(eye(6),A)-c*kron((L+G),F);
% eig(Ao);