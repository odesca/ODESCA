function switchStates(obj, state1, state2)
% Switches the two states state1 and state2.
%
% SYNTAX
%   obj.switchStates(state1,state2)
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
%   state1:   State to switch. Two options:
%               - String with the name of the state
%               - Index of the state in 'stateNames'
%
%   state2:   State to switch. Two options:
%               - String with the name of the state
%               - Index of the state in 'stateNames'
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   Switches the two states 'state1' and 'state2' if they exist. The
%   input arguments can be the positions of the inputs in
%   the 'stateNames' array or the names of the states. But these
%   two patterns must not be used at once!
%
% NOTE
%   - IMPORTANT: The two input arguments 'state1' and 'state2' must
%     be either both of type string or both of type integer.
%   - If the two ways of input arguments are mixed, an error
%     occures
%
% SEE ALSO
%
% EXAMPLE
%   Pipe = OCLib_Pipe('MyPipe');
%   Pipe.setConstructionParam('Nodes',2);
%   states_before = Pipe.stateNames
%   Pipe.switchStates('Temp1', 'Temp2'); % or  Pipe.switchStates(1,2);
%   states_after = Pipe.stateNames
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
if( isa(state1, 'char') && size(state1, 1) == 1 && ...
        isa(state2, 'char') && size(state2, 1) == 1 )
    % If the input arguments are both strings, search for the
    % choosen states.
    
    % Positions stay -1 if the states are not found
    pos1 = -1;
    pos2 = -1;
    
    % Search for the states in the stateNames array
    for posCount = 1:numel(obj.stateNames)
        currentName = obj.stateNames{posCount};
        if( strcmp(currentName,state1) )
            pos1 = posCount;
        end
        if( strcmp(currentName,state2) )
            pos2 = posCount;
        end
    end
    
    % Check if matching input names were found
    if( pos1 == -1 )
        error('ODESCA_Object:switchStates:InputNotFound',['There is no state with the name ''',state1,'''.']);
    end
    if( pos2 == -1 )
        error('ODESCA_Object:switchStates:InputNotFound',['There is no state with the name ''',state2,'''.']);
    end
    
elseif( isnumeric(state1) && isnumeric(state2) && numel(state1)==1 && numel(state2)==1 )
    % If the input arguments are both numeric, check if the array
    % index exists in 'stateNames'
    
    % Check if the input arguments are positiv integers and in
    % the range of the number of state names
    l_in = numel(obj.stateNames);
    if( state1 <= 0 || mod(state1,1) ~= 0 || state1 > l_in || ...
            state2 <= 0 || mod(state2,1) ~= 0 || state2 > l_in )
        error('ODESCA_Object:switchStates:InvalidArryIndex','The indexs of the states must be integer values between 1 and the number of states.');
    end
    
    pos1 = state1;
    pos2 = state2;
    
else
    % If the input pair is no valid input, throw an error
    error('ODESCA_Object:switchStates:InvalidInputArguments','The input arguments must be either both of type string or both of type integer.');
end

%% Evaluation of the task
% Get the states to be switched and create a placeholder
x1 = obj.x(pos1);
x2 = obj.x(pos2);
placehold = sym('REPLACEVAR');

% Switch the states in the state equations
obj.f = subs(obj.f,x1,placehold); 
obj.f = subs(obj.f,x2,x1);
obj.f = subs(obj.f,placehold,x2);

% Switch the states in the output equations
if(~isempty(obj.g))
    obj.g = subs(obj.g,x1,placehold);
    obj.g = subs(obj.g,x2,x1);
    obj.g = subs(obj.g,placehold,x2);
end

% Switch the state equations
tempF = obj.f(pos1);
obj.f(pos1) = obj.f(pos2);
obj.f(pos2) = tempF;

% Switch the names
tempName = obj.stateNames(pos1);
obj.stateNames(pos1) = obj.stateNames(pos2);
obj.stateNames(pos2) = tempName;

% Switch the units
tempUnit = obj.stateUnits(pos1);
obj.stateUnits(pos1) = obj.stateUnits(pos2);
obj.stateUnits(pos2) = tempUnit;

% Call the method to signal that the parts of the equations were changed
obj.reactOnEquationsChange();

end