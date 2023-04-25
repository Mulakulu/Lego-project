clear all

k = 0;
G = 9.81;
h_r=80;
h_d=61.45;
while k<75
    for k = 0:1:60
        v=1.33; %rise velocity
    end
    for k = 60:1:70
        v=0; %before drop
    end
    for k = 70:0.1:73.54
        v = sqrt(2*G*h_d); % drop velocity
    end
    for k = 73.54:74.61:0.01
        v = -sqrt(3.3*G*2*(h_r-h_d)); %braking velocity
    end
    k=k+1;
end

plot(k,v)
