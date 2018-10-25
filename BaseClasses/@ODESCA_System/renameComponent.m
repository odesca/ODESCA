function renameComponent(sys, oldName, newName )
% Renames a component within a system
%
% SYNTAX
%   sys.renameComponent(oldName,newName);
%
% INPUT ARGUMENTS
%   sys:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
%   oldName:Old name of the component that should be renamed.
%
%   newName:New name of the component that should be renamed.
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%
% NOTE
%  - This method only changes the component name inside the system. The
%    component you created inside
%
% SEE ALSO
%
% EXAMPLE
%   Pipe = OCLib_Pipe('MyPipe');
%   Pipe.setConstructionParam('Nodes',2);
%   PipeSys = ODESCA_System('MySystem',Pipe);
%   componentName_before = PipeSys.components
%   PipeSys.renameComponent('MyPipe','YourPipe');
%   componentName_after = PipeSys.components
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
% check if oldName is a string
if( ~ischar(oldName) || size(oldName,1) ~= 1)
    error('ODESCA_System:renameComponent:oldNameNotAString','The old name has to be a string.');
end

% check if a component with the old name exists
if( ~ismember(oldName ,sys.components) )
    error('ODESCA_System:renameComponent:oldNameNotInSystem',['The system has no component with the name ''',oldName,'''.']);
end

% check if the new name is valid
if( ~isvarname(newName))
    error('ODESCA_System:renameComponent:newNameNotValid','The Argument ''newName'' has to match the naming conventions of MATLAB variables.');
end

% check if the size of the new name has maximal 31 characters
if( size(newName,2) > 31 )
    error('ODESCA_System:renameComponent:newNameLengthInvalid','The argument ''newName'' exceeds the maximal length of 31 characters.');
end

% check if the new name equals the old name
if( strcmp(newName,oldName) )
    return;
end

% check if the new name is free
if( ismember(newName ,sys.components) )
    error('ODESCA_System:renameComponent:newNameAlreadyInSystem',['The system already has a component with the name ''',newName,'''.']);
end

%% Evaluation of the task
% change the names of the parameter
paramNames = fields(sys.param);
for numParam = 1:numel(paramNames)
    paramName = paramNames{numParam};
    % Check if the parameter name starts with the old component name
    if( strncmp(paramName,[oldName,'_'],numel(oldName)+1) )
        % Rename the parameter by adding the name of the parameter after
        % the component name ( numel(oldName) + 1 ) to new component name
        sys.renameParam(paramName,[newName,paramName(numel(oldName)+1:end)])
    end    
end

% Change the names of the inputs
for numIn = 1:numel(sys.inputNames)
    inputName = sys.inputNames{numIn};
    % Check if the input name starts with the old component name
    if( strncmp(inputName,[oldName,'_'],numel(oldName)+1) )
        % Rename the input by adding the name of the input after
        % the component name ( numel(oldName) + 1 ) to new component name
        sys.inputNames{numIn} = [newName,inputName(numel(oldName)+1:end)];
    end 
end

% Change the names of the outputs
for numOut = 1:numel(sys.outputNames)
    outputName = sys.outputNames{numOut};
    % Check if the output name starts with the old component name
    if( strncmp(outputName,[oldName,'_'],numel(oldName)+1) )
        % Rename the output by adding the name of the output after
        % the component name ( numel(oldName) + 1 ) to new component name
        sys.outputNames{numOut} = [newName,outputName(numel(oldName)+1:end)];
    end 
end


% Change the names of the states
for numState = 1:numel(sys.stateNames)
    stateName = sys.stateNames{numState};
    % Check if the input name starts with the old component name
    if( strncmp(stateName,[oldName,'_'],numel(oldName)+1) )
        % Rename the state by adding the name of the state after
        % the component name ( numel(oldName) + 1 ) to new component name
        sys.stateNames{numState} = [newName,stateName(numel(oldName)+1:end)];
    end 
end

% Change the name in the component list
for num = 1:numel(sys.components)
   if( strcmp(sys.components{num}, oldName) ) 
       sys.components{num} = newName;
   end
end

end