%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% ProsjektKreativt_AutomatiskKjoring
%--------------------------------------------------------------------------


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                EXPERIMENT SETUP AND DATA FILENAME

clear; close all

online = true;

filename = 'P0X_MeasBeskrivendeTekst_Y.mat';

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

    % motorer
    motorA = motor(mylego,'A');
    motorA.resetRotation;
    motorB = motor(mylego,'B');
    motorB.resetRotation;

else
    % Dersom online=false lastes datafil.
    load(filename)
end

disp('Equipment initialized.')
%--------------------------------------------------------------------------


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                       SPECIFY FIGURE SIZE
fig1=figure;
screen = get(0,'Screensize');
set(fig1,'Position',[1,1,0.5*screen(3), 0.5*screen(4)])
set(0,'defaultTextInterpreter','latex');
set(0,'defaultAxesFontSize',14)
set(0,'defaultTextFontSize',16)
%--------------------------------------------------------------------------


% setter skyteknapp til 0, og tellevariabel k=1
JoyMainSwitch=0;
k=1;

while ~JoyMainSwitch
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                       GET TIME AND MEASUREMENT

    if online
        if k==1
            tic
            Tid(1) = 0
        else
            Tid(k) = toc;
        end



        % sensorer (bruk ikke Lys(k) og LysDirekte(k) samtidig)
        Lys(k) = double(readLightIntensity(myColorSensor,'reflected'));

        %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        %                   Referance & Error
        Refrence(k) = Lys(1);

        Avvik(k) = Lys(1) - Lys(k);
        %------------------------------------------------------------------
        
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

        % motorer
        VinkelPosMotorA(k) = double(motorA.readRotation);
        VinkelPosMotorB(k) = double(motorB.readRotation);
        
        [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
        JoyForover(k) = JoyAxes(2);
        JoySide(k) = JoyAxes(3);


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

    % Spesifisering av initialverdier og beregninger
    if k==1
        % Initialverdier
        Ts(1) = 0.01;  % nominell verdi
    else
        % Beregninger av Ts og variable som avhenger av initialverdi
    end

  
    if online

    %----------------------------------------------------------------------

    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                          Automatic driving

    Kp = 2;
    Ki = 1;
    Kd = 1;
    u_0 = 25;
    alfa = 0.2;

    P(k) = Kp * Avvik(k);

    if k == 1
        I(1) = 0;
        D(1) = 0;
        Avvik_IIR(1) = 0;
    else
        I(k) = (I(k-1) + (Ts(k)*Avvik(k-1))) * Ki;
        Avvik_IIR(k)= alfa*Avvik(k)+(1-alfa)*(Avvik_IIR(k-1));
        D(k) = ((Avvik_IIR(k) - Avvik_IIR(k-1)) / Ts(k)) * Kd;
    end

    if I(k) < -8
        I(k) = -8;
    elseif I(k) > 3
        I(k) = 3;
    end
       
    
    PowerA(k) = u_0 - P(k) - I(k) - D(k);
    PowerB(k) = u_0 + P(k) + I(k) + D(k);

    %----------------------------------------------------------------------

        motorA.Speed = PowerA(k);
        motorB.Speed = PowerB(k);

        start(motorA)
        start(motorB)

    end
    %----------------------------------------------------------------------

    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT DATA

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
     plot(Tid(1:k), I(1:k))
     hold on
     plot(Tid(1:k), D(1:k))
     title('I og D')
     xlabel('Tid [sek]')
 
     subplot(3,2,6)
     plot(Tid(1:k), P(1:k));
     title('P')
     xlabel('Tid [sek]')

    drawnow
    %----------------------------------------------------------------------

    % oppdatere tellevariabel
    k=k+1;

end

% figure;
% histogram(Lys);

% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%               STOP MOTORS

if online

    stop(motorA);
    stop(motorB);

end
%--------------------------------------------------------------------------