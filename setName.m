function setName(obj, name)
% Sets the name of the steady state
%
% SYNTAX
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%   name:   New name as string
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   Sets the name of the steady state. It is important that no steady state
%   with the same name exists in the system this steady state is attached
%   to.
%
% NOTE
%
% SEE ALSO
%
% EXAMPLE
%     Pipe = OCLib_Pipe('MyPipe');
%     Pipe.setConstructionParam('Nodes',2);
%     Pipe.setParam('cPipe',500);
%     Pipe.setParam('mPipe',0.5);
%     Pipe.setParam('VPipe',0.001);
%     Pipe.setParam('RhoFluid', 998);
%     Pipe.setParam('cFluid',4182);
%     PipeSys = ODESCA_System('MySystem',Pipe);
%     ss1 = PipeSys.createSteadyState([40; 40],[40; 0.1],'ss1');
%     ss1.setName('myName')
%     newname = PipeSys.steadyStates(1).name
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
% Check if the method is called for more than one object
if( numel(obj) ~= 1 )
   error('ODESCA_SteadyState:setName:tooManyObjects','The method ''setName'' can not be called for more than one instance of the class ODESCA_SteadyState at once.'); 
end

% Check if the name is a string
if( ~ischar(name) || size(name,1) ~= 1)
    error('ODESCA_SteadyState:setName:nameNotAString','The argument ''name'' has to be a string.');
end

% If the steady state is added to a system, check if the name is unique
if( ~isempty(obj.system) )
    oldName = obj.name;
    
    % Get the names of all steady states at the system
    nameList = {};
    for num = 1:numel(obj.system.steadyStates)
        ssop = obj.system.steadyStates(num);
        nameList = [nameList;ssop.name]; %#ok<AGROW>
    end
    
    % Remove the name of the current steady state
    nameList = nameList(~strcmp(nameList,oldName));
    
    % Check if the new name is a member of the name list
    if( ismember(name,nameList) )
       error('ODESCA_SteadyState:setName:nameAlreadyInSystem',['There is another steady state in the system this steady state belongs to which has the name ''',name,'''.']); 
    end
end

%% Evaluation of the task
% Set the name
obj.name = name;

end