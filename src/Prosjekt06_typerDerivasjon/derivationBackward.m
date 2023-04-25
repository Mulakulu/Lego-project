function [derived] = derivationBackward(inputFunction,step,timeStep)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
try
    derived = (inputFunction(step)-inputFunction(step-1))/timeStep;
catch
    derived = 0;
end
end