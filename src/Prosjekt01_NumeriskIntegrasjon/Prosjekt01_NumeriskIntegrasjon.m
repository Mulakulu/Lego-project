%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt0X_.....
%
% Hensikten med programmet er å test numerisk integrasjon med variabelt tidsskritt
% Følgende sensorer brukes:
% - Lyssensor
%
%--------------------------------------------------------------------------


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                EXPERIMENT SETUP AND DATA FILENAME
%
% Alltid lurt å rydde workspace opp først
clear;
close all;
% Skal prosjektet gjennomføres online mot EV3 eller mot lagrede data?
online = true;
% Skal prosjektet lagre data etter en sesjon?
save_files = false;
% Spesifiser et beskrivende filnavn for lagring av måledata
filename_mat = 'data/Prosjekt01_NumeriskIntegrasjon_Test.mat';
filename_csv = 'data/Prosjekt01_NumeriskIntegrasjon_Test.csv';
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

    % sensorer
    myColorSensor = colorSensor(mylego);

else
    % Dersom online=false lastes datafil.
    load(filename_mat)
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

        % Data fra styrestikke. Utvid selv med andre knapper og akser.
        % Bruk filen joytest.m til å finne koden for de andre
        % knappene og aksene.
        [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);

    else
        % online=false
        % Når k er like stor som antall elementer i datavektoren Tid,
        % simuleres det at bryter på styrestikke trykkes inn.
        if k==numel(Tid)
            JoyMainSwitch=1;
        end

        % simulerer EV3-Matlab kommunikasjon i online=false
        %pause(0.01)

    end
    %--------------------------------------------------------------


    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %             CONDITIONS, CALCULATIONS AND SET MOTOR POWER
    % Gjør matematiske beregninger og motorkraftberegninger
    % hvis motor er tilkoplet.
    % Kaller IKKE på en funksjon slik som i Python.

    % Tilordne målinger til variabler
    ZeroFlow = Lys(1);

    % Spesifisering av initialverdier og beregninger
    if k == 1
        % Initialverdier
        Ts(k) = 0.01;  % nominell verdi
        Volum(k) = 0; % initialverdi volum [cl]
        Flow(k) = 0; % initialverdi flow [cl/s]
    else
        Ts(k) = Tid(k) - Tid(k-1); % beregne tidsskritt
        Flow(k) = Lys(k) - ZeroFlow; % beregne flow [cl/s]
        Volum(k) = Volum(k-1) + Ts(k) * Flow(k); % beregne volum [cl]
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

    subplot(2,1,1)
    plot(Tid(1:k),Flow(1:k));
    xlabel('Time [s]')
    ylabel(' Flow [cl/s]')


    subplot(2,1,2)
    plot(Tid(1:k),Volum(1:k));
    xlabel('Time [s]')
    ylabel(' Volume [cl]')

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


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                  SAVE DATA
% Denne seksjonen lagrer dataene etter en sesjon.
% Dataene blir lagret i samme mappe som kildefilen.

if save_files == true
    % Lagre .mat-fil
    save(filename_mat, 'Tid', 'Lys', 'Flow', 'Volum');
    % Lagre .csv-fil
    csv_data = [Tid', Flow', Volum']; % Transpose
    table = array2table(csv_data, "VariableNames",{'t', 'f', 'v'}); % Converter til tabell med overskrifter
    writetable(table, filename_csv); % Skriv ut fil
end
