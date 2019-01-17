function initializeODE(obj)
% Initializes all properties of the ODE to empty 
%
% SYNTAX
%   obj.initializeODE()
%
% INPUT ARGUMENTS
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   Initializes the properties of the ODE with empty arrays.
%
% NOTE
%   - This method is meant to be called in the constructor of an 
%     ODESCA_ODE.
%
% SEE ALSO
%
% EXAMPLE
%   --- inside the constructor of an ODESCA_ODE ---------
%   obj.initializeODE();
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
obj.f = [];
obj.g = [];

end