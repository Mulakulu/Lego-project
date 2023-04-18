clear
close all
phase_waves = 29;           %How many different phaseshifts to try
time_mult = 1000;
period_step = 0.01;
max_period = 15;
alpha_step = 0.001;
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
for period = 2:period_step:max_period
    time = round(period*time_mult);
    func = zeros(phase_waves,time);
    for j=1:1:phase_waves
        for k=1:1:time   %Generate the Sine
            func(j,k+1) = sin(2*k*pi/period+2*pi*j/phase_waves);
        end
    end
    found = 0;
    y=height;
    for alpha = alpha_step:alpha_step:1-alpha_step
        result_estimate = zeros(1,phase_waves);
        for j = 1:1:phase_waves
            IIR_freq = zeros(1,time);
            for k=0:1:time
                if k~=0
                    IIR_freq(k+1) = (1-alpha)*IIR_freq(k)+alpha*func(j,k+1);
                else
                    IIR_freq(1) = 0;
                end
            end
            result_estimate(j) = max(IIR_freq(:,round(time/4):time));
        end
        result = max(result_estimate);
        img(y, x) = result;
        output(y+1,x+1) = result;
        y = y-1;
        output(y+2,1) = alpha;
    end
    output(1,x+1)= period;
    x = x+1
    imshow(img)
end