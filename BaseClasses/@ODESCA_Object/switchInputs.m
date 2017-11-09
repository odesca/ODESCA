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

function switchInputs(obj, in1, in2)
% Switches the two inputs in1 and in2.
%
% SYNTAX
%   obj.switchInputs(in1,in2)
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
%   in1:   Input to switch. Two options:
%               - String with the name of the input
%               - Index of the input in 'inputNames'
%
%   in2:   Input to switch. Two options:
%               - String with the name of the input
%               - Index of the input in 'inputNames'
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   Switches the two inputs 'in1' and 'in2' if they exist. The
%   input arguments can be the positions of the inputs in
%   the 'inputNames' array or the names of the inputs. But these
%   two patterns must not be used at once!
%
% NOTE
%   - IMPORTANT: The two input arguments 'in1' and 'in2' must
%     be either both of type string or both of type integer.
%   - If the two ways of input arguments are mixed, an error
%     occures
%
% SEE ALSO
%
% EXAMPLE
%   obj.switchInputs('InputName1', 'InputName3')
%   obj.switchInputs(1,3)
%

%% Check of the conditions
if( isa(in1, 'char') && size(in1, 1) == 1 && ...
        isa(in2, 'char') && size(in2, 1) == 1 )
    % If the input arguments are both strings, search for the
    % choosen inputs.
    
    % Positions stay -1 if the inputs are not found
    pos1 = -1;
    pos2 = -1;
    
    % Search for the inputs in the inputNames array
    for posCount = 1:numel(obj.inputNames)
        if( strcmp(obj.inputNames(posCount),in1) )
            pos1 = posCount;
        end
        if( strcmp(obj.inputNames(posCount),in2) )
            pos2 = posCount;
        end
    end
    
    % Check if matching input names were found
    if( pos1 == -1 )
        error('ODESCA_Object:switchInputs:InputNotFound',['There is no intput with the name ''',in1,'''.']);
    end
    if( pos2 == -1 )
        error('ODESCA_Object:switchInputs:InputNotFound',['There is no intput with the name ''',in2,'''.']);
    end
    
elseif( isnumeric(in1) && isnumeric(in2) && numel(in1)==1 && numel(in2)==1 )
    % If the input arguments are both numeric, check if the array
    % index exists in 'inputNames'
    
    % Check if the input arguments are positiv integers and in
    % the range of the number of input names
    l_in = numel(obj.inputNames);
    if( in1 <= 0 || mod(in1,1) ~= 0 || in1 > l_in || ...
            in2 <= 0 || mod(in2,1) ~= 0 || in2 > l_in )
        error('ODESCA_Object:switchInputs:InvalidArryIndex','The indexs of the inputs must be integer values between 1 and the number of inputs.');
    end
    
    pos1 = in1;
    pos2 = in2;
    
else
    % If the input pair is no valid input, throw an error
    error('ODESCA_Object:switchInputs:InvalidInputArguments','The input arguments must be either both of type string or both of type integer.');
end

%% Evaluation of the task
% Get the inputs to be switched and create a placeholder
u1 = obj.u(pos1);
u2 = obj.u(pos2);
placehold = sym('REPLACEVAR');

% Switch the inputs in the state equations
if(~isempty(obj.f))
   obj.f = subs(obj.f,u1,placehold); 
   obj.f = subs(obj.f,u2,u1);
   obj.f = subs(obj.f,placehold,u2);
end

% Switch the inputs in the output equations
if(~isempty(obj.g))
    obj.g = subs(obj.g,u1,placehold);
    obj.g = subs(obj.g,u2,u1);
    obj.g = subs(obj.g,placehold,u2);
end

% Switch the names
tempName = obj.inputNames(pos1);
obj.inputNames(pos1) = obj.inputNames(pos2);
obj.inputNames(pos2) = tempName;

% Switch the units
tempUnit = obj.inputUnits(pos1);
obj.inputUnits(pos1) = obj.inputUnits(pos2);
obj.inputUnits(pos2) = tempUnit;

% Call the method to signal that the parts of the equations were changed
obj.reactOnEquationsChange();

end