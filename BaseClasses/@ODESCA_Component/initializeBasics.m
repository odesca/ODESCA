function initializeBasics(obj, stateNames, inputNames, outputNames, paramNames, stateUnits, inputUnits, outputUnits, paramUnits)
% Creates the basic symbolic parts and sets the names and units
%
% SYNTAX
%   obj.initializeBasics(stateNames, inputNames, outputNames)
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
%   stateNames: Cell array with the names of the states as
%               string. The array must not have more than one
%               row. Leave the argument empty if no states should be added.
%
%   inputNames: Cell array with the names of the inputs as
%               string. The array must not have more than one
%               row. Leave the argument empty if no inputs should be added.
%
%   outputNames: Cell array with the names of the output as
%                string. The array must not have more than one
%                row. It is mandatory to have at least one output.
%
%   paramNames: Cell array with the names of the parameters as
%               string. The array must not have more than one
%               row. Leave the argument empty if no parameters should be 
%               added.
%
%   stateUnits: Cell array with the units of the states. It must have the
%               same number of elements as 'stateNames'.
%
%   inputUnits: Cell array with the units of the inputs. It must have the
%               same number of elements as 'inputNames'.
%
%   outputUnits: Cell array with the units of the outputs. It must have the
%               same number of elements as 'outputNames'.
%
%   paramUnits: Cell array with the units of the parameters. It must have
%               the same number of elements as 'paramNames'.
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   This method sets the names and units for the states, inputs, outputs
%   and parameters and creates the corresponding variables like the 
%   symbolicarray x = [x1, x2, ...] for the states.
%   An error will be thrown if there are name conflicts between the
%   state names, input names and parameter names
%
% NOTE
%   - The equations are set to an empty symbolic  n x 0 array. 
%   - This method is meant to be called in the function
%     calculateEquations() of a subclass of ODESCA_Component.
%
% SEE ALSO
%   ODESCA_Component.calculateEquations()
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
%---------- Check the stateNames ------------------------------
if( ~isempty(stateNames) )
    % Check if stateNames is a cell array
    if( ~iscell(stateNames) )
        error('ODESCA_Component:initializeBasics:stateNamesNotACellArray','The input argument ''stateNames'' has to be a cell array.');
    end
    
    % Get the state names and units in the right order
    stateNames = reshape(stateNames,[numel(stateNames),1]);
    stateUnits = reshape(stateUnits,[numel(stateUnits),1]);
    
    % Check if the number of stateNames and stateUnits is equal
    if( numel(stateNames) ~= numel(stateUnits) )
        error('ODESCA_Component:initializeBasics:numberStateNamesUnitsDifferent','The number of state names is different to the number of state units.');
    end
    
    % Check if all elements of 'stateNames' are valid strings and if all
    % units are strings
    for num = 1:numel(stateNames)
        name = stateNames{num,1};
        if( ~isvarname(name) )
            error('ODESCA_Component:initializeBasics:stateNameInvaldi',['The names for the states have to match the naming conventions of MATLAB variables. The state name number ',num2str(num),' is invalid.']);
        end
        
        if( size(name,2) > 31 )
            error('ODESCA_Component:initializeBasics:stateNameTooLong',['The state name number ',num2str(num),' exceeds the maximum length of 31 characters.']);
        end
        
        unit = stateUnits{num};
        if( ~ischar(unit) || size(unit,1) ~= 1 )
            error('ODESCA_Component:initializeBasics:stateUnitNotAString', ['The state unit number ',num2str(num),' is not a string.']);
        end
    end
end

%---------- Check the inputNames ------------------------------
if( ~isempty(inputNames) )
    % Check if inputNames is a cell array
    if( ~iscell(inputNames) )
        error('ODESCA_Component:initializeBasics:inputNamesNotACellArray','The input argument ''inputNames'' has to be a cell array.');
    end
    
    % Get the input names and units in the right order
    inputNames = reshape(inputNames,[numel(inputNames),1]);
    inputUnits = reshape(inputUnits,[numel(inputUnits),1]);
    
    % Check if the number of inputNames and inputUnits is equal
    if( numel(inputNames) ~= numel(inputUnits) )
        error('ODESCA_Component:initializeBasics:numberStateNamesUnitsDifferent','The number of input names is different to the number of input units.');
    end
    
    % Check if all elements of 'inputNames' are valid strings and if all
    % units are strings
    for num = 1:numel(inputNames)
        name = inputNames{num,1};
        if( ~isvarname(name) )
            error('ODESCA_Component:initializeBasics:inputNameInvalid',['The names for the inputs have to match the naming conventions of MATLAB variables. The input name number ',num2str(num),' is invalid.']);
        end
        
        if( size(name,2) > 31 )
            error('ODESCA_Component:initializeBasics:inputNameTooLong',['The input name number ',num2str(num),' exceeds the maximum length of 31 characters.']);
        end
        
        unit = inputUnits{num};
        if( ~ischar(unit) || size(unit,1) ~= 1 )
            error('ODESCA_Component:initializeBasics:inputUnitNotAString', ['The input unit number ',num2str(num),' is not a string.']);
        end
    end
end

%---------- Check the outputNames -----------------------------

