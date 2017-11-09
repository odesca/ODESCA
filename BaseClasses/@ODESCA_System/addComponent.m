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

function addComponent(sys, comp)
% Adds a component to the system.
%
% SYNTAX
%   sys.addComponent(comp)
%
% INPUT ARGUMENTS
%   sys:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
%   comp:   The ODESCA_Component that should be added to the system.
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   This function adds a component to the system. This means it adds all
%   equations, inputs, outputs and parameters and renames them to fit in
%   the system.
%
% NOTE
%
% SEE ALSO
%
% EXAMPLE
%

%% Check of the conditions
% Check if the given component is a subclass of component
if( ~isa(comp,'ODESCA_Component') )
    error('ODESCA_System:addComponent:tryingToAddNoneComponent','The parameter ''comp'' has to be a subclass of ODESCA_Component.')
end

% Check if there is a component with the same name
if( ~isempty(sys.components) )
    if( ismember(comp.name, sys.components))
        error('ODESCA_System:addComponent:componentNameConflict',['A component with the name ''',comp.name,''' already exists in this system.']);
    end
end

% Try calculate the equations, throw error if it is not possible
warning('off','all')
ready = comp.tryCalculateEquations();
warning('on','all')
if( ~ready )
    error('ODESCA_System:addComponent:canNotCalculateEquations',['The equations of the component ''',comp.name,''' can not be calculated. Either there are unset construction parameters or the calculation of the equations in the class definition is incorrect. Use the method ''tryCalculateEquations'' of the component to get more information.']);
end

% Check if all equations have been set correctly
if( ~comp.checkEquationsCorrect() )
    error('ODESCA_System:tryCalculateEquations:equationsNotCorrect',['A component with uncorrect equations can not be added to a system. Check the equations in the class ''',class(comp),'''.']);
end

%% Evaluation of the task

% Use a copy of the component to add to the system
comp = comp.copy();

% Add parameter and create symbolic arrays of the parameters for the
% substitution in the equations
newSymParam = [];
oldSymParam = [];
if( ~isempty(comp.param) )
   paramNames = fieldnames(comp.param);
   toAdd = {};
   for num = 1:numel(paramNames) 
      toAdd = [toAdd; [comp.name,'_',paramNames{num}]]; %#ok<AGROW>
   end
   
   % Add the new symbolic parameters to the system and fill the symbolic arrays
   % for the substitution in the equations
   oldSymParam = comp.p;
   newSymParam = sys.addParameters(toAdd,comp.paramUnits);
   
   % Fill the new parameters with the value of the old parameters
   for num = 1:numel(paramNames)
       value = comp.param.(paramNames{num});
       if( ~isempty(value) )
            sys.setParam(toAdd{num}, value);
       end
   end
end

%--------------------------------------------------------------------------

% Add states and create symbolic arrays of the states for the
% substitution in the equations
newX = [];
oldX = [];
if( ~isempty(comp.x) )
   toAdd = {};
   numberCompX = numel(comp.x); %number of states in the component
   numberSysX  = numel(sys.x);  %number of states in the system
   
   % Add the name of the component to each state
   for num = 1:numberCompX
       toAdd = [toAdd; [comp.name,'_',comp.stateNames{num}]]; %#ok<AGROW>
   end
   
   % Add the new state names and units to the system
   sys.stateNames = [sys.stateNames; toAdd];
   sys.stateUnits = [sys.stateUnits; comp.stateUnits];
   
   % Add the new symbolic states (with different numeration) to the system 
   % and fill the symbolic arrays for the substitution in the equations
   oldX = comp.x;
   newX = sym('x',[numberSysX + numberCompX,1]);
   newX = newX( (numberSysX + 1):(numberSysX + numberCompX) ); 
   sys.x = [sys.x; newX];  
end

%--------------------------------------------------------------------------

% Add inputs and create symbolic arrays of the inputs for the
% substitution in the equations
newU = [];
oldU = [];
if( ~isempty(comp.u) )
   toAdd = {};
   numberCompU = numel(comp.u); %number of inputs in the component
   numberSysU  = numel(sys.u);  %number of inputs in the system
   
   % Add the name of the component to each input
   for num = 1:numberCompU
       toAdd = [toAdd; [comp.name,'_',comp.inputNames{num}]]; %#ok<AGROW>
   end
   
   % Add the new input names and units to the system
   sys.inputNames = [sys.inputNames; toAdd];
   sys.inputUnits = [sys.inputUnits; comp.inputUnits];
   
   % Add the new symbolic inputs to the system and fill the symbolic arrays
   % for the substitution in the equations
   oldU = comp.u;
   newU = sym('u',[numberSysU + numberCompU,1]);
   newU = newU( (numberSysU + 1):(numberSysU + numberCompU) ); 
   sys.u = [sys.u; newU];  
end

%--------------------------------------------------------------------------

% Add the output names and units
toAdd = {};
for num = 1:numel(comp.outputNames)
   toAdd = [toAdd; [comp.name,'_',comp.outputNames{num}]]; %#ok<AGROW>
end
sys.outputNames = [sys.outputNames; toAdd];
sys.outputUnits = [sys.outputUnits; comp.outputUnits];

%--------------------------------------------------------------------------

% Substitute the symbolic variables in the equations an add them to the
% system
if( ~isempty(comp.f) )
    tempF = comp.f;
    tempF = subs(tempF,oldX,newX);
    tempF = subs(tempF,oldU,newU);
    tempF = subs(tempF,oldSymParam,newSymParam);
    sys.f = [sys.f; tempF];
end
if( ~isempty(comp.g) )
    tempG = comp.g;
    tempG = subs(tempG,oldX,newX);
    tempG = subs(tempG,oldU,newU);
    tempG = subs(tempG,oldSymParam,newSymParam);
    sys.g = [sys.g; tempG];
end

% Add the name of the new component
sys.components = [sys.components; comp.name];

% Call the method to signal that the parts of the equations were changed
sys.reactOnEquationsChange();

end