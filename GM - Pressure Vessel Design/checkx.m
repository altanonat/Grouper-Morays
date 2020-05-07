function x = checkx(x,nop)
for i=1:nop
%     if x(i,1)<=0.0625
%         x(i,1)=0.0625;
%     end
%     if x(i,1)>=99*0.0625
%         x(i,1)=99*0.0625;
%     end
%     if x(i,2)<=0.0625
%         x(i,2)=0.0625;
%     end
%     if x(i,2)>=99*0.0625
%         x(i,2)=99*0.0625;
%     end
    if x(i,1)<=0
        x(i,1)=0;
    end
    if x(i,1)>=99
        x(i,1)=99;
    end
    if x(i,2)<=0
        x(i,2)=0;
    end
    if x(i,2)>=99
        x(i,2)=99;
    end
    %%
    if x(i,3)<=10
        x(i,3)=10;
    end
    if x(i,3)>=200
        x(i,3)=200;
    end
    %%
    if x(i,4)<=10
        x(i,4)=10;
    end
    if x(i,4)>=200
        x(i,4)=200;
    end
end
end