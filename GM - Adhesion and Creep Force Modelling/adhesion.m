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

morays    = zeros(nop,dim);
groupers  = zeros(nop,dim);
gbestall  = zeros(reps,dim);
fgbestall = zeros(reps,1);
% Index for sequential movement
pindx = 1;
% Repetitions
for y=1:reps
    %%
    % Position and distance initialization
    % Positions are uniformly distributed in search space
    % Distances are equated to zero
    morays(:,1) = (rand(nop,1)).*(mu0max-mu0min)+mu0min;
    morays(:,2) = (rand(nop,1)).*(1-0)+0;
    morays(:,3) = (rand(nop,1)).*(1-0)+0;
    morays(:,4) = (rand(nop,1)).*(1-0)+0;
    morays(:,5) = (rand(nop,1)).*(.6-0)+0;
    d           = (zeros(1,dim));   
    %% Other parameters
    % Objective values of morays are initially zero
    % Objective values of groupers (pbest in PSO) and 
    % their best (gbest in PSO) are chosen large initially.
    fmorays       = zeros(nop,1);
    groupers      = zeros(nop,dim);
    fGroupers     = inf*ones(nop,1);
    groupersBest  = zeros(1,dim);
    fGroupersBest = inf;
    % Iterations
    for k=1:nIter
        % For each moray and grouper
        for i=1:nop
            % Bound Check
            morays(i,:) = checkx(morays(i,:));
            % Objective evaluation
            fmorays(i,1) = func(morays(i,:));
            % Constraint check
            if morays(i,4)<morays(i,5)
               fmorays(i,:) = 10^20; 
            end
            % If morays objective if less than corresponding grouper
            if((fmorays(i,1)<fGroupers(i,1)))
                % Check if the morays are in search space and
                % the constraint is satisfied
                groupers(i,:)  = morays(i,:);
                fGroupers(i,1) = fmorays(i,1);
                % Check if the current morays position
                % is the best of the swarm
                if(fmorays(i,1)<fGroupersBest)
                    fGroupersBest = fmorays(i,1);
                    groupersBest    = morays(i,:);
                end
            end
        end
        % Sequential position update of the swarm
        if pindx<2
            d = 1*(2*rand(nop,dim)-1).*abs((groupers-groupersBest));
            pindx = pindx+1;
            morays = morays + d;
        else
            d = 1*(2*rand(nop,dim)-1).*abs(((morays-groupersBest)));
            pindx = 1;
            morays = groupers + d;
        end
        
    end
    % All best values for repetitions are recorded
    gbestall(y,:)  = groupersBest;
    fgbestall(y,1) = fGroupersBest;
end
%% Determining the best solution found amongst repetitions
[gbest,idx] = min(fgbestall);
gbestpos    = gbestall(idx,:);
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

