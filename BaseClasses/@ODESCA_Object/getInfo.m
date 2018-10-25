function info = getInfo(obj)
% Creates info structur about states, inputs, outputs and parameters
%
% SYNTAX
%   info = obj.getInfo();
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%   info:   Structure with the four fields 'states', 'inputs', 'outputs' 
%           and 'param'. In each field, the information about the parts 
%           are listed in arrays where the first column is the a string 
%           which represents the position, the second the corresponding 
%           name and the third the unit. For the states and inputs, the
%           first column entry matches the symbolic variable.
%
% DESCRIPTION
%   This method creates a structure with the three fields
%   'states', 'inputs' and 'outputs'. In each field an array
%   holds the information about the parts where the first column is the
%   symbolic variable, the second the corresponding name and the third the 
%   unit. E.g.: the field 'states' could look like this:
%       'x1'    'StateName1'    'm'
%       'x2'    'StateName2'    'm/s'
%
% NOTE
%   - In the fields 'outputs' and 'param' the first column contains 
%   representive strings  like 'y1', 'y2', etc. and 'p1', 'p2', etc. which 
%   are not used anywhere else in ODESCA.
%
% SEE ALSO
%   - The assigned values for the parameters are not included in the info
%   structur. To get the information about the values simply call the
%   structur obj.param.
%
% EXAMPLE
%   Pipe = OCLib_Pipe('MyPipe');
%   Pipe.setConstructionParam('Nodes',2);
%   info_states = Pipe.getInfo.states
%   info_inputs = Pipe.getInfo.inputs
%   info_outputs = Pipe.getInfo.outputs
%   info_param = Pipe.getInfo.param
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
% Define info structurs to return
info = struct;

% Create info list for the states
info.states = {};
for i=1:length(obj.stateNames)
    info.states{i,1} = char(obj.x(i));
    info.states{i,2} = obj.stateNames{i};
    info.states{i,3} = obj.stateUnits{i};
end

% Create info list for the inputs
info.inputs = {};
for i=1:length(obj.inputNames)
    info.inputs{i,1} = char(obj.u(i));
    info.inputs{i,2} = obj.inputNames{i};
    info.inputs{i,3} = obj.inputUnits{i};
end

% Create info list for the outputs
info.outputs = {};
for i=1:length(obj.outputNames)
    info.outputs{i,1} = ['y',num2str(i)];
    info.outputs{i,2} = obj.outputNames{i};
    info.outputs{i,3} = obj.outputUnits{i};
end

% Create info list for the parameters
info.param = {};
if(~isempty(obj.param))
    paramNames = fieldnames(obj.param);
    for i=1:length(paramNames)
        info.param{i,1} = ['p',num2str(i)];
        info.param{i,2} = paramNames{i};
        info.param{i,3} = obj.paramUnits{i};
    end
end

end