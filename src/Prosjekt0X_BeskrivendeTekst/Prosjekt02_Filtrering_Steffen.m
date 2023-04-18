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
% Skal prosjektet gjennomføres online mot EV3 eller mot lagrede data?
online = false;
% Spesifiser et beskrivende filnavn for lagring av måledata
filename = 'P02_Stoy.mat';
%--------------------------------------------------------------------------


% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
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
%--------------------------------------------------------------------------


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                       SPECIFY FIGURE SIZE
fig1=figure;
screen = get(0,'Screensize');
set(fig1,'Position',[1,1,0.6*screen(3), 0.6*screen(4)])
set(0,'defaultTextInterpreter','latex');
set(0,'defaultAxesFontSize',14)
set(0,'defaultTextFontSize',16)
%--------------------------------------------------------------------------

JoyMainSwitch=0;
k=1;

while ~JoyMainSwitch
    %pause(0.5)
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
    %----------------------------------------------------------------------


    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %             CONDITIONS, CALCULATIONS AND SET MOTOR POWER

    % Parametre: alpha og M
    alfa1 = 0.2;
    alfa2 = 0.5;
    alfa3 = 0.7;

    M1 = 3;
    M2 = 6;
    M3 = 9;
    
    % Omgjor lyssignal til temperatursignal
    Temp(k) = Lys(k);
    %legger til målestoy
%     Temp(k) = Lys(k) + randn;

    %----------------------------------------------------------------------

    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                   IIR-filter

    if k == 1
        Temp_IIR_a1(1) = Temp(1);
        Temp_IIR_a2(1) = Temp(1);
        Temp_IIR_a3(1) = Temp(1);

    else
        Temp_IIR_a1(k) = IIR_filter(Temp_IIR_a1(k-1), Temp(k), alfa1);
        Temp_IIR_a2(k) = IIR_filter(Temp_IIR_a2(k-1), Temp(k), alfa2);
        Temp_IIR_a3(k) = IIR_filter(Temp_IIR_a3(k-1), Temp(k), alfa3);

    end
    
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                   FIR-filter

    % 3 variabler for froskjellig antall målinger
    M1 = 3;
    M2 = 6;
    M3 = 9;

    if k == 1
        Temp_FIR(k) = Lys(k);
    end

    if k < M1
        M1 = k;
    end

    if k < M2
        M2 = k;
    end

    if k < M3
        M3 = k;
    end

        Temp_FIR_M1(k) = FIR_filter(Temp(k-M1+1:k), M1);
        Temp_FIR_M2(k) = FIR_filter(Temp(k-M2+1:k), M2);
        Temp_FIR_M3(k) = FIR_filter(Temp(k-M3+1:k), M3);

    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT KAFFE

%     subplot(1,2,1)
%     plot(Tid(1:k),Temp(1:k), "b-"); hold on
%     plot(Tid(1:k),Temp_IIR_a1(1:k), "r-"); hold on
%     plot(Tid(1:k),Temp_IIR_a2(1:k), 'Color', "#FF00FF"); hold on
%     plot(Tid(1:k),Temp_IIR_a3(1:k), "g-");
%     title(['IIR-variabler:'...
%          , ' \color{red}\alpha_1=', num2str(alfa1, '%1.1f')...
%          , ', \color{magenta}\alpha_2=', num2str(alfa2, '%1.1f')...
%          , ', \color{green}\alpha_3=', num2str(alfa3, '%1.1f')]...
%          , 'Interpreter', 'tex', FontName='CMU Serif')
%     xlabel('Tid')
%     xtickformat('%g s')
%     ylabel('Kaffetemp.')
%     ytickformat('%g °C')
% 
%     subplot(1,2,2)
%     plot(Tid(1:k),Temp(1:k), "b-"); hold on
%     plot(Tid(1:k),Temp_FIR_M1(1:k), "r-");
%     plot(Tid(1:k),Temp_FIR_M2(1:k), 'Color', "#FF00FF");
%     plot(Tid(1:k),Temp_FIR_M3(1:k), "g-");
%     title(['FIR-variabler:'...
%          , ' \color{red}M_1=', num2str(M1, '%1.0f')...
%          , ', \color{magenta}M_2=', num2str(M2, '%1.0f')...
%          , ', \color{green}M_3=', num2str(M3, '%1.0f')]...
%          , 'Interpreter', 'tex', FontName='CMU Serif')
%     xlabel('Tid')
%     xtickformat('%g s')
%     ylabel('Kaffetemp.')
%     ytickformat('%g °C')
% 
%     drawnow
% 
%     movegui("center")
    %----------------------------------------------------------------------


    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT STOY

    % IIR

