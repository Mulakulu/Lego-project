clear
close all
time_mult = 100;
period_step = 1;
max_period = 50;
alpha_step = 0.01;
peaks_to_smooth = 10;

width = 0;      %Calculate width
for period = 2:period_step:max_period
    width = width + 1;
end
height = 0;     %Calculate height
for alpha = alpha_step:alpha_step:1-alpha_step
    height = height + 1;
end
output = zeros(height+1,width+1);
img = ones(height,width,3);
x = 1;
y = 1;
phase_waves = 1000;           %How many different phaseshifts to try
%for period = max_period:-period_step:2
for period = 2:period_step:max_period
    time = round(period*time_mult);
    func = zeros(phase_waves,time);

    %generate sine
    for k=1:1:time
        func(k+1) = cos(2*k*pi/period);
    end


    y=height;
    for alpha = alpha_step:alpha_step:1-alpha_step
        max_result = 0; prev_result = 0; going_up = 0; 
        phase_result = 0; found_peak = 0; 
        result_temp = 0;



        %run filter
        IIR_freq = zeros(1,time);
        for k=0:1:time
            if k~=0
                IIR_freq(k+1) = (1-alpha)*IIR_freq(k)+alpha*func(k+1);
            else
                IIR_freq(1) = 0;
            end
        end

        %find peaks
        filter_peak = findpeaks(IIR_freq);
        [p,filter_locs] = filter_peak{1}
        



        %calculate the phaseshift delta
        cycles = 0;
        for o = 1:1:time
            cycles = cycles + period;
            if cycles > found_peak
                delta = (found_peak - prev_cycle)/period;
                break
            end
            prev_cycle = cycles;
        end

        if result_temp > max_result
            max_result = result_temp;
            phase_result = found_peak;
        end
        prev_result = result_temp;



        %convert value to rainbow

        %result = max(result_estimate);
        %result = round(max_result*20+0.5)/20;
        result = mod(1+delta/(2*pi),1);
        if result < 1/6
            r = 1; g = 6*result; b = 0;
        elseif result < 2/6
            r = 1 - 6*(result-1/6); g = 1; b = 0;
        elseif result < 3/6
            r = 0; g = 1; b = 6*(result-2/6);
        elseif result < 4/6
            r = 0; g = 1 - 6*(result-3/6); b = 1;
        elseif result < 5/6
            r = 6*(result-4/6); g = 0; b = 1;
        else
            r = 1; g = 0; b = 1 - 6*(result-5/6);
        end
        rgb = [r, g, b];
        img(y, x,:) = rgb;
        output(y+1,x+1) = delta;
        y = y-1;
        output(y+2,1) = alpha;
    end
    output(1,x+1)= period;
    x = x+1
    imshow(img)

end