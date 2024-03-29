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
filename = 'treg_sin.mat';
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


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                DEFINE THE ALFAS OF THE FIR INPUTS
%   1 = moving average  (1*(k-2)+1*(k-1)+1*(k))/3  <-sum of alphas
%   2 = liear           (1*(k-2)+2*(k-1)+3*(k))/6  <-sum of alphas
%   3 = exponent        (1*(k-2)+4*(k-1)+9*(k))/14 <-sum of alphas
lookback = 10; %Definerer hvor mye FIR filtered ser tilbake
spreadtype = 4;
switch spreadtype
    case 1
        alfas(1:lookback) = 1
        alfaspread = "moving average";
    case 2
        alfas(1:lookback) = 1:lookback
        alfaspread = "lineær";
    case 3
        alfas(1:lookback) = power(1:lookback,2)
        alfaspread = "kvadratisk";
    case 4
        alfas(1:lookback) = power(1:lookback,3)
        alfaspread = "kubisk";
    otherwise
end
alfas(1:lookback) = alfas(1:lookback)/sum(alfas)
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


% setter skyteknapp til 0, og tellevariabel k=1
JoyMainSwitch=0;
k=1;

while ~JoyMainSwitch
    %pause(0.5)
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
        Flow(k) = Lys(k) - Nullflow;
        %Flow(k) = Lys(k)- Nullflow - meanFlow; %Del 2
        %beregn Flow(k) som "Lys(k)-nullflow"
        Ts(k) = Tid(k) - Tid(k-1);
        %beregn tidsskrittet Ts(k)
        V(k)= V(k-1)+Ts(k)*(Flow(k-1));
        %V(k)=a2*Tid(k);
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

    %subplot(2,2,1)
    %plot(Tid(1:k),Lys(1:k));
    %title('Lys reflektert')
    %xlabel('Tid [sek]')

    subplot(2,2,2)
    plot(Tid(1:k),Flow(1:k));
    title('Flow')
    xlabel('Tid [sek]')

    %subplot(2,2,3)
    %plot(Tid(1:k),V(1:k));
    %title('Volum')
    %xlabel('Tid [sek]')
    %--------------------------------------------------------------
    
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                   IIR-filter
    alfa = 0.6;
    if k ~= 1
        Temp_IIR(k) = (1-alfa) * Temp_IIR(k-1) + alfa * Flow(k);
    else
        Temp_IIR(1) = Flow(1);
    end
    %--------------------------------------------------------------
    
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                   FIR-filter
    M=lookback; %Antall målinger
    %Temp_FIR(k) = Lys(k);

    Temp_FIR(k) = 0;
    if k < M
        M=k;
        for n = 0:1:M-1
            Temp_FIR(k) = Temp_FIR(k)+1/M*Lys(k-n);
        end
    else
        for n = 0:1:M-1
            Temp_FIR(k) = Temp_FIR(k)+alfas(lookback-n)*Lys(k-n);
        end
    end
    %Temp_FIR(k) = 1/M*sum(Lys(k-M+1:k));

    if k == 1
        Temp_FIR(k) = Lys(k);
    end
    Temp_FIR(k) = Temp_FIR(k) - Nullflow;
    %--------------------------------------------------------------
 
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    subplot(2,2,4)
    plot(Tid(1:k),Temp_IIR(1:k));
    title(strjoin(["(IIR)Flow filtrert med faktor " alfa]))
    xlabel('Tid [sek]')

    subplot(2,2,1)
    plot(Tid(1:k),Temp_FIR(1:k));
    title(strjoin(["(FIR)Flow filtrert med faktor " lookback newline " og " alfaspread " alfaspredning"]))
    xlabel('Tid [sek]')

    %subplot(2,2,5)
    %plot(Tid(1:k),Temp_FIR(1:k));
    %title('Power B')
    %xlabel('Tid [sek]')

    %subplot(2,2,6)
    %plot(Tid(1:k),Temp_IIR(1:k));
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
    stop(motorA);
    stop(motorB);
    stop(motorC);
    stop(motorD);

end
%------------------------------------------------------------------
while ~skyteknapp
% GET TIME AND MEASUREMENT

% CONDITIONS, CALCULATIONS AND SET MOTOR POWER



% PLOT DATA
plot Flow i øverste subplot
plot Volum i nederste subplot
end



