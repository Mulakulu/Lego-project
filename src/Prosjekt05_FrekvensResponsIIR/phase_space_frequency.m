clear
close all
time_mult = 20;
period_step = 0.1;
max_period = 50;
alpha_step = 0.0025;
width = 0;      %Calculate width
blur_factor = 3;
compression_factor = 100; %how many tests to average per pixel
for period = 2:period_step:max_period
    width = width + 1;
end
width = width*compression_factor;
height = 0;     %Calculate height
for alpha = alpha_step:alpha_step:1
    height = height + 1;
end
output = zeros(height+1,width+1);
img = ones(height,width);
x = 0;
y = 1;
phase_waves = 1;           %How many different phaseshifts to try
%for period = max_period:-period_step:2
for period = 2:period_step/compression_factor:max_period
    x = x+1
    time = round(period*time_mult);
    func = zeros(phase_waves,time);
    for j=1:1:phase_waves
        for k=1:1:time   %Generate the Sine
            func(j,k+1) = sin(2*k*pi/period);
        end
    end
    found = 0;
    y=height;
    for alpha = alpha_step:alpha_step:1-alpha_step
        [max_result,prev_result,going_up] = deal(0,0,0);

        IIR_freq = zeros(1,time);

        %run filter
        for k=0:1:time
            if k~=0
                IIR_freq(k+1) = (1-alpha)*IIR_freq(k)+alpha*func(k+1);
            else
                IIR_freq(1) = 0;
            end
        end

        result_temp = max(IIR_freq(:,round(time/4):round(time*3/4)));
        max_location = 0;
        b = round(time/4);
        while true
            if IIR_freq(b) == result_temp
                max_location = b;
                break
            end
            b = b + 1;
        end
        location_delta = 0;
        %find max location
        while true
                v = 2;
                sine_location = 0;
                prev_max_sine = 0;
                while true
                    if and(func(v)>func(v+1),func(v)>=func(v-1))
                        if v > max_location
                            break
                        else
                            prev_max_sine = v;
                        end
                    end
                    v = v + 1;
                end
                location_delta = (max_location - prev_max_sine)/period;
                break
        end

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
        

        %result = max(result_estimate);
        %result = round(max_result*20+0.5)/20;
        result = location_delta/0.22;
        img(y, x) = result;
        output(y+1,x+1) = result;
        y = y-1;
        output(y+2,1) = alpha;
    end
    output(1,x+1)= period;
end

compressed_img = zeros(height,width/compression_factor);

%squish back to intended width and average the pixel values
for y = 1:1:height
    for x = 1:1:width/compression_factor
        compressed_img(y,x) = mean(img(y,(x-1)*compression_factor+1:(x)*compression_factor));
    end
end

imshow(compressed_img)


%blur
% new_img = zeros(height, width);
% for h = 1:1:height
%     for w = 1:1:width
%         pixels = 0;
%         running_average = 1;
%         for y = -blur_factor:1:blur_factor
%             for x = -blur_factor:1:blur_factor
%                 try
%                     captured_pixels(pixels + 1) = img(h+y,w+x);
%                     pixels = pixels + 1;
%                 catch
%                 end
%             end
%         end
%         new_img(h,w) = mean(captured_pixels);
%     end
%     h
% end
% imshow(new_img)