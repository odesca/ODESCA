function isValid = isValidSymbolic(obj, symbolicExpression)
% Checks if all symbolic variables of the argument are part of the object
%
% SYNTAX
%   isValid = obj.isValidSymbolic(symbolicExpression)
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
%   symbolicExpression: Symbolic expression to be checked
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%   isValid: boolean value, true if all symbolic variables of the
%            expression are either inputs, states or parameters of the
%            object, false otherwise
%
% DESCRIPTION
%   This method checks if all symbolic variables of the argument
%   'symbolicExpression' are either inputs, states or parameters of the
%   object. If this is the case the method returns true, otherwise it
%   returns false.
%
% NOTE
%
% SEE ALSO
%
% EXAMPLE
%   Pipe = OCLib_Pipe('MyPipe');
%   isValid_before = Pipe.isValidSymbolic(Pipe.f)
%   Pipe.setConstructionParam('Nodes',2);
%   isValid_after = Pipe.isValidSymbolic(Pipe.f)
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
isValid = false;
if( isa(symbolicExpression, 'sym') )
    symbolicInExpression = symvar(symbolicExpression);
    symbolicInObject = [obj.x; obj.u; obj.p];
    % If there is one or more symbolics which are not in the system the
    % variable isValid is set to false
    isValid = (sum( ~ismember(symbolicInExpression,symbolicInObject) ) == 0);
end

end