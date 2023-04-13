%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt0X_.....
%
% Hensikten med programmet er å ....
% Følgende sensorer brukes:
% - Lyssensor
% - ...
% - ...
%
% Følgende motorer brukes:
% - motor A
% - ...
% - ...
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
filename = 'P0X_MeasBeskrivendeTekst_Y.mat';
%--------------------------------------------------------------------------


% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                      INITIALIZE EQUIPMENT
% Initialiser styrestikke, sensorer og motorer.
%
% Spesifiser hvilke sensorer og motorer som brukes.
% I Matlab trenger du generelt ikke spesifisere porten de er tilkoplet.
% Unntaket fra dette er dersom bruke 2 like sensorer, hvor du må
% initialisere 2 sensorer med portnummer som argument.
% Eksempel:
% mySonicSensor_1 = sonicSensor(mylego,3);
% mySonicSensor_2 = sonicSensor(mylego,4);

% For ryddig og oversiktlig kode, kan det være lurt å slette
% de sensorene og motoren som ikke brukes. 


if online
    
    % LEGO EV3 og styrestikke
    mylego = legoev3('USB');
    joystick = vrjoystick(1);
    [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);

    % sensorer
    myColorSensor = colorSensor(mylego);
    
    
%     myTouchSensor = touchSensor(mylego);
%     mySonicSensor = sonicSensor(mylego);
%     myGyroSensor  = gyroSensor(mylego);
%     resetRotationAngle(myGyroSensor);

    % motorer
    motorA = motor(mylego,'A');
    motorA.resetRotation;
    motorB = motor(mylego,'B');
    motorB.resetRotation;
%     motorC = motor(mylego,'C');
%     motorC.resetRotation;
%     motorD = motor(mylego,'D');
%     motorD.resetRotation;
    

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
    % For ryddig og oversiktlig kode, kan det være lurt å slette
    % de sensorene og motoren som ikke brukes.

    if online
        if k==1
            tic
            Tid(1) = 0
        else
            Tid(k) = toc;
        end



        % sensorer (bruk ikke Lys(k) og LysDirekte(k) samtidig)
        Lys(k) = double(readLightIntensity(myColorSensor,'reflected'));

        Refrence(k) = Lys(1);

        Avvik(k) = Lys(1) - Lys(k);
        
        %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        %                           IAE
        if k == 1
            IAE(1) = 0;
            e(1) = 0;
            Ts(1) = 0;
        else
            e(k) = abs(Avvik(k));
            Ts(k) = Tid(k) - Tid(k-1);
            IAE(k) = IAE(k-1) + (Ts(k)*e(k-1));
        end
        %------------------------------------------------------------------
        %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        %                           MAE
        if K == 1
            MAE(k) = e(k);
        else
            MAE(k) = MAE(k-1) + ((1/k).*e(k));
        end
        %------------------------------------------------------------------

%         LysDirekte(k) = double(readLightIntensity(myColorSensor));
%         Bryter(k)  = double(readTouch(myTouchSensor));
%         Avstand(k) = double(readDistance(mySonicSensor));
%         GyroAngle(k) = double(readRotationAngle(myGyroSensor));
%         GyroRate(k)  = double(readRotationRate(myGyroSensor));

        % motorer
        VinkelPosMotorA(k) = double(motorA.readRotation);
        VinkelPosMotorB(k) = double(motorB.readRotation);
