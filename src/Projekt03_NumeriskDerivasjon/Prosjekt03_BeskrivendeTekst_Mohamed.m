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
online = false;
% Spesifiser et beskrivende filnavn for lagring av måledata
filename = 'DerivasjonChirp.mat';
% Definer variabler
alfa = 0.2; %Hvor mye effekt ny data har på verdien i prosent
Flowmean = 0.8670; %Beregnet mean(Flow)
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
    
    %{
    myTouchSensor = touchSensor(mylego);
    mySonicSensor = sonicSensor(mylego);
    myGyroSensor  = gyroSensor(mylego);
    resetRotationAngle(myGyroSensor);

    % motorer
    motorA = motor(mylego,'A');
    motorA.resetRotation;
    motorB = motor(mylego,'B');
    motorB.resetRotation;
    motorC = motor(mylego,'C');
    motorC.resetRotation;
    motorD = motor(mylego,'D');
    motorD.resetRotation;
    %}

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
            Tid(1) = 0;
        else
            Tid(k) = toc;
        end

        % sensorer (bruk ikke Lys(k) og LysDirekte(k) samtidig)
        Lys(k) = double(readLightIntensity(myColorSensor,'reflected'));
       % Avstand(k) = double(readDistance(mySonicSensor));

        %{
        LysDirekte(k) = double(readLightIntensity(myColorSensor));
        Bryter(k)  = double(readTouch(myTouchSensor));
        Avstand(k) = double(readDistance(mySonicSensor));
        GyroAngle(k) = double(readRotationAngle(myGyroSensor));
        GyroRate(k)  = double(readRotationRate(myGyroSensor));

        % motorer
        VinkelPosMotorA(k) = double(motorA.readRotation);
        VinkelPosMotorB(k) = double(motorB.readRotation);
        VinkelPosMotorC(k) = double(motorC.readRotation);
        VinkelPosMotorD(k) = double(motorC.readRotation);
        %}

        % Data fra styrestikke. Utvid selv med andre knapper og akser.
        % Bruk filen joytest.m til å finne koden for de andre 
        % knappene og aksene.
        [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
        JoyForover(k) = JoyAxes(2);
      %  Avstand(k) = double(readDistance(mySonicSensor));

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
  
    %a=0.7;
        if k~=1
      Smooth(k) = (1-alfa)*Smooth(k-1)+alfa*Lys(k);
    else
        Smooth(1) = Lys(1);
    end
    % Tilordne målinger til variabler
     %Avstand(k) = double(readDistance(mySonicSensor));
    % Spesifisering av initialverdier og beregninger
   % a1=5;
   % a2=-5;
    if k==1
        Avstand(1)=Lys(1);
        AvstandIIR(1)=Smooth(k);
       % Nullflow = Lys(1)+2.84;
       % V(1) = 0.0;
        Ts(1) = 0.0;
        Fart(1)=0;
        FartIIR(1)=0;
       % Flow(1) = -Flowmean;% nominell verdi
    else
        Ts(k) = Tid(k) - Tid(k-1);
        Avstand(k) = Lys(k);
        AvstandIIR(k)= alfa*Avstand(k)+(1-alfa)*(AvstandIIR(k-1));
        Fart(k) = (Avstand(k)-Avstand(k-1))/Ts(k);
        FartIIR(k) = (AvstandIIR(k)-AvstandIIR(k-1))/Ts(k);

        %Flow(k)=a2;   
        %definer nominell initialverdi for Ts
        %Flow(k) = Lys(k)- Nullflow-Flowmean;
        %beregn Flow(k) som "Lys(k)-nullflow"
        
        %beregn tidsskrittet Ts(k)
       % V(k)= V(k-1)+Ts(k)*(Flo ...);
            %w(k-1));
        %V(k)=a2*Tid(k);
        %beregn Volum(k) vha Eulers forovermetode  % Beregninger av Ts og variable som avhenger av initialverdi
   
    end

    % Andre beregninger som ikke avhenger av initialverdi

    % Pådragsberegninger
    %PowerA(k) = a*JoyForover(k);
    %PowerB(k) = ...
    %PowerC(k) = ...
    %PowerD(k) = ...

    if online
        % Setter powerdata mot EV3
        % (slett de motorene du ikke bruker)
        %motorA.Speed = PowerA(k);
        %motorB.Speed = PowerB(k);
        %motorC.Speed = PowerC(k);
        %motorD.Speed = PowerD(k);

        %start(motorA)
        %start(motorB)
        %start(motorC)
        %start(motorD)
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

   
    %subplot(2,2,2)
    %plot(Tid(1:k),Flow(1:k));
    %title('Flow')
    %xlabel('Tid [sek]')

   % subplot(2,2,3)
   % plot(Tid(1:k),V(1:k));
   % title('Volum')
   % xlabel('Tid [sek]')

    subplot(2,2,2)
    plot(Tid(1:k),Fart(1:k));
    title('Fart')
    xlabel('Tid [sek]')

    subplot(2,2,3)
    plot(Tid(1:k),FartIIR(1:k));
    title('FartIIR')
    xlabel('Tid [sek]')

    subplot(2,2,1)
    plot(Tid(1:k),Avstand(1:k));
    hold on
    plot(Tid(1:k),AvstandIIR(1:k));
    hold off
    title('Avstand')
    xlabel('Tid [sek]')
    
    
    %if k~=1
     % Smooth(k) = (1-alfa)*Smooth(k-1)+alfa*Lys(k);
   % else
    %    Smooth(1) = Lys(1);
    %end
   
   

    %subplot(2,2,4)
    %plot(Tid(1:k),Smooth(1:k));
    %title(['IIR Smooth with factor: ',num2str(alfa,4)])
    %xlabel('Tid [sek]')


    %subplot(2,2,4)
    %plot(Tid(1:k),PowerB(1:k));
    %title('Power B')
    %xlabel('Tid [sek]')

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
    %stop(motorA);
    %stop(motorB);
    %stop(motorC);
    %stop(motorD);

end


%------------------------------------------------------------------





