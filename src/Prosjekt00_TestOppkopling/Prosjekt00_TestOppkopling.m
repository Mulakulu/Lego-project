%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt00_TestOppkopling
%
% Hensikten med programmet er å teste at opplegget fungerer på PC/Mac
% Følgende sensorer brukes:
% - Lyssensor
%
% Følgende motorer brukes:
% - motor A
%
%--------------------------------------------------------------------------


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                EXPERIMENT SETUP AND DATA FILENAME
%
% Alltid lurt å rydde workspace opp først
clear; close all
% Skal prosjektet gjennomføres online mot EV3 eller mot lagrede data?
online = true;
% Spesifiser et beskrivende filnavn for lagring av måledata
filename = 'P00_MeasTest_1.mat';
%--------------------------------------------------------------------------


% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                 INITIALIZE EQUIPMENT
% Initialiser styrestikke, sensorer og motorer.
%
% Spesifiser hvilke sensorer og motorer som brukes.
% I Matlab trenger du generelt ikke spesifisere porten de er tilkoplet.
% Unntaket fra dette er dersom bruke 2 like sensorer, for da må
% du initialisere 2 sensorer med portnummer som argument.
% Eksempel:
% mySonicSensor_1 = sonicSensor(mylego,3);
% mySonicSensor_2 = sonicSensor(mylego,4);

% For ryddig og oversiktlig kode, kan det være lurt å slette
% de sensorene og motoren som ikke brukes, alternativt kommentere koden
% ut med %{ før og %} etter.

if online

    % LEGO EV3 og styrestikke
    mylego = legoev3('USB');
    joystick = vrjoystick(1);
    [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);

    % sensorer
    myColorSensor = colorSensor(mylego);

    % motorer
    motorA = motor(mylego,'A');
    motorA.resetRotation;
else
    % Dersom online=false lastes datafil.
    load(filename)
end


disp('Equipment initialized.')
%----------------------------------------------------------------------



%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                       SPECIFY FIGURE SIZE
fig1=figure;
screen = get(0,'Screensize');
set(fig1,'Position',[1,1,0.5*screen(3), 0.5*screen(4)])
set(0,'defaultTextInterpreter','latex');
set(0,'defaultAxesFontSize',14)
set(0,'defaultTextFontSize',16)
%----------------------------------------------------------------------

% setter skyteknapp til 0, og tellevariabel k=1
JoyMainSwitch=0;
k=1;

while ~JoyMainSwitch
    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                       GET TIME AND MEASUREMENT
    % Få tid og målinger fra sensorer, motorer og joystick
    %
    % For ryddig og oversiktlig kode, er det lurt aa slette
    % de sensorene og motoren som ikke brukes.

    if online
        if k==1
            tic
            Tid(1) = 0;
        else
            Tid(k) = toc;
        end

        % sensorer
        Lys(k) = double(readLightIntensity(myColorSensor,'reflected'));

        % motorer
        VinkelPosMotorA(k) = double(motorA.readRotation);

        % Data fra styrestikke. Utvid selv med andre knapper og akser
        [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
        JoyForover(k) = JoyAxes(2);
    else
        % online=false
        % Naar k er like stor som antall elementer i datavektoren Tid,
        % simuleres det at bryter paa styrestikke trykkes inn.
        if k==numel(Tid)
            JoyMainSwitch=1;
        end

        % simulerer EV3-Matlab kommunikasjon i online=false
        pause(0.01)

    end
    %--------------------------------------------------------------






    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %             CONDITIONS, CALCULATIONS AND SET MOTOR POWER
    % Gjoer matematiske beregninger og motorkraftberegninger
    % hvis motor er tilkoplet

    % Parametre
    a=0.7;
    b=0.4;
    c=0.01;

    % Tilordne maalinger til variable
    dummy(k) = Lys(k);

    % Spesifisering av initialverdier og beregninger
    if k==1
        % Initialverdier
        referanse = dummy(1);
    else
        % Beregninger av Ts og variable som avhenger av initialverdi
    end


    % Andre beregninger som ikke avhenger av initialverdi
    if JoyForover(k) ~= 0
        % kan ikke dividere paa 0
        VinkelPos_vs_Forward(k)=VinkelPosMotorA(k)/JoyForover(k);
    else
        % dersom joyForover = 0, benytt justert dummy-verdi
        VinkelPos_vs_Forward(k)=VinkelPosMotorA(k)/(dummy(k)+3);
    end


    % Paadragsberegning
    PowerA(k)= b*JoyForover(k);

    if k==1
        summeringAvPowerA(1)=0;
    else
        summeringAvPowerA(k)=summeringAvPowerA(k-1)+PowerA(k);
    end

    if online
        % Setter powerdata mot EV3
        % (slett de motorene du ikke bruker)
        motorA.Speed = PowerA(k);
        start(motorA)
    end
    %--------------------------------------------------------------



    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT DATA
    % Denne plasseres enten i while-lokka eller rett etterpaa.
    % Dette kan enkelt gjoeres ved flytte de 5 nederste linjene
    % foer 'end'-kommandoen nedenfor opp foer denne seksjonen.
    % Alternativt saa kan du lage en egen .m-fil for plottingen som du
    % kaller paa.
    %
    % Husk at syntaksen plot(Tid(1:k),data(1:k))
    % for gir samme opplevelse i online=0 og online=1 siden
    % hele datasettet (1:end) eksisterer i den lagrede .mat fila

    figure(fig1)
    subplot(2,2,1)
    plot(Tid(1:k),VinkelPosMotorA(1:k));
    xlabel('Tid [sek]')
    title('Vinkelposisjon motor A')

    subplot(2,2,2)
    plot(Tid(1:k),PowerA(1:k));
    xlabel('Tid [sek]')
    title('PowerA')

    subplot(2,2,3)
    plot(Tid(1:k),summeringAvPowerA(1:k));
    xlabel('Tid [sek]')
    title('Summering av PowerA')

    subplot(2,2,4)
    plot(Tid(1:k),VinkelPos_vs_Forward(1:k));
    xlabel('Tid [sek]')
    title('Vinkelposisjon vs joyForover')

    % tegn naa (viktig kommando)
    drawnow
    %--------------------------------------------------------------

    % oppdater tellevariabel
    k=k+1;
end


% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                STOP MOTORS

if online
    % For ryddig og oversiktlig kode, er det lurt aa slette
    % de sensorene og motoren som ikke brukes.
    stop(motorA);
end
%------------------------------------------------------------------





