%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt02_Filtrering
%
% Hensikten med programmet er å filtrere et signal
% Følgende sensorer brukes:
% - Lyssensor
%
%--------------------------------------------------------------------------


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                EXPERIMENT SETUP AND DATA FILENAME
clear; close all
online = false;
filename = 'treg_sin.mat';
%--------------------------------------------------------------------------


% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                      INITIALIZE EQUIPMENT

if online
    
    % LEGO EV3 og styrestikke
    mylego = legoev3('USB');
    joystick = vrjoystick(1);
    [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);

    % sensorer
    myColorSensor = colorSensor(mylego);

else
    load(filename)
end

disp('Equipment initialized.')
%----------------------------------------------------------------------


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                DEFINE THE ALFAS OF THE FIR INPUTS
%   1 = moving average  (1*(k-2)+1*(k-1)+1*(k))/3  <-sum of alphas
%   2 = slope           (1*(k-2)+2*(k-1)+3*(k))/6  <-sum of alphas
%   3 = exponent        (1*(k-2)+4*(k-1)+9*(k))/14 <-sum of alphas
%lookback = 5; %Definerer hvor mye FIR filtered ser tilbake
%spreadtype = 2;
%switch spreadtype
    %case 1
        %alfas(1:lookback) = 1/sum(lookback)
    %case 2
        %alfas(1:lookback) = (1:lookback)/sum(1:lookback)
    %case 3
        %alfas(1:lookback) = (power(1:lookback,2))/sum(power(1:lookback,2))
    %otherwise
%end
%--------------------------------------------------------------------------


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                       SPECIFY FIGURE SIZE
fig1=figure;
screen = get(0,'Screensize');
set(fig1,'Position',[1,1,0.5*screen(3), 0.5*screen(4)])
set(0,'defaultTextInterpreter','latex');
set(0,'defaultAxesFontSize',14)
set(0,'defaultTextFontSize',16)
%----------------------------------------------------------------------

JoyMainSwitch=0;
k=1;

while ~JoyMainSwitch
    
%     pause(0.5)

    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                       GET TIME AND MEASUREMENT

    if online
        if k==1
            tic
            Tid(1) = 0;
        else
            Tid(k) = toc;
        end

        % sensorer
        Lys(k) = double(readLightIntensity(myColorSensor,'reflected'));

        [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
        JoyForover(k) = JoyAxes(2);

    else
        if k==numel(Tid)
            JoyMainSwitch=1;
        end

        % simulerer EV3-Matlab kommunikasjon i online=false
        pause(0.01)

    end
    %--------------------------------------------------------------




    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %             CONDITIONS, CALCULATIONS AND SET MOTOR POWER

    % Parametre
    a=0.7;

    % Tilordne målinger til variabler


    % Spesifisering av initialverdier og beregninger
    a1=5;
    a2=-5;
    meanFlow = 4.5;
    if k==1
        Nullflow = Lys(1);
        V(1) = 7;
        Ts(1) = 0.0;
        %Flow(1) = -meanFlow; %Del 2
        Flow(1) = 0;% nominell verdi
    else
        %Flow(k)=a2;   
        %definer nominell initialverdi for Ts
        Flow(k) = Lys(k)- Nullflow;
        %Flow(k) = Lys(k)- Nullflow - meanFlow; %Del 2
        %beregn Flow(k) som "Lys(k)-nullflow"
        Ts(k) = Tid(k) - Tid(k-1);
        %beregn tidsskrittet Ts(k)
        V(k)= V(k-1)+Ts(k)*(Flow(k-1));
        %V(k)=a2*Tid(k);
    end

    % Andre beregninger som ikke avhenger av initialverdi

    %--------------------------------------------------------------


    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT FLOW

    % aktiver fig1
    figure(fig1)

    subplot(2,2,2)
    plot(Tid(1:k),Flow(1:k));
    title('Flow')
    xlabel('Tid [sek]')
    
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                   IIR-filter
    alfa = 0.6;
    if k ~= 1
        Temp_IIR(k) = (1-alfa) * Temp_IIR(k-1) + alfa * Flow(k);
        
    else
        Temp_IIR(1) = Flow(1);
    end
    
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                   FIR-filter

    M=3; %Antall målinger
    %Temp_FIR(k) = Lys(k);
    if k == 1
        Temp_FIR(k) = Lys(k);
    end

    if k < M
        M=k;
    end
        Temp_FIR(k) = 1/M*sum(Lys(k-M+1:k));

    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT FILTERS

    subplot(2,2,4)
    plot(Tid(1:k),Temp_IIR(1:k));
    title('(IIR)Flow filtrert med faktor: ', alfa)
    xlabel('Tid [sek]')

    subplot(2,2,1)
    plot(Tid(1:k),Temp_FIR(1:k));
    title('(FIR)Flow filtrert med faktor: ', M)
    xlabel('Tid [sek]')

    drawnow
    %--------------------------------------------------------------

    % Oppdaterer tellevariabel
    k=k+1;
end

