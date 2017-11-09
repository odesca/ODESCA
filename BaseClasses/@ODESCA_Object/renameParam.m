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

function renameParam(obj, oldName, newName)
% Renames a parameter
%
% SYNTAX
%   obj.renameParam(oldName, newName)
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%   oldName:    Name of the parameter to be renamed
%
%   newName:    Name the parameter should be set to
%
% DESCRIPTION
%   This method renames a parameter.
%
% NOTE
%   - This method MUST NOT be used outside the method renameComponent() of
%     the ODESCA_System because it is likely to render the system
%     inoperable.
%
% SEE ALSO
%   ODESCA_System.renameComponent(oldName, newName)
%   param
%   p
%
% EXAMPLE
%

%% Check of the conditions
% Check if the object has parameters
if( isempty(obj.param) )
    error('ODESCA_Object:renameParam:noParametersInObject','The object has no parameters.');
end

% Check if oldName is a string
if( ~ischar(oldName) || size(oldName,1) ~= 1)
    error('ODESCA_Object:renameParam:oldNameNotAString','The old name has to be a string.');
end

% Get the names of the parameters
paramNames = fieldnames(obj.param);

% Check if a parameter with the old name exists
if( ~ismember(oldName ,paramNames) )
    error('ODESCA_Object:renameParam:oldNameNotInObject',['The object has no parameter with the name ''',oldName,'''.']);
end

% Check if the new name is valid
if( ~isvarname(newName))
    error('ODESCA_Object:renameParam:newNameNotValid','The Argument ''newName'' has to match the naming conventions of MATLAB variables.');
end

% Check if the new name is free
if( ismember(newName ,paramNames) || ismember(newName ,obj.inputNames) || ismember(newName ,obj.stateNames) )
    error('ODESCA_System:renameParam:newNameAlreadyInObject',['The object already has a parameter, state or input with the name ''',newName,'''.']);
end


%% Evaluation of the task
% Replace the symbolic parameter
oldSym = sym(oldName);
newSym = sym(newName);

obj.p = subs(obj.p,oldSym,newSym);
if( ~isempty(obj.f) )
    obj.f = subs(obj.f,oldSym,newSym);
end
if( ~isempty(obj.g) )
    obj.g = subs(obj.g,oldSym,newSym);
end

% Create new parameter structure with the name changed
newParam = struct;
for numParam = 1:numel(paramNames)
    name = paramNames{numParam};
    value = obj.param.(name);
    
    % Add the fields to the new structure
    if( strcmp(oldName, name) )
        newParam.(newName) = value;
    else
        newParam.(name) = value;
    end
end
% Replace the old parameter structure with the new structure
obj.param = newParam;

end