%         VinkelPosMotorC(k) = double(motorC.readRotation);
%         VinkelPosMotorD(k) = double(motorC.readRotation);
        

        % Data fra styrestikke. Utvid selv med andre knapper og akser.
        % Bruk filen joytest.m til å finne koden for de andre 
        % knappene og aksene.
        [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
        JoyForover(k) = JoyAxes(2);
        JoySide(k) = JoyAxes(3);


    else
        % online=false
        % Når k er like stor som antall elementer i datavektoren Tid,
        % simuleres det at bryter på styrestikke trykkes inn.
        if k==numel(Tid)
            JoyMainSwitch=1;
        end

        % simulerer EV3-Matlab kommunikasjon i online=false
        pause(0.01)

    end
    %--------------------------------------------------------------




    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %             CONDITIONS, CALCULATIONS AND SET MOTOR POWER
    % Gjør matematiske beregninger og motorkraftberegninger
    % hvis motor er tilkoplet.
    % Kaller IKKE på en funksjon slik som i Python.

    % Parametre
    a=0.4;

    % Tilordne målinger til variabler


    % Spesifisering av initialverdier og beregninger
    if k==1
        % Initialverdier
        Ts(1) = 0.01;  % nominell verdi
    else
        % Beregninger av Ts og variable som avhenger av initialverdi
    end

    % Andre beregninger som ikke avhenger av initialverdi

    % Pådragsberegninger
    PowerA(k) = a*JoyForover(k);
    PowerB(k) = a*JoyForover(k);

%     PowerC(k) = ...
%     PowerD(k) = ...

  

    if online
        % Setter powerdata mot EV3
        % (slett de motorene du ikke bruker)

       if Lys(k) > 60
            break
       else
            if JoySide(k) < 0 && JoyForover(k) > 0
                PowerA(k) = a*JoySide(k)*0 + 0.5*a*JoyForover(k);
                PowerB(k) = a*JoySide(k)*-1 + 0.5*a*JoyForover(k);
    
            elseif JoySide(k) > 0 && JoyForover(k) > 0
                PowerA(k) = a*JoySide(k)*1 + 0.5*a*JoyForover(k);
                PowerB(k) = a*JoySide(k)*0 + 0.5*a*JoyForover(k);
            
            elseif JoySide(k) < 0 && JoyForover(k) < 0
                PowerA(k) = a*JoySide(k)*0 + 0.5*a*JoyForover(k);
                PowerB(k) = a*JoySide(k)*1 + 0.5*a*JoyForover(k);
    
            elseif JoySide(k) > 0 && JoyForover(k) < 0
                PowerA(k) = a*JoySide(k)*-1 + 0.5*a*JoyForover(k);
                PowerB(k) = a*JoySide(k)*0 + 0.5*a*JoyForover(k);
            end

        end

%         if JoySide(k) < 0 && JoyForover(k) > 0
%             PowerA(k) = a*JoySide(k)*0.2 - 0.5*a*JoyForover(k);
%             PowerB(k) = a*JoySide(k)*-1 + 0.5*a*JoyForover(k);
% 
%         elseif JoySide(k) > 0 && JoyForover(k) > 0
%             PowerA(k) = a*JoySide(k)*1 + 0.5*a*JoyForover(k);
%             PowerB(k) = a*JoySide(k)*-0.2 - 0.5*a*JoyForover(k);
%         
%         elseif JoySide(k) < 0 && JoyForover(k) < 0
%             PowerA(k) = a*JoySide(k)*-0.2 - 0.5*a*JoyForover(k);
%             PowerB(k) = a*JoySide(k)*1 + 0.5*a*JoyForover(k);
% 
%         elseif JoySide(k) > 0 && JoyForover(k) < 0
%             PowerA(k) = a*JoySide(k)*-1 + 0.5*a*JoyForover(k);
%             PowerB(k) = a*JoySide(k)*0.2 - 0.5*a*JoyForover(k);
% 
%         end

    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                               TV
        if k == 1
            PowerA(1) = 0;
            PowerB(1) = 0;
            TV_A(1) = 0;
            TV_B(1) = 0;
        else
            TV_A(k) = TV_A(k-1) + abs(PowerA(k) - PowerA(k-1));
            TV_B(k) = TV_B(k-1) + abs(PowerB(k) - PowerB(k-1));
        end
    %------------------------------------------------------------------

        motorA.Speed = PowerA(k);
        motorB.Speed = PowerB(k);
%         motorC.Speed = PowerC(k);
%         motorD.Speed = PowerD(k);

        start(motorA)
        start(motorB)
%         start(motorC)
%         start(motorD)
    end
    %--------------------------------------------------------------




    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT DATA
    % Denne seksjonen plasseres enten i while-lokka eller rett etterpå.
    % Dette kan enkelt gjøres ved flytte de 5 nederste linjene
    % før "end"-kommandoen nedenfor opp før denne seksjonen.
    %
    % Husk at syntaksen plot(Tid(1:k),data(1:k))
    % gir samme opplevelse i online=0 og online=1 siden
    % hele datasettet (1:end) eksisterer i den lagrede .mat fila

    % aktiver fig1
    figure(fig1)

    subplot(3,2,1)
    plot(Tid(1:k), Lys(1:k))
    hold on
    plot(Tid(1:k), Refrence(1:k))
    hold off
    title('Lys reflektert')
    xlabel('Tid [sek]')

    subplot(3,2,2)
    plot(Tid(1:k), Avvik(1:k))
    title('Avvik')
    xlabel('Tid [sek]')

    subplot(3,2,3)
    plot(Tid(1:k), PowerA(1:k))
    hold on
    plot(Tid(1:k), PowerB(1:k))
    hold off
    title('PowerA og PowerB')
    xlabel('Tid [sek]')

    subplot(3,2,4)
    plot(Tid(1:k), IAE(1:k));
    title('IAE')
    xlabel('Tid [sek]')

     subplot(3,2,5)
     plot(Tid(1:k), TV_A(1:k))
     hold on
     plot(Tid(1:k), TV_B(1:k))
     title('TV')
     xlabel('Tid [sek]')
% 
%     subplot(3,2,6)
%     plot(Tid(1:k),PowerB(1:k));
%     title('Power B')
%     xlabel('Tid [sek]')

    % tegn nå (viktig kommando)
    drawnow
    %--------------------------------------------------------------

    % For å flytte PLOT DATA etter while-lokken, er det enklest å
    % flytte de neste 5 linjene (til og med "end") over PLOT DATA.
    % For å indentere etterpå, trykk Ctrl-A/Cmd-A og deretter Crtl-I/Cmd-I
    %
    % Oppdaterer tellevariabel
    k=k+1;
end

% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%               STOP MOTORS

if online
    % For ryddig og oversiktlig kode, kan det være lurt å slette
    % de sensorene og motoren som ikke brukes.
    stop(motorA);
    stop(motorB);
%     stop(motorC);
%     stop(motorD);

end
%------------------------------------------------------------------





