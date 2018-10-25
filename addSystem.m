function addSystem(rootSys, newSys)
% Adds the given system to the existing
%
% SYNTAX
%   rootSys.addSystem(newSys)
%
% INPUT ARGUMENTS
%   rootSys:    Instance of the object where the method was
%               called. This parameter is given automatically.
%
%   newSys:   System which should be added to the existing system
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   This method adds the new system to the root system by combining
%   the two systems. The root system  keeps the numeration 
%   of the symbolic variables. The new system is renumerated. If there
%   are components in both systems with the same name numbers are added to
%   the names of the new system to differ them.
%
% NOTE
%   - If there are components in both systems with the same name numbers 
%     are added to the names of the new system to differ them.
%   - The name and the defaultSampleTime are taken from the root system.
%
% SEE ALSO
%
% EXAMPLE
%     Pipe = OCLib_Pipe('MyPipe');
%     Pipe.setConstructionParam('Nodes',2);
%     TSens = OCLib_TSensor('MyTSens');
%     TSensSys = ODESCA_System('MySystem',TSens);
%     PipeSys = ODESCA_System('MySystem',Pipe);
%     PipeSys.addSystem(TSensSys);
%     components = PipeSys.components
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
% Check if the argument newSys is of the class ODESCA_System
if( ~isa(newSys,'ODESCA_System') )
   error('ODESCA_System:addSystem:newSysNotASystem','The argument ''newSys'' has to be an instance of the class ODESCA_System.'); 
end

% Check if  one of the systems or both have no components
if( isempty(rootSys.components) )
   if( isempty(newSys.components) )
       warning('ODESCA_System:addSystem:bothSystemsEmpty','Both systems are empty. Nothing changed');
       return;
   else
       warning('ODESCA_System:addSystem:rootSystemEmpty','The root systems is empty. The new system will be copied into the root system.');
   end
elseif( isempty(newSys.components) )
    warning('ODESCA_System:addSystem:newSystemEmpty','The new system is empty. The root system has not changed.');
    return;
end

%% Evaluation of the task
% Create a copy of the given system to work with
newSys = newSys.copy();

%--------------------------------------------------------------------------
% Find name conflicts and add numbers to the name to avoid the conflict

% Get the index of name conflicts and a list of all conflict names
conflictIndex = ismember(newSys.components, rootSys.components);
conflictNames = newSys.components(conflictIndex);

% List to contain all names the combined system will have. Before renaming
% the names with conflicts this list contains all names of the root system
% and all names of the new system which are not conflict names
totalNameList = [rootSys.components; newSys.components(~conflictIndex)]; 

% Cell array to store name changes. First column contains old names. Second
% column contains new names.
changeList = {};

% Create changed names for every name conflict
for numConflictName = 1:numel(conflictNames)
    name = conflictNames{numConflictName}; 
    
    changedName = name;
    addNumber = 1; % By setting to 1, name numeration starts at 2
    % Add numbers to the name untill a unused name is found
    while(ismember(changedName,totalNameList))
        addNumber = addNumber + 1;
        changedName = [name,num2str(addNumber)];
    end
    % Add the name change to the list of changes
    changeListSize = size(changeList,1);
    changeList{changeListSize+1,1} = name; %#ok<AGROW>
    changeList{changeListSize+1,2} = changedName; %#ok<AGROW>;
    
    % Extend the list of total names
    totalNameList = [totalNameList;changedName]; %#ok<AGROW>
end

% Rename components and throw warning if name conflicts occured
if( ~isempty(changeList) )
   % create warning message
   msg = ['There are components with the same name in both systems.\n', ...
       'The following changes to the names of the new system are made:\n'];
   for numChanges = 1:size(changeList,1)
      msg = [msg,'''', changeList{numChanges,1},''' -> ''',changeList{numChanges,2},'''\n']; %#ok<AGROW>
   end
   
   % Throw warning
   warning('ODESCA_System:addSystem:namesChanged',msg);
   
   % Rename components
   for numChanges = 1:size(changeList,1)
      newSys.renameComponent(changeList{numChanges,1},changeList{numChanges,2}); 
   end
end

%--------------------------------------------------------------------------
% Add the new system to the root system

% Add parameter and fill them with the values of the new system
if( ~isempty(newSys.param) )
   paramNames = fieldnames(newSys.param);
   rootSys.addParameters(paramNames,newSys.paramUnits);
   
   % Fill the new parameters with the values of the old parameters
   for num = 1:numel(paramNames)
       value = newSys.param.(paramNames{num});
       rootSys.setParam(paramNames{num}, value);
   end
end

%--------------------------------------------------------------------------

% Add inputs and create symbolic arrays of the inputs for the
% substitution in the equations
newU = [];
oldU = [];
if( ~isempty(newSys.u) )
   numberNewU = numel(newSys.u); %number of inputs in the component
   numberOldU  = numel(rootSys.u);  %number of inputs in the system
   
   % Add the new input names and units to the system
   rootSys.inputNames = [rootSys.inputNames; newSys.inputNames];
   rootSys.inputUnits = [rootSys.inputUnits; newSys.inputUnits];
   
   % Add the new symbolic inputs to the system and fill the symbolic arrays
   % for the substitution in the equations
   oldU = newSys.u;
   newU = sym('u',[numberOldU + numberNewU,1]);
   newU = newU( (numberOldU + 1):(numberOldU + numberNewU) ); 
   rootSys.u = [rootSys.u; newU];  
end

%--------------------------------------------------------------------------

% Add states and create symbolic arrays of the states for the
% substitution in the equations
newX = [];
oldX = [];
if( ~isempty(newSys.x) )
   numberNewX = numel(newSys.x); %number of states in the component
   numberOldX = numel(rootSys.x);  %number of states in the system
   
   % Add the new state names to the system
   rootSys.stateNames = [rootSys.stateNames; newSys.stateNames];
   rootSys.stateUnits = [rootSys.stateUnits; newSys.stateUnits];
   
   % Add the new symbolic states (with different numeration) to the system 
   % and fill the symbolic arrays for the substitution in the equations
   oldX = newSys.x;
   newX = sym('x',[numberOldX + numberNewX,1]);
   newX = newX( (numberOldX + 1):(numberOldX + numberNewX) ); 
   rootSys.x = [rootSys.x; newX];  
end

%--------------------------------------------------------------------------

% Add the inputs
rootSys.outputNames = [rootSys.outputNames; newSys.outputNames];
rootSys.outputUnits = [rootSys.outputUnits; newSys.outputUnits];

%--------------------------------------------------------------------------

% Substitute the symbolic variables in the equations an add them to the
% system
if( ~isempty(newSys.f) )
    tempF = newSys.f;
    tempF = subs(tempF,oldX,newX);
    tempF = subs(tempF,oldU,newU);
    rootSys.f = [rootSys.f; tempF];
end
if( ~isempty(newSys.g) )
    tempG = newSys.g;
    tempG = subs(tempG,oldX,newX);
    tempG = subs(tempG,oldU,newU);
    rootSys.g = [rootSys.g; tempG];
end

% Add the new components
rootSys.components = [rootSys.components; newSys.components];

% Call the method to signal that the parts of the equations were changed
rootSys.reactOnEquationsChange();

end