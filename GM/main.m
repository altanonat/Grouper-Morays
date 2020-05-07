clear
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

feval    = zeros(1,reps);
tElapsed = zeros(1,reps);

for ri=1:reps
    % Position and velocity initialization
    morays        = (rand(nop,dim)).*(ulim-llim)+llim;
    d             = (zeros(1,dim));
    fMorays       = zeros(nop,1);
    groupers      = zeros(nop,dim);
    fGroupers     = inf*ones(nop,1);
    groupersBest  = zeros(1,dim);
    fGroupersBest = inf;
    pindx = 1;
    % Profiler
    profile off
    profile on -timer 'real'
    for k=1:iter
        % bounds are checked
        morays  = checkx(morays,ulim,llim,nop,dim);
        % Function evaluation
        fMorays = getfunc(morays,fnum,nop,dim);
        % grouper and groupers' best is determined
        for i=1:nop
            if((fMorays(i,1)<fGroupers(i,1)))
                groupers(i,:)  = morays(i,:);
                fGroupers(i,1) = fMorays(i,1);
                if(fMorays(i,1)<fGroupersBest)
                    fGroupersBest = fMorays(i,1);
                    groupersBest  = morays(i,:);
                end
            end
        end
        % Update Rules
        if pindx<2
            d = 1*(2*rand(nop,dim)-1).*abs((groupers-groupersBest));
            pindx = pindx+1;
            morays = morays+d;
        else
            d = 1*(2*rand(nop,dim)-1).*abs(((morays-groupersBest)));
            pindx = 1;  
            morays = groupers+d;
        end
    end
    p = profile('info');
    tElapsed(ri) = p.FunctionTable.TotalTime;
    feval(ri)    = fGroupersBest;
end
mfeval = mean(feval);
sfeval = std(feval);
tfeval = mean(tElapsed);

f = msgbox({sprintf('Mean Value = %2.10d,\n Standard Deviation = %2.10d,\n Time Elapsed = %2.10d\n'...
    ,mfeval,sfeval,tfeval)});
disp(mfeval)
disp(sfeval)
disp(tfeval)

% Please comment out if it is required to write results in an excel sheet
% filename = 'Result.xlsx';
% writecell({strcat('Mean = ', num2str(mfeval,'%2.10d'));...
%     strcat('Std = ', num2str(sfeval,'%2.10d'));...
%     strcat('Time Elapsed = ', num2str(tfeval,'%2.2d'))},...
%     filename,'Range','A1:A3')