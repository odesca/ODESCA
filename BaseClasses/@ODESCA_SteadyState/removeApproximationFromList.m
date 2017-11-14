function removeApproximationFromList(obj, pos)
% Removes the approximation at the given position of the list
%
% SYNTAX
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the methode was
%           called. This parameter is given automatically.
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   This method removes the approximation at a given position of the list
%   of approximations.
%
% NOTE
%   - This method is not relevant for a user.
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

%% Evaluation of the task

% Remove the steady state from the system
if( numel(obj.approximations) == 1)
    obj.approximations = [];
else
    obj.approximations = [obj.approximations(1:(pos-1));obj.approximations((pos+1):end)];
end

end