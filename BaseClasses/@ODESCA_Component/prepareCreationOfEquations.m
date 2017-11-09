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

function prepareCreationOfEquations(obj)
% Creates all symbolic variables in the caller function for easy access
%
% SYNTAX
%   obj.prepareCreationOfEquations()
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   This method creates symbolic variables for the
%   states, inputs and parameters in the workspace of the
%   caller function. The variables have the names which the states, inputs
%   and parameters have at the component and store the symbolic
%   representation of all these parts. E.g.: the variable called 'state1'
%   (which is the name of the first state) would store the symbolic
%   variable 'x1'.
%
% NOTE
%   - This method uses the evalin() command to create variables
%     in the workspace of the function which called this
%     function.
%   - This method is meant to be used in the method calculateEquations of a
%     subclass of ODESCA_Component.
%
% SEE ALSO
%   ODESCA_Component.calculateEquations()
%   
% EXAMPLE
%

%% Evaluation of the task
% Create the Parameters
if( ~isempty(obj.param) )
    paramNames = fieldnames(obj.param);
    for num = 1:numel(paramNames)
        name = paramNames{num,1};
        evalin('caller',[name,' = obj.p(',num2str(num),');']);
    end
end

% Create the states 
stateNames = obj.stateNames;
for num = 1:numel(stateNames)
    name = stateNames{num,1};
    evalin('caller', [name,' = obj.x(',num2str(num),');']);
end

% Create the inputs
inputNames = obj.inputNames;
for num = 1:numel(inputNames)
    name = inputNames{num,1};
    evalin('caller', [name,' = obj.u(',num2str(num),');']);
end
end