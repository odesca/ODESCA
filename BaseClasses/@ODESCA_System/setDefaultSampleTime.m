function setDefaultSampleTime(sys, time)
% Sets the default sample time of the system
%
% SYNTAX
%   sys.setDefaultSampleTime(time)
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
%   time: sample time 
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   This method sets the default sample time. The value has to be greater 
%   than zero.
%
% NOTE
%
% SEE ALSO
%
% EXAMPLE
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

%% Check of the conditions
% Check if the sample time is a scalar numeric value greater than zero
if( ~isnumeric(time) || numel(time) ~= 1 || time <= 0)
   error('ODESCA_System:setDefaultSampleTime:invalidSampleTime','The sample time has to be a scalar numeric value greater than zero.'); 
end

%% Evaluation of the task
% Set the sample time
sys.defaultSampleTime = time;

end