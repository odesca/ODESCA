function equationsCorrect = checkEquationsCorrect(obj)
% Check if all equations were set correctly
%
% SYNTAX
%   equationCorrect = obj.checkEquationsCorrect()
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%   equationsCorrect: boolean, true if all equations are set correctly
%
% DESCRIPTION
%   This method checks if all equations are set correctly. This is the case
%   if the equations have the same number of elements as the names for the
%   equations, are symbolic and do not hold any symbolic variables which
%   are not part of the component.
%
% NOTE
%
% SEE ALSO
%   ODESCA_Object.isValidSymbolic()
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

%% Evaluation of the task
equationsCorrect = true;

% Check if the equations for the states (f) are set correctly
if( ~isempty(obj.stateNames) )    
    % Check if the number of equations is equal to the number of names
    sizeStates = size(obj.f);
    if( sizeStates(1) ~= numel(obj.stateNames) || sizeStates(2) ~= 1 )
        warning('ODESCA_Component:checkEquationsCorrect:wrongSizeForStateEquations',['The array of the equations of the state changes (f) does not have the correct size.\n', ...
            'Expected size: [%i,1]\nActual Size: [%i,%i]'],numel(obj.stateNames),sizeStates(1),sizeStates(2));
        equationsCorrect = false; 
        return;
    end
    
    % Check if the equations are symbolic
    if( ~isa(obj.f,'sym') ) 
        warning('ODESCA_Component:checkEquationsCorrect:stateEquationsNotSymbolic','The equations of the state changes (f) are not of typ symbolic.');
        equationsCorrect = false;
        return;
    end
    
    % Check if the equations only conain symbolic variables of the system
    if( ~obj.isValidSymbolic(obj.f) )
        warning('ODESCA_Component:checkEquationsCorrect:stateEquationsWrongSymbolics','The equations of the state changes (f) containe symbolic variables which are not part of the component. This could also indicate that the not all state equations were set.');
        equationsCorrect = false; 
        return;
    end
end

% Check if the equations for the outputs (g) are set correctlyt
if( ~isempty(obj.outputNames) )
    % Check if the number of equations is equal to the number of names
    sizeOutputs = size(obj.g);
    if( sizeOutputs(1) ~= numel(obj.outputNames) || sizeOutputs(2) ~= 1 )
        warning('ODESCA_Component:checkEquationsCorrect:wrongSizeForOutputEquations',['The array of the equations of the outputs (g) does not have the correct size.\n', ...
            'Expected size: [%i,1]\nActual Size: [%i,%i]'],numel(obj.outputNames),sizeOutputs(1),sizeOutputs(2));
        equationsCorrect = false; 
        return;
    end
    
    % Check if the equations are symbolic
    if( ~isa(obj.g,'sym') )
        warning('ODESCA_Component:checkEquationsCorrect:outputEquationsNotSymbolic','The equations of the outputs (g) are not of typ symbolic.');
        equationsCorrect = false; 
        return;
    end
    
    % Check if the equations only contain symbolic variables of the system
    if( ~obj.isValidSymbolic(obj.g) )
        warning('ODESCA_Component:checkEquationsCorrect:outputEquationsWrongSymbolics','The equations of the outputs (g) containe symbolic variables which are not part of the component. This could also indicate that the not all output equations were set.');
        equationsCorrect = false; 
        return;
    end
end

end