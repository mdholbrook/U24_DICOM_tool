%% Update paths
% Add JSON and NifTi tools to path

%% Set up function paths

[mpath, ~] = fileparts(mfilename('fullpath'));
addpath(fullfile(mpath, 'jsonlab-1.5'));
addpath(fullfile(mpath, 'NIfTI_Tools'));