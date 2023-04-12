function [FilteredValue] = FIR_filter(Measurements, M)
FilteredValue = 1 / M * (sum(Measurements(1:M)));
end