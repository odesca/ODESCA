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

function symStruct = getSymbolicStructure(obj)
% Creates a structure with the symbolic variables of the system
%
% SYNTAX
%   symStruct = obj.getSymbolicStructure()
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%   symStruct:  A structure containing the three substructure 'states', 
%               'inputs', 'outputs' and 'params' which store the symbolic 
%               variables in the fields with their name. If there are no 
%               inputs, no states or no parameters the corresponding fields 
%               of the symStruct is empty.
%
% DESCRIPTION
%   This method creates and returns a structure holding three substructures
%   'states', 'inputs', 'outputs' and 'params' which store the symbolic 
%   variables in the fields with their name. If there are no inputs, no 
%   states or no parameters the corresponding field of the symStruct is 
%   empty. For example the substructure symStruct.inputs could be this:
%       inputs.stateName1 = x1;
%       inputs.stateName2 = x2;
%   where x1 and x2 are the symbolic variables.
%
% NOTE
%   - This structure is usefull to create a symbolic expression
%     which can be used for example in the function
%     connectInput() of the class ODESCA_System as value.
%
% SEE ALSO
%   ODESCA_System.connectInput(toConnect, connection)
%   x
%   stateNames
%   u
%   inputNames
%   p
%   param
%
% EXAMPLE
%

%% Evaluation of the task
% Create the structure to be returned
symStruct = struct;
symStruct.states  = [];
symStruct.inputs  = [];
symStruct.outputs = [];
symStruct.params  = [];

% Create the state structure if there are states
if( ~isempty(obj.stateNames) )
    states = struct;
    for num = 1:numel(obj.stateNames)
        states.(obj.stateNames{num}) = obj.x(num);
    end
    symStruct.states = states;
end

% Create the input structure if there are inputs
if( ~isempty(obj.inputNames) )
    inputs = struct;
    for num = 1:numel(obj.inputNames)
        inputs.(obj.inputNames{num}) = obj.u(num);
    end
    symStruct.inputs = inputs;
end

% Create the output structure if there are outputs
if( ~isempty(obj.outputNames) )
    outputs = struct;
    for num = 1:numel(obj.outputNames)
        outputs.(obj.outputNames{num}) = obj.g(num);
    end
    symStruct.outputs = outputs;
end

% Create the param structure if there are parameters
if( ~isempty(obj.p) )
    params = struct;
    paramNames = fieldnames(obj.param);
    for num = 1:numel(paramNames)
        params.(paramNames{num}) = obj.p(num);
    end
    symStruct.params = params;
end

end