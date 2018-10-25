% Copyright 2017 Tim Grunert, Christian Schade, Lars Brandes, Sven Fielsch,
% Claudia Michalik, Matthias Stursberg
%
% This file is part of ODESCA.
% 
% ODESCA is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published 
% by the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% ODESCA is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Lesser General Public License for more details.
% 
% You should have received a copy of the GNU Lesser General Public License
% along with ODESCA.  If not, see <http://www.gnu.org/licenses/>.

function addODESCAPaths()
% Add the paths of the ODESCA-Tool to the Matlab directory
%
% SYNTAX
%       addODESCAPaths()
%
% INPUT ARGUMENTS
%
% OPTIONAL INPUT ARGUMENTS       
%
% OUTPUT ARGUMENTS       
%
% DESCRIPTION
%      Add the paths of the ODESCA-Tool to the Matlab directory.
%
% SEE ALSO
%       
% NODE
%       
% EXAMPLE

% Check if the toolboxes needed are available, otherwise throw a warning
try % Symbolic math toolbox
   var = sym('var');  %#ok<NASGU>
   disp('Symbolic math toolbox license has been checked out successfully.');
catch err
   warning('ODESCA:RequiredLicensesNotAvailable','The symbolic math toolbox license could not be checked out. It is required to work with ODESCA.\n\nLicense Error:\n##############################\n\n%s',err.message);
end
try % Control system toolbox
   var = ss();  %#ok<NASGU>
   disp('Control system toolbox license has been checked out successfully.');
catch err
   warning('ODESCA:RequiredLicensesNotAvailable','The control system toolbox license could not be checked out. It is required for the linear approximations in ODESCA.\n\nLicense Error:\n##############################\n\n%s',err.message);
end

% Get the base path of the ODESCA-Folder
basePath = strrep(mfilename('fullpath'),mfilename,'');

% Add required paths with all subfolders. The option '-end' leads to the
% pathes added at the end of the path list so that no matlab search path is
% overwritten.
addpath(genpath(fullfile([basePath,'/BaseClasses'])), '-end');
addpath(genpath(fullfile([basePath,'/Tool'])), '-end');
addpath(genpath(fullfile([basePath,'/Examples'])), '-end');

% Display a message that all pathes were added
disp('Pathes added.');
disp(['Version of ODESCA: ',ODESCA_BaseClass.classDefinitionVersion]);

end