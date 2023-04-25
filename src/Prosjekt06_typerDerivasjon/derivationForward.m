function [derived] = derivationForward(inputFunction,step,timeStep)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
try
    derived = (inputFunction(step+1)-inputFunction(step))/timeStep;
catch
    derived = 0;
end
end