%     subplot(1,3,1)
%     plot(Tid(1:k),Temp(1:k), "b-"); hold on
%     plot(Tid(1:k),Temp_IIR_a1(1:k), "r-");
%     title(['IIR-variabler:'...
%          , ' \color{red}\alpha_1=', num2str(alfa1, '%1.1f')]...
%          , 'Interpreter', 'tex', FontName='CMU Serif')
%     xlabel('Tid')
%     xtickformat('%g s')
%     ylabel('Temp.')
%     ytickformat('%g °C')
% 
%     subplot(1,3,2)
%     plot(Tid(1:k),Temp(1:k), "b-"); hold on
%     plot(Tid(1:k),Temp_IIR_a2(1:k), 'Color', "#FF00FF");
%     title(['IIR-variabler:'...
%          , ', \color{magenta}\alpha_2=', num2str(alfa2, '%1.1f')]...
%          , 'Interpreter', 'tex', FontName='CMU Serif')
%     xlabel('Tid')
%     xtickformat('%g s')
%     ylabel('Temp.')
%     ytickformat('%g °C')
% 
%     subplot(1,3,3)
%     plot(Tid(1:k),Temp(1:k), "b-"); hold on
%     plot(Tid(1:k),Temp_IIR_a3(1:k), "g-");
%     title(['IIR-variabler:'...
%          , ', \color{green}\alpha_3=', num2str(alfa3, '%1.1f')]...
%          , 'Interpreter', 'tex', FontName='CMU Serif')
%     xlabel('Tid')
%     xtickformat('%g s')
%     ylabel('Temp.')
%     ytickformat('%g °C')


    % FIR

    subplot(1,3,1)
    plot(Tid(1:k),Temp(1:k), "b-"); hold on
    plot(Tid(1:k),Temp_FIR_M1(1:k), "r-");
    title(['FIR-variabler:'...
         , ' \color{red}M_1=', num2str(M1, '%1.0f')]...
         , 'Interpreter', 'tex', FontName='CMU Serif')
    xlabel('Tid')
    xtickformat('%g s')
    ylabel('Temp.')
    ytickformat('%g °C')

    subplot(1,3,2)
    plot(Tid(1:k),Temp(1:k), "b-"); hold on
    plot(Tid(1:k),Temp_FIR_M2(1:k), 'Color', "#FF00FF");
    title(['FIR-variabler:'...
         , ', \color{magenta}M_2=', num2str(M2, '%1.0f')]...
         , 'Interpreter', 'tex', FontName='CMU Serif')
    xlabel('Tid')
    xtickformat('%g s')
    ylabel('Temp.')
    ytickformat('%g °C')

    subplot(1,3,3)
    plot(Tid(1:k),Temp(1:k), "b-"); hold on
    plot(Tid(1:k),Temp_FIR_M3(1:k), "g-");
    title(['FIR-variabler:'...
         , ', \color{green}M_3=', num2str(M3, '%1.0f')]...
         , 'Interpreter', 'tex', FontName='CMU Serif')
    xlabel('Tid')
    xtickformat('%g s')
    ylabel('Temp.')
    ytickformat('%g °C')

    drawnow

    movegui("center")
    %----------------------------------------------------------------------

    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT MANUELL

%     subplot(1,2,1)
%     plot(Tid(1:k),Temp(1:k), "b-"); hold on
%     plot(Tid(1:k),Temp_IIR_a1(1:k), "r-");
%     title(['IIR-variabler:'...
%          , ' \color{red}\alpha_1 ', num2str(alfa1, '%3.2f')]...
%          , 'Interpreter', 'tex', FontName='CMU Serif')
%     xlabel('Tid')
%     xtickformat('%g s')
%     ylabel('Temp.')
%     ytickformat('%g °C')
% 
%     subplot(1,2,2)
%     plot(Tid(1:k),Temp(1:k), "b-"); hold on
%     plot(Tid(1:k),Temp_FIR_M1(1:k), "r-");
%     title(['FIR-variabler:'...
%          , ' \color{red}M_1 ', num2str(M1, '%3.2f')]...
%          , 'Interpreter', 'tex', FontName='CMU Serif')
%     xlabel('Tid')
%     xtickformat('%g s')
%     ylabel('Temp.')
%     ytickformat('%g °C')
% 
%     drawnow
% 
%     movegui("center")
    %----------------------------------------------------------------------

    % Oppdaterer tellevariabel
    k=k+1;
end

