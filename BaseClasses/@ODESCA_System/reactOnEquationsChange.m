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

function reactOnEquationsChange(sys)
% Sets all steady states to invalid on a change in the equations
%
% SYNTAX
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   This method sets all the steady states of the system to a invalid state
%   if the equations of the systems where changed.
%
% NOTE
%   - This method is a implementation of the same named abstract method of
%     the ODESCA_Object
%
% SEE ALSO
%
% EXAMPLE
%

%% Evaluation of the task#
% Set all steady states to invalid
if( ~isempty(sys.steadyStates) )
   for num = 1:numel(sys.steadyStates);
       ss = sys.steadyStates(num);
       ss.structuralValid = false;
       ss.numericValid = false;
   end
end

end