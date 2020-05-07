clear
close all
clc
% This option is selected for reproducibility of the results
rng('default')

global initial_flag
initial_flag = 0;
addpath('./CEC2005/');

list = {'CEC2005 F1','CEC2005 F2','CEC2005 F5','CEC2005 F6',...
    'CEC2005 F7','CEC2005 F9','CEC2005 F12','CEC2005 F13',...
    'CEC2005 F15','CEC2005 F16','CEC2005 F17','CEC2005 F18',...
    'CEC2005 F20','CEC2005 F21','CEC2005 F22'};

[lindx,tf] = listdlg('ListString',list);

fnum = lindx;

[ulim,llim,dim,fn] = funcdetails(fnum);

nop  = 50;
iter = 500;
reps = 30;

feval    = zeros(1,reps);
tElapsed = zeros(1,reps);

for ri=1:reps
    % Position and velocity initialization
    morays        = (rand(nop,dim)).*(ulim-llim)+llim;
    d             = (zeros(nop,dim));
    f             = zeros(nop,1);
    groupers      = zeros(nop,dim);
    fGroupers     = inf*ones(nop,1);
    groupersBest  = zeros(1,dim);
    fGroupersBest = inf;
    pindx = 1;
    
    profile off
    profile on -timer 'real'
    for k=1:iter
        morays = checkx(morays,ulim,llim,nop,dim);
        f = benchmark_func(morays,fn);
        
        for i=1:nop
            if((f(i,1)<fGroupers(i,1)))
                groupers(i,:)  = morays(i,:);
                fGroupers(i,1) = f(i,1);
                if(f(i,1)<fGroupersBest)
                    fGroupersBest   = f(i,1);
                    groupersBestIdx = i;
                    groupersBest    = morays(groupersBestIdx,:);
                end
            end
        end
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
    p = profile('info');
    tElapsed(ri) = p.FunctionTable.TotalTime;
    feval(ri)    = fGroupersBest;
end
mfeval   = mean(feval);
minfeval = min(feval);
maxfeval = max(feval);
sfeval   = std(feval);
tfeval   = mean(tElapsed);

f = msgbox({sprintf('Mean Value = %2.10d,\n Standard Deviation = %2.10d,\n Min. Value = %2.10d, \n Max. Value = %2.10d,\n Time Elapsed = %2.10d\n'...
    ,mfeval,sfeval,minfeval,maxfeval,tfeval)});
disp(mfeval)
disp(sfeval)
disp(minfeval)
disp(maxfeval)
disp(tfeval)

% Please comment out this section to write results in an excel file
% filename = 'Result.xlsx';
% writecell({strcat('Mean = ', num2str(mfeval,'%2.10d'));...
%     strcat('Min = ', num2str(minfeval,'%2.10d'));...
%     strcat('Max = ', num2str(maxfeval,'%2.10d'));...
%     strcat('Std = ', num2str(sfeval,'%2.10d'));...
%     strcat('Time Elapsed = ', num2str(tfeval,'%2.2d'))},...
%     filename,'Range','A1:A5')