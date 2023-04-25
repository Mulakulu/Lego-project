clear
close all
time_mult = 100;
period_step = 0.1;
max_period = 50;
alpha_step = 0.0025;
width = 0;      %Calculate width
for period = 2:period_step:max_period
    width = width + 1;
end
height = 0;     %Calculate height
for alpha = alpha_step:alpha_step:1-alpha_step
    height = height + 1;
end
output = zeros(height+1,width+1);
img = ones(height,width);
x = 1;
y = 1;
phase_waves = 1000;           %How many different phaseshifts to try
%for period = max_period:-period_step:2
for period = 2:period_step:max_period
    time = round(period*time_mult);
    func = zeros(phase_waves,time);
    for j=1:1:phase_waves
        for k=1:1:time   %Generate the Sine
            func(j,k+1) = sin(2*k*pi/period+(2*pi*j)/phase_waves);
        end
    end
    found = 0;
    y=height;
    for alpha = alpha_step:alpha_step:1-alpha_step
        [max_result,prev_result,going_up] = deal(0,0,0);
        for j = 1:1:phase_waves
            IIR_freq = zeros(1,time);
            for k=0:1:time
                if k~=0
                    IIR_freq(k+1) = (1-alpha)*IIR_freq(k)+alpha*func(j,k+1);
                else
                    IIR_freq(1) = 0;
                end
            end
            result_temp = max(IIR_freq(:,round(time/4):time));
            if and(result_temp > prev_result,j > 3)
                going_up = 1;
            else
                if and(going_up == 1,result_temp < max_result)
                    break
                end
            end
            if result_temp > max_result
                max_result = result_temp;
            end
            prev_result = result_temp;
        end
        %result = max(result_estimate);
        result = round(max_result*20+0.5)/20;
        img(y, x) = result;
        output(y+1,x+1) = result;
        y = y-1;
        output(y+2,1) = alpha;
    end
    output(1,x+1)= period;
    x = x+1
end
imshow(img)