clear
close all
clc
% For reproducability
rng('default')
dim  = 4;
nop  = 100;
iter = 2000;
reps = 50;

feval    = zeros(1,reps);
tElapsed = zeros(1,reps);
groupersBesteval  = zeros(reps,dim);
parfor ri=1:reps
    % Position and velocity initialization
    morays (:,1)  = (rand(nop,1)).*(99*0.0625-0.0625)+0.0625;
    morays (:,2)  = (rand(nop,1)).*(99*0.0625-0.0625)+0.0625;
    % Mixed integer problem
    %     morays (:,1)  = randi([1,99],nop,1)*0.0625;
    %     morays (:,2)  = randi([1,99],nop,1)*0.0625;
    morays (:,3)  = (rand(nop,1)).*(200-10)+10;
    morays (:,4)  = (rand(nop,1)).*(200-10)+10;

    d             = (zeros(nop,dim));
    fMorays       = zeros(nop,1);
    groupers      = zeros(nop,dim);
    fGroupers     = inf*ones(nop,1);
    groupersBest  = zeros(1,dim);
    
    fGroupersBest = inf;
    pindx = 1;
    
    profile off
    profile on -timer 'real'
    for k=1:iter
        morays  = checkx(morays,nop);
        fMorays = (0.6224*(morays(:,1).*morays(:,3).*morays(:,4)))+...
            (1.7781*morays(:,2).*morays(:,3).^2)+...
            (3.1661*morays(:,1).^2.*morays(:,4))+19.84*morays(:,1).^2.*morays(:,3);

        for i=1:nop
            if ((-morays(i,1)+0.0193*morays(i,3))>0)||...
                    ((-morays(i,2)+0.00954*morays(i,3))>0)||...
                    (((-pi*morays(i,3)^2*morays(i,4))-((4/3)*pi*morays(i,3)^3)+1296000)>0)||...
                    (morays(i,4)-240)>0
                fMorays(i,1)=10^20;
            end
            if((fMorays(i,1)<fGroupers(i,1)))
                groupers(i,:)  = morays(i,:);
                fGroupers(i,1) = fMorays(i,1);
                if(fMorays(i,1)<fGroupersBest)
                    fGroupersBest = fMorays(i,1);
                    groupersBest  = morays(i,:);
                end
            end
        end       
        if pindx<2
            d =1*(2*rand(nop,dim)-1).*abs((groupers-groupersBest));
            pindx = pindx+1;
            morays = morays + d; 
            % Mixed integer problem
            % morays (:,1:2)  = round(morays (:,1:2)./(0.0625))*0.0625;
        else
            d = 1*(2*rand(nop,dim)-1).*abs(((morays-groupersBest)));    
            pindx = 1;
            morays = groupers + d; 
            % Mixed integer problem
            % morays (:,1:2)  = round(morays (:,1:2)./(0.0625))*0.0625;
        end  
    end
    p = profile('info');
    tElapsed(ri) = p.FunctionTable.TotalTime;
    feval(ri)    = fGroupersBest;
    groupersBesteval(ri,:)    = groupersBest;
end
mfeval = min(feval);
sfeval = std(feval);
tfeval = mean(tElapsed);

f = msgbox({sprintf('Min Value = %2.10d,\n Standard Deviation = %2.10d,\n Time Elapsed = %2.10d\n'...
    ,mfeval,sfeval,tfeval)});
disp(mfeval)
disp(sfeval)
disp(tfeval)