clear
close all
b0 = 0.25;
figure(figure)
for t=1:5
    k=0;
    switch t
        case 1; sine = load("..\perfect_funcs\sinT22.mat");
        case 2; sine = load("..\perfect_funcs\sinT14.mat");
        case 3; sine = load("..\perfect_funcs\sinT10.mat");
        case 4; sine = load("..\perfect_funcs\sinT6.mat");
        case 5; sine = load("..\perfect_funcs\sinT4.mat");
    end
    fields = fieldnames(sine);      %find name of array variable
    arrayValues = sine.(fields{1}); %extract array out of struct
    time = length(arrayValues);     %assume all funcs have same len
    IIR_freq = ones(1,time);        %reset filter
    while k<time
        if k~=0
            IIR_freq(k+1) = (1-b0)*IIR_freq(k)+b0*arrayValues(k+1);
        else
            IIR_freq(1) = arrayValues(1);
        end
        k=k+1;
    end
    subplot(1,1,1)
    plot(1:time,IIR_freq(1:time));
    hold on %there partner
    title('IIR amplitude')
    ylim([-1 1])
    ylabel('amplitude')
    xlabel('Tid [k]')
    findMax = IIR_freq(:,time-99:time); %remove first part of output
    max(findMax)                        %find amplitude when stable
end