% Check if outputNames is filled
if( isempty(outputNames) )
    error('ODESCA_Component:initializeBasics:outputNamesEmpty','The argument ''outputNames'' is not allowed to be empty.');
end

% Check if outputNames is a cell array
if( ~iscell(outputNames) )
    error('ODESCA_Component:initializeBasics:outputNamesNotACellArray','The input argument ''outputNames'' has to be a cell array.');
end

% Get the output names and units in the right order
outputNames = reshape(outputNames,[numel(outputNames),1]);
outputUnits = reshape(outputUnits,[numel(outputUnits),1]);

% Check if the number of outputNames and outputUnits is equal
if( numel(outputNames) ~= numel(outputUnits) )
    error('ODESCA_Component:initializeBasics:numberStateNamesUnitsDifferent','The number of output names is different to the number of output units.');
end

% Check if all elements of 'outputNames' valid are strings and if all
% units are strings
for num = 1:numel(outputNames)
    name = outputNames{num,1};
    if( ~isvarname(name) )
        error('ODESCA_Component:initializeBasics:outputNameInvalid',['The names for the outputs have to match the naming conventions of MATLAB variables. The ouput name number ',num2str(num),' is invalid.']);
    end
    
    if( size(name,2) > 31 )
        error('ODESCA_Component:initializeBasics:outputNameTooLong',['The output name number ',num2str(num),' exceeds the maximum length of 31 characters.']);
    end
    
    unit = outputUnits{num};
    if( ~ischar(unit) || size(unit,1) ~= 1 )
        error('ODESCA_Component:initializeBasics:outputUnitNotAString', ['The output unit number ',num2str(num),' is not a string.']);
    end
end


%---------- Check the parameter names -------------------------
if( ~isempty(paramNames) )
    % Check if the input argument 'paramNames' is a cell array.
    if( ~iscell(paramNames) )
        error('ODESCA_Component:initializeBasics:paramNamesNotACellArray','The input argument ''paramNames'' has to be a cell array.');
    end
    
    % Get the param names and units in the right order
    paramNames = reshape(paramNames,[numel(paramNames),1]);
    paramUnits = reshape(paramUnits,[numel(paramUnits),1]);
    
    % Check if the number of paramNames and paramUnits is equal
    if( numel(paramNames) ~= numel(paramUnits) )
        error('ODESCA_Component:initializeBasics:numberStateNamesUnitsDifferent','The number of parameter names is different to the number of parameter units.');
    end
    
    % Check if all elements of 'paramNames' are valid strings
    for num = 1:numel(paramNames)
        paramName = paramNames{num,1};
        if( ~isvarname(paramName) )
            error('ODESCA_Component:initializeBasics:parameterNameNotValid',['The names for the parameters has to match the naming conventions of MATLAB variables. The parameter name number ',num2str(num),' is invalid.']);
        end
        
        if( size(paramName,2) > 31 )
            error('ODESCA_Component:initializeBasics:parameterNameTooLong',['The parameter name number ',num2str(num),' exceeds the maximum length of 31 characters.']);
        end
        
        unit = paramUnits{num};
        if( ~ischar(unit) || size(unit,1) ~= 1 )
            error('ODESCA_Component:initializeBasics:paramUnitNotAString', ['The parameter unit number ',num2str(num),' is not a string.']);
        end
    end
end

%---------- Ckeck if names are unique -------------------------
% Find the states, inputs and parameters which are double
nameList = [stateNames; inputNames; paramNames];
conflicts = {};
% Create a list of all names which are double in the list
for num = 1:numel(nameList)
    if( sum(ismember(nameList,nameList{num})) > 1 )
        conflicts = [conflicts; nameList{num}]; %#ok<AGROW>
    end
end
conflicts = unique(conflicts);
% Throw an error if there are name conflicts
if( ~isempty(conflicts) )
    %Create a String with the names of all the name conflicts
    conflictNames = '';
    for num = 1:numel(conflicts)
        conflictNames = [conflictNames,' ',conflicts{num}];  %#ok<AGROW>
    end
    error('ODESCA_Component:initializeBasics:NameConflicts',['The states,inputs and parameters must have different names. The following names are used multiple times: ',conflictNames]);
end

%% Evaluation of the task
%---------- Set the names after all checks are passed ---------
% Set states if the 'stateNames' propertie is not empty
if( ~isempty(stateNames) )
    % Set the state names of the object and create the symbolics
    obj.stateNames = stateNames;
    obj.stateUnits = stateUnits;
    obj.x = sym('x',[numel(stateNames), 1]);
    obj.f = sym('f',[numel(stateNames), 1]);
end

% Set inputs if the 'inputNames' propertie is not empty
if( ~isempty(inputNames) )
    % Set the input names of the object and create the symbolics
    obj.inputNames = inputNames;
    obj.inputUnits = inputUnits;
    obj.u = sym('u',[numel(inputNames), 1]);
end

% Set the output names of the object and create the symbolics
obj.outputNames = outputNames;
obj.outputUnits = outputUnits;
obj.g = sym('g',[numel(outputNames),1]);

% Create the parameters
if( ~isempty(paramNames) )
    obj.addParameters(paramNames, paramUnits);
end

end