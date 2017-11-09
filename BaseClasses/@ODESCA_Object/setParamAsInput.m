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

function setParamAsInput(obj, paramName)
% Sets the specified parameter as an input of the object.
%
% SYNTAX
%   obj.setParamAsInput(paramName)
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
%   paramName: Name of the parameter which should be set as
%              input as string.
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   This function sets a parameter as input of the object. To unset a
%   parameter as input simply set the parameter with the method setParam()
%
% NOTE
%   - If the parameter is already added as input nothing will happen.
%   - To unset a parameter as input use the method
%     setParam(paramName,value). The input is than removed automatically.
%
% SEE ALSO
%   paramAsInputs
%   setParam(paramName,value)
%
% EXAMPLE
%

%% Check of the conditions
% Check if the input argument is a string
if( ~isa(paramName,'char') || size(paramName,1) ~= 1 )
    error('ODESCA_Object:setParamAsInput:ParameterNameMustBeString','Argument ''paramName'' must be of type string.');
end

% Check if the object has parameters
if( isempty(obj.param) )
    error('ODESCA_Object:setParamAsInput:NoParametersExist','The object has no parameters which could be set as input.');
end

existingParam = fieldnames(obj.param);

% Check if the parameter exists
if( ~ismember(paramName, existingParam) )
    error('ODESCA_Object:setParamAsInput:NotAParameter',['The parameter ''',paramName,''' dose not exist.']);
end

% Check if an input with the same name already exists
if( ismember(paramName, obj.inputNames))
    error('ODESCA_Object:setParamAsInput:isAlreadyInput','An input with the same name as the parameter already exists.');
end

%% Evaluation of the task
% Create the symbolic variable for the new input
numIn = numel(obj.u);
newU = sym(['u',num2str(numIn + 1)]);

% Add the new input to the symbolic inputs and input names
obj.u = [obj.u; newU];
obj.inputNames = [obj.inputNames; paramName];

% Add the parameter unit to the list of input units
pos = -1;
paramNames = fieldnames(obj.param);
for num = 1:numel(paramNames)
    if(strcmp(paramNames{num},paramName))
        pos = num;
    end
end
obj.inputUnits = [obj.inputUnits; obj.paramUnits(pos)];

% Remove the parameter from the parameter structure and paramUnits array
if(numel(paramNames) == 1 )
    % Set the param-structure, paramUnits and p array empty if no 
    % parameter is left
    obj.param = [];
    obj.paramUnits = [];
    obj.p = [];
else
    newParam = struct;
    for num = 1:numel(paramNames)
        currentName = paramNames{num};
        % Add the parameters which are not added as inputs
        if(~strcmp(currentName,paramName))
            newParam.(currentName) = obj.param.(currentName);
        else
            % Remove the parameter unit of the parameter set as input
            obj.paramUnits = [obj.paramUnits(1:num-1);obj.paramUnits(num+1:end)];
            % Remove the symbolic parameter of the parameter set as input
            obj.p = [obj.p(1:num-1); obj.p(num+1:end)];
        end
    end
    obj.param = newParam;
end


% Replace the parameter in the equations with the new input
oldParam = sym(paramName);
if( ~isempty(obj.f) )
    obj.f = subs(obj.f,oldParam,newU);
end
if( ~isempty(obj.g) )
    obj.g = subs(obj.g,oldParam,newU);
end

% Call the method to signal that the parts of the equations were changed
obj.reactOnEquationsChange();

end