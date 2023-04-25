clear all



% Tid=[0:0.01:74.61];
online= true;
k=1;
G = 9.81;
h_d=61.45;
h_r=80;
v(1)=0;

while k<7462
    if online
        if k==1
            tic
            Tid(1) = 0;
        else
            Tid(k) = Tid(k-1)+0.01;
        end
    end
    
    if (0<=Tid(k)) && (Tid(k)<=60)
        v(k)= -80/60;
    elseif (60<Tid(k)) && (Tid(k)<=70)
        v(k)=0;
    elseif (70<Tid(k)) && (Tid(k)<=73.54)
        v(k)=G*Tid(k)-686.7;
    elseif (73.54<Tid(k)) && (Tid(k)<=74.62)
        v(k)=-3.24*G*Tid(k)+2372.32;
    else
        v(k)=0;
    end

    k=k+1;

end

         
 plot(Tid(1:k-1),v(1:k-1))
       