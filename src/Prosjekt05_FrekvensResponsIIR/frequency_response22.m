clear
close all
load("../perfect_funcs/HDchirp.mat")
time = 10000;
IIR_freq = ones(1,time);
k=0;
b0 = 0.01;
while k<10000
    if k~=0
        IIR_freq(k+1) = (1-b0)*IIR_freq(k)+b0*chirp(k+1);
    else
        IIR_freq(1) = chirp(1);
    end
    k=k+1;
end
figure(figure)
subplot(2,1,1)
plot(1:time,chirp(1:time));
hold on %there partner
title('frequency')
ylabel('amplitude')
xlabel('Tid [k]')
subplot(2,1,2)
plot(1:time,IIR_freq(1:time));
ylim([-1 1])
title("IIR amplitude")
ylabel('amplitude')
xlabel('Tid [k]')