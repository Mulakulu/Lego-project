clear
close all
time_mult = 100;
period_step = 1;
max_period = 500;
alpha_step = 0.0025;
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
for period = max_period:-period_step:2
%for period = 2:period_step:max_period
    time = round(period*time_mult);
    func = zeros(phase_waves,time);
    phase_shift = zeros(1,time);
    for j=1:1:phase_waves
        phase_shift(j) = (2*pi*j)/phase_waves;
        for k=1:1:time   %Generate the Sine
            func(j,k+1) = cos(2*k*pi/period+phase_shift(j));
        end
    end
    found = 0;
    y=height;
    for alpha = alpha_step:alpha_step:1-alpha_step
        max_result = 0; prev_result = 0; going_up = 0; 
        phase_result = 0; found_peak = 0; 
        result_temp = 0;
        for j = 1:1:phase_waves
            IIR_freq = zeros(1,time);
            for k=0:1:time
                if k~=0
                    IIR_freq(k+1) = (1-alpha)*IIR_freq(k)+alpha*func(j,k+1);
                else
                    IIR_freq(1) = 0;
                end
            end

            %Find the highest points and the h on those points (max())
            max_result_find_peak = 0; prev_result_find_peak = 0; 
            going_up_find_peak = 0; peaks_found = 0;



            for h=round(time/4):1:time
                if and(IIR_freq(h)>IIR_freq(h-1),IIR_freq(h) >= IIR_freq(h+1))
                end
                
                if and(and(going_up_find_peak == 1,IIR_freq(h)>IIR_freq(h-1)),IIR_freq(h) >= IIR_freq(h+1))
                    %Successfully found a peak
                    found_peak_array(peaks_found+1) = h-peaks_found*period;
                    peaks_found = peaks_found + 1;
                    going_up_find_peak = 0;
                    if peaks_found == peaks_to_smooth
                        %Done
                        found_peak = mean(found_peak_array);
                        break
                    end
                end
                if and(IIR_freq(h)>IIR_freq(h-1),h>round(time/4)+2)
                    going_up_find_peak = 1;
                end
                if IIR_freq(h) > max_result_find_peak
                    max_result_find_peak = IIR_freq(h);
                end
                prev_result_find_peak = IIR_freq(h);
            end



            %Use the found max for this phase and check if it's the real
            %max
            result_temp = max_result_find_peak;
            if and(result_temp > prev_result,j > 3)
                going_up = 1;
            else
                if and(going_up == 1,result_temp < max_result)
                    break
                end
            end

            %calculate the phaseshift delta
            cycles = 0;
            for o = 1:1:time
                cycles = cycles + period;
                if cycles > found_peak
                    delta = prev_cycle - found_peak;
                    break
                end
                prev_cycle = cycles;
            end

            if result_temp > max_result
                max_result = result_temp;
                phase_result = found_peak + phase_shift(j);
            end
            prev_result = result_temp;
        end
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