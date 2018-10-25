function removeSymbolicInput(obj, position)
% Removes the symbolic input from the object
%
% SYNTAX
%   obj.removeSymbolicInput(position)
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
%   position: Position of the input to be removed
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   This method removes the input with the number 'position' and 
%   renumerates the remaining symbolic inputs. 
%   E.g.: if there are four inputs 'u1','u2','u3','u4' and the second one
%   should be removed the symbolic inputs should be 'u1','u2','u3' where u3
%   is replaced by u2 and u4 is replaced by u3.
%
% NOTE
%   - This method is used by the tool and must not be used by a user
%     because it renders the system inoperable.
%
% SEE ALSO
%
% EXAMPLE
%   There is no example provided because this method must not be used by a
%   user.
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
% Renumerate the inputs with a heigher number than the removed  and replace
% them in the equations

% Get the inputs to replace
uOld = obj.u(position+1:numel(obj.u));
uNew = obj.u(position:numel(obj.u)-1);

% Replace them
if( ~isempty(obj.f) )
    obj.f = subs(obj.f,uOld,uNew);
end
if( ~isempty(obj.g) )
    obj.g = subs(obj.g,uOld,uNew);
end

% Remove the input from the system
if(numel(obj.u) == 1)
    obj.u = [];
    obj.inputNames = {};
    obj.inputUnits = {};
else
    obj.u = obj.u(1:(end-1));
    obj.inputNames = [ obj.inputNames(1:position-1); obj.inputNames(position+1:end) ];
    obj.inputUnits = [ obj.inputUnits(1:position-1); obj.inputUnits(position+1:end) ];
end

end