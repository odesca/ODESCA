function initializeObject(obj)
% Initializes all properties of the object (except the name) to empty 
%
% SYNTAX
%   obj.initializeObject()
%
% INPUT ARGUMENTS
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   Initializes the properties of the object with empty arrays.
%
% NOTE
%   - This method is meant to be called in the constructor of an 
%     ODESCA_Object.
%
% SEE ALSO
%
% EXAMPLE
%   --- inside the constructor of an ODESCA_Object ------
%   obj.initializeObject();
%   -----------------------------------------------------
%

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

%% Evaluation of the task
% Initialization of the protected parameters
obj.x = [];
obj.u = [];
obj.stateNames    = {};
obj.inputNames    = {};
obj.outputNames   = {};
obj.stateUnits    = {};
obj.inputUnits    = {};
obj.outputUnits   = {};

% Initialization of the private properties
obj.param       = [];
obj.p    = [];
obj.paramUnits  = {};

end