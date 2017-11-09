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

function setName(obj, name)
% Sets the name of the instance.
%
% SYNTAX
%   obj.setName(name)
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
%   name:   name for the instance of the class as string
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   Sets the name of the calling object instance and check
%   if the argument 'name' has the correct type.
%
% NOTE
%   - The name has to be a valid MATLAB variable name with a maximal length
%     of 31 characters and is not allowed to contain any underscores.
%
% SEE ALSO
%   name
%
% EXAMPLE
%

%% Check of the conditions
% check if the agrument is valid
if( ~isvarname(name))
    error('ODESCA_Object:setName:InvalidName','The Argument ''name'' has to match the naming conventions of MATLAB variables. Name was not set.');
end

% check if there are no underscores in the argument
if( contains(name,'_'))
    error('ODESCA_Object:setName:UnderscoreInName','The Argument ''name'' MUST NOT contain an underscore.');
end

% check if the size of the name has maximum 31 characters
if( size(name,2) > 31 )
    error('ODESCA_Object:setName:InvalidNameLength','The argument ''name'' exceeds the maximal length of 31 characters.');
end

%% Evaluation of the task
% Set the name of the component instance
obj.name = name;

end