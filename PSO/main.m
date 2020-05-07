clear all
close all
clc
% This option is selected for reproducibility of the results
rng('default')

list = {'F1','F2','F3','F4','F5','F6','F7','F8','F9','F10',...
    'F11','F12','F13','F14','F15','F16','F17','F18','F19','F20',...
    'F21','F22','F23','F24','F25','F26','F27','F28','F29','F30',...
    'F31','F32','F33','F34','F35','F36'};

[lindx,tf] = listdlg('ListString',list);

fnum = lindx;
[ulim,llim,dim] = funcdetails(fnum);

nop  = 30;
iter = 300;
reps = 30;

% Define the PSO's paramters
w  = 0.9;
c1 = 2;
c2 = 2;
% Velocity Clamping
vMax = (ulim - llim)/5;
vMin = -vMax;

feval    = zeros(1,reps);
tElapsed = zeros(1,reps);

for ri=1:reps  
    % Position and velocity initialization
    x = (rand(nop,dim)).*(ulim-llim)+llim;
    v = (rand(nop,dim)).*(ulim-llim)+llim;
    f      = zeros(nop,1);
    pBest  = zeros(nop,dim);
    fpBest = inf*ones(nop,1);
    gBest  = 0;
    fBest  = inf;
    
    profile off
    profile on -timer 'real'
    for k=1:iter
        x = checkx(x,ulim,llim,nop,dim);
        f = getfunc(x,fnum,nop,dim);

        for i=1:nop    
            if((f(i,1)<fpBest(i,1)))
                pBest(i,:)  = x(i,:);
                fpBest(i,1) = f(i,1);
                if(f(i,1)<fBest)
                    fBest    = f(i,1);
                    gBestIdx = i;
                    gBest    = x(gBestIdx,:);
                end
            end
        end
        
        % Update the X and V vectors
        v = w*v+c1*rand(nop,dim).*(pBest-x)+c2*rand(nop,dim).*(gBest-x);
        
        % Check velocities
        index1 = find(v > vMax);
        index2 = find(v < vMin);
        
        v(index1) = vMax;
        v(index2) = vMin;
        
        x = x + v;
    end 
    p = profile('info');
    tElapsed(ri) = p.FunctionTable.TotalTime;
    feval(ri)    = fBest;  
end
mfeval = mean(feval);
sfeval = std(feval);
tfeval = mean(tElapsed);

f = msgbox({sprintf('Mean Value = %2.10d,\n Standard Deviation = %2.10d,\n Time Elapsed = %2.10d\n'...
    ,mfeval,sfeval,tfeval)});
disp(mfeval)
disp(sfeval)
disp(tfeval)

% filename = 'Result.xlsx';
% writecell({strcat('Mean = ', num2str(mfeval,'%2.10d'));...
%     strcat('Std = ', num2str(sfeval,'%2.10d'));...
%     strcat('Time Elapsed = ', num2str(tfeval,'%2.2d'))},...
%     filename,'Range','A1:A3')