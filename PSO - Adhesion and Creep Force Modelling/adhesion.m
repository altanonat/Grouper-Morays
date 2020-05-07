close all
clc
clear all
%% For reproducability of the results
rng default
%% Globals used in functions
global sx mumeas w N mu epsilon C a b mu0min mu0max
%%
% Shear Modulus of rigidity in pa
G = 8*10^10;
% Contact Patch
a  = 0.001837;
b  = 0.002080;
nu = 0.3; % Poisson Ratio
%%
% Kalker's Coefficients c11
abratio = b/a;
k1      =  2.3464+1.5443*nu+7.9577*(nu^2);
k2      =  0.961669-0.043513*nu+2.402357*(nu^2);
k3      = -0.0160185+0.0055475*nu-0.0741104*(nu^2);
k4      =  0.10563+0.61285*nu-7.26904*(nu^2);
c11     =  (k1)+(k2/(abratio))+(k3/(abratio^2))+(k4/sqrt(abratio));
C       = 3/8*(G/a)*c11;
gamma   = 0.0573;       % in radians
Q       = 4269;         % in Newtons
N       = Q/cos(gamma); % in Newtons
%%
% Measurements for dry conditions
load('measurement')
% Translational speed
vw = 5/3.6;
% Slip velocity
w = vw.*sx;
%% Particle Initialization
% Number of particles
nop  = 30;
% Dimension
dim  = 5;
% Repetitions
reps = 30;
% Number of iterations
nIter = 500;

% Static Friction Coefficient Limits
mu0min = 0.02;
mu0max = 0.7;

x         = zeros(nop,dim);
pbest     = zeros(nop,dim);
gbestall  = zeros(reps,dim);
fgbestall = zeros(reps,1);
% Particle Swarm parameters
c1     = 2;
c2     = 2;
winert = 0.9;
% Repetitions
for y=1:reps
    %%
    % Particle and velocity initialization
    % Positions are distributed randomly in search space
    % Velocities are distributed randomly
    x(:,1) = (rand(nop,1)).*(mu0max-mu0min)+mu0min;
    x(:,2) = (rand(nop,1)).*(1-0)+0;
    x(:,3) = (rand(nop,1)).*(1-0)+0;
    x(:,4) = (rand(nop,1)).*(1-0)+0;
    x(:,5) = (rand(nop,1)).*(.6-0)+0;
    v      = (rand(nop,dim)).*(1-0)+0;
    %% Other parameters
    % Objective values of particles are initially zero
    % Objective values of pbest and 
    % their gbest are chosen large initially.
    f        = zeros(nop,1);
    pbest    = zeros(nop,dim);
    fpbest   = inf*ones(nop,1);
    gbest    = zeros(1,dim);
    gbestsse = inf;
    
    for k=1:nIter
        % For each particle
        for i=1:nop
            % Bound Check
            x(i,:) = checkx(x(i,:));
            % Objective evaluation
            f(i,:) = func(x(i,:));
            % Constraint check
            if x(i,4)<x(i,5)
               f(i,:) = 10^20; 
            end
            % If particle objective if less than corresponding local best
            if((f(i,1)<fpbest(i,1)))               
                pbest(i,:)  = x(i,:);
                fpbest(i,1) = f(i,1);
                % If particle objective if less than corresponding
                % global best
                if(f(i,1)<gbestsse)
                    gbestsse = f(i,1);
                    gbest    = x(i,:);
                end
            end
        end
        % Position and velocity update
        v = winert*v + c1*rand(nop,dim).*...
            (pbest-x)+c2*rand(nop,dim).*(gbest-x);
        % Velocity clamping
        v(v>0.1)  =  0.1;
        v(v<-0.1) = -0.1;
        x         = x+v;
    end
    % All best values for repetitions are recorded
    gbestall(y,:)  = gbest;
    fgbestall(y,1) = gbestsse;
end
%% Determining the best solution found amongst repetitions
[gbest,idx] = min(fgbestall);
gbestpos = gbestall(idx,:);
% Best value is written to message box
f = msgbox({sprintf('Best Value = %2.10d,\n',gbest)});
%% This part includes the calculation of adhesion for plotting
mu = gbestpos(1,1).*((1-gbestpos(1,2)).*exp(-gbestpos(1,3).*w)+gbestpos(1,2));
% Gradient of tangential stress in the area of adhesion
epsilon = (2/3).*((C.*pi.*((a).^2).*(b))./(N.*mu)).*sx;
% Creep Force
Fx = -((2.*N.*mu)/(pi)).*(((gbestpos(1,4).*epsilon)./...
    (1+(gbestpos(1,4).*epsilon).^2))+atan(gbestpos(1,5).*epsilon));
%%
figure(1)
plot (sx,-(Fx./N),'LineWidth',4)
hold on
grid on
plot(sx,mumeas,'*');
hold on
xlim([0 max(sx)])
ylim([0 0.4])
title('Adhesion Model')
xlabel('Creepage')
ylabel('Coefficient of Adhesion (COA)')

