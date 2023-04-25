clear
load("..\perfect_funcs\sinT10.mat") %load function

time = 10;
func = sinT10(1:time);
time = min(time,length(func));

func_backward = zeros(1,time);
func_center = zeros(1,time);
func_forward = zeros(1,time);

for k = 1:1:time
    func_backward(k) = derivationBackward(func,k,1);
    func_center(k) = derivationCenter(func,k,2);
    func_forward(k) = derivationForward(func,k,1);
end

subplot(2,1,1)
plot(1:time,func(1:time));
xlim([1,time])
subplot(2,1,2)
plot(1:time,func_backward(1:time));
hold on
plot(1:time,func_center(1:time));
hold on
plot(1:time,func_forward(1:time));
title('FartIIR')
xlabel('Tid [sek]')
xlim([1,time])