function g = loadGEBCO14(filename)
%loadGEBCO Loads GEBCO 2014 data into a structure for MATLAB processing.
% Raw .nc data files are available online from:
%   https://www.bodc.ac.uk/data/online_delivery/gebco/
% Written by Matthew P. Humphreys. Last updated on 2017-04-03

%% Initial data extraction
fileinfo = ncinfo(filename);
vars = cell(size(fileinfo.Variables));
for V = 1:length(vars)
    vars{V} = fileinfo.Variables(V).Name;
    g.(vars{V}) = ncread(filename,vars{V});
end %for V

%% Meshgrid for output
[g.lat,g.lon] = meshgrid(g.lat,g.lon);

%% elevation => z
g.z = -g.elevation;
g = rmfield(g,'elevation');

end %function loadGEBCO14