function createdSymbolics = addParameters(obj, parameterNames, parameterUnits)
% Adds parameters to the object
%
% SYNTAX
%   obj.addParameters(parameterNames, parameterUnits)
%   createdSymbolics = obj.addParameters(parameterNames, parameterUnits)
%
% INPUT ARGUMENTS
%   obj: Instance of the object where the method was called.
%        This parameter is given automatically.
%
%   parameterNames: Cell array with the names of the parameters as string.
%
%   parameterUnits: Cell array with the units of the parameters as string.
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%   createdSymbolics: Symbolic array with the symbolic
%                     parameters created in this method. This
%                     is necessary for the substitution of
%                     parameters where the names have changed (e.g.: on
%                     adding a component to a system)
%
% DESCRIPTION
%   This method adds the parameters given as strings in the cell array 
%   'parameterNames'. It will not add parameters already added to the 
%   object. The array 'createdSymbolics' contains the symbolic variables
%   for the parameters created in this method.
%
% NOTE
%   - Parameters which already exist will not be created again.
%
% SEE ALSO
%   obj.param
%   obj.p
%
% EXAMPLE
%   obj.addParameters({'length', 'radius', 'mass'},{'m','m','kg'});
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
% Check if the input arguments are cell arrays.
if( ~iscell(parameterNames) || ~iscell(parameterUnits) )
    error('ODESCA_Object:addParameters:inputNotACellArray','The input arguments have to be a cell arrays.');
end

% Get the parameter names and units in the right order
parameterNames = reshape(parameterNames,[numel(parameterNames),1]);
parameterUnits = reshape(parameterUnits,[numel(parameterUnits),1]);

% Check if the number of elements in the input argumets are equals
if( numel(parameterNames) ~= numel(parameterUnits) )
   error('ODESCA_Object:addParameters:inputArgumentsDifferentLength','The number of elemnets in the input arguments ''parameterNames'' and ''parameterUnits'' is not equal.'); 
end

% Check if all elements of 'parameterNames' are valid strings and the
% elements of 'parameterUnits' are strings
for num = 1:numel(parameterNames)
    paramName = parameterNames{num,1};
    if( ~isvarname(paramName) )
        error('ODESCA_Object:addParameters:parameterNameNotValid',['The names for the parameters has to match the naming conventions of MATLAB variables. The parameter name number ',num2str(num),' is invalid.']);
    end
    
    if( size(paramName,2) > 31 )
        error('ODESCA_Object:addParameters:parameterNameTooLong',['The parameter name number ',num2str(num),' exceeds the maximum length of 31 characters.']);
    end
    
    paramUnit = parameterUnits{num,1};
    if( ~ischar(paramUnit) || size(paramUnit,1) ~= 1)
       error('ODESCA_Object:addParameters:parameterUnitNotAString',['The paramter unit number ',num2str(num),' is not a string.']); 
    end
end

%% Evaluation of the task
% Array to store the created symbolic counterparts of the parameters
createdSymbolicsTemp = [];

% Cell array to store the units to add
newUnits = {};

% Add the parameters excapt those who already exists.
for num = 1:numel(parameterNames)
    toAdd = parameterNames{num,1};  % Current parameter name
    wasAdded = false;
    
    if( isempty(obj.param) )
        % Create the parameter structure if its empty
        obj.param = struct;
        obj.param.(toAdd) = [];
        wasAdded = true;
    else
        % Add the parameter if its not already added
        existingParam = fieldnames(obj.param);
        if( ~ismember(toAdd,existingParam) )
            obj.param.(toAdd) = [];
            wasAdded = true;
        end
    end
    
    % Create the symbolic counterpart for the parameter if it
    % was successfully added
    if( wasAdded )
        if( isempty(createdSymbolicsTemp) )
            createdSymbolicsTemp = sym(toAdd);
        else
            createdSymbolicsTemp = [createdSymbolicsTemp; sym(toAdd)];  %#ok<AGROW>
        end
        newUnits = [newUnits; parameterUnits{num}]; %#ok<AGROW>
    end
end

% If parameters were created ..
if( ~isempty(createdSymbolicsTemp) )
    % .. add the symbolic parameters to the p list
    obj.p = [obj.p; createdSymbolicsTemp];
    obj.paramUnits = [obj.paramUnits; newUnits];
end

% Only return the created symbolics when used
if(nargout > 0)
    createdSymbolics = createdSymbolicsTemp;
end

end