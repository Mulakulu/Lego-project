clear
time = 1000;                 %length of the generated arrays
k=0;
fig1=figure;
screen = get(0,'Screensize');
set(fig1,'Position',[1,1,0.5*screen(3), 0.5*screen(4)])

%display plots
rows = 1;
columns = 1;

%setup arrays. Only uncomment the amount of functions you need
Tid = zeros(1,time);
func1 = zeros(1,time);
% func2 = zeros(1,time);
% func3 = zeros(1,time);
% func4 = zeros(1,time);
% func5 = zeros(1,time);
% func6 = zeros(1,time);
%------------

while k<time
    Tid(k+1) = k;

    %functions. Only uncomment the amount of functions you need
    func1(k+1) = sin((k^3)/10^7);
%     func2(k+1) = sin((k*pi)/11);
%     func3(k+1) = sin((k*pi)/7);
%     func4(k+1) = sin((k*pi)/5);
%     func5(k+1) = sin((k*pi)/3);
%     func6(k+1) = sin((k*pi)/2);
    %---------

    k=k+1;
end

%display results
if exist('func1','var') == 1
    figure(fig1)
    subplot(rows,columns,1)
    plot(Tid(1:k),func1(1:k));
    xlabel('func1')
end

if exist('func2','var') == 1
    figure(fig1)
    subplot(rows,columns,2)
    plot(Tid(1:k),func2(1:k));
    xlabel('func2')
end

if exist('func3','var') == 1
    figure(fig1)
    subplot(rows,columns,3)
    plot(Tid(1:k),func3(1:k));
    xlabel('func3')
end

if exist('func4','var') == 1
    figure(fig1)
    subplot(rows,columns,4)
    plot(Tid(1:k),func4(1:k));
    xlabel('func4')
end

if exist('func5','var') == 1
    figure(fig1)
    subplot(rows,columns,5)
    plot(Tid(1:k),func5(1:k));
    xlabel('func5')
end

if exist('func6','var') == 1
    figure(fig1)
    subplot(rows,columns,6)
    plot(Tid(1:k),func6(1:k));
    xlabel('func6')
end
%---------------

%Give names to your functions
chirp = func1;
% sinT22 = func2;
% sinT14 = func3;
% sinT10 = func4;
% sinT6 = func5;
% sinT4 = func6;
%----------------------------

drawnow