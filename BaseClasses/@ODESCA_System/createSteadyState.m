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

function [newSteadyState, valid] = createSteadyState(sys, x0, u0, name)
% Creates a new ODESCA_SteadyState and links it to the system
%
% SYNTAX
%   sys.createSteadyState(x0, u0, name)
%
% INPUT ARGUMENTS
%   sys:    Instance of the object where the method was
%           called. This parameter is given automatically.
%   x0: Values of the states in the steady state
%   u0: Values of the inputs in the steady state 
%
% OPTIONAL INPUT ARGUMENTS
%   name: Name of the steady state operation point
%
% OUTPUT ARGUMENTS
%   newSteadyState: ODESCA_SteadyState instance which was created in this
%                   method
%   valid: boolean to indicate, if the steady state is valid
%
% DESCRIPTION
%
% NOTE
%   - If no name is given the steady state gets the name 'Default'
%
% SEE ALSO
%   steadyStates
%
% EXAMPLE
%

%% Check of the conditions
if(nargin == 3)
    % If no name is given select a default name
    if( ~isempty(sys.steadyStates) )
        % Get list of the existing names
        nameList = {};
        for num = 1:numel(sys.steadyStates)
            ssop = sys.steadyStates(num);
            nameList = [nameList; ssop.name]; %#ok<AGROW>
        end
        
        % Find a default name which is not taken
        num = 1;
        newName = 'SteadyState';
        while( ismember(newName,nameList) )
            newName = ['SteadyState',num2str(num)];
            num = num + 1;
        end
       name = newName; 
    else
       name = 'SteadyState'; 
    end
    
elseif(nargin == 4)
    % If a name is given ...
    % Check if the name is a string
    if( ~ischar(name) || size(name,1) ~= 1)
        error('ODESCA_System:addSteadyState:nameNotAString','The argument ''name'' has to be a string.');
    end
    
    % Check if a steady state with the name already exists
    if( ~isempty(sys.steadyStates) )
        nameList = {};
        for num = 1:numel(sys.steadyStates)
            ssop = sys.steadyStates(num);
            nameList = [nameList; ssop.name]; %#ok<AGROW>
        end
        if( ismember(name,nameList) )
            error('ODESCA_System:addSteadyState:nameAlreadyExist','A steady state with the same name already exists.');
        end
    end
else
    error('ODESCA_System:addSteadyState:wrongNumerOfInputArguments', 'The method requires 2 or 3 arguments and no other number.');
end

% Check if x0, u0 and y0 are numeric
if( ~isnumeric(x0) || ~isnumeric(u0))
   error('ODESCA_System:addSteadyState:steadyStateValueNotNumeric','The arguments x0 and u0 have to be numeric.');
end

% Get number of states, inputs and outputs of the system to check if x0, u0
% and y0 have the right dimension.
numX = numel(sys.stateNames);
numU = numel(sys.inputNames);

% Check if the number of states is correct
if( numel(x0) ~= numX)
   error('ODESCA_System:addSteadyState:wrongNumberOfStates',['The number of states in ''x0'' [',numel(x0),'] does not match the number of states in the system [',numX,'].']);
end

% Check if the number of inputs is correct
if( numel(u0) ~= numU)
   error('ODESCA_System:addSteadyState:wrongNumberOfInputs',['The number of inputs in ''u0'' [',numel(u0),'] does not match the number of inputs in the system [',numU,'].']);
end

% Check if all parameters are set
if( ~sys.checkParam() )
    error('ODESCA_System:createSteadyState:notAllParametersSet', 'A steady state can not be created if there are unset parameters at the system.');
end

%% Evaluation of the task

if(~isempty(x0))
    x0 = reshape(x0',numel(x0),1);
end
if(~isempty(u0))
    u0 = reshape(u0',numel(u0),1);
end

% Create the new steady state 
sso = ODESCA_SteadyState(sys, x0, u0, name);

% Set the structural valid flag to true
sso.structuralValid = true;

% Set the parameter set and the default sample time
sso.param = sys.param;

% Get the values of the parameter 
temp = sys.getParam();
paramVal = sym('p',size(temp));
for num = 1:numel(temp)
   paramVal(num) = temp{num}; 
end

% Set the y0 value 
sso.y0 = double(subs(sys.g,[sys.x;sys.u;sys.p],[sso.x0;sso.u0;paramVal]));

% Add the steady state to the system
if( isempty(sys.steadyStates) )
    sys.steadyStates = sso;
else
    sys.steadyStates = [sys.steadyStates; sso];
end

% Add the system to the steady state
sso.system = sys;

% Check if the steady state is numerical valid
sso.numericValid = sso.isNumericValid();

% Check if the given steady state is valid
if(~sso.numericValid)
    warning('ODESCA_System:createSteadyState:steadyStateInvalid',['The steady state ''',sso.name,''' is numerical invalid. This can lead to numerical problems.']);
end

%##########################################################################
newSteadyState = sso;

if(nargout >= 2)
   valid = sso.numericValid;
end

end