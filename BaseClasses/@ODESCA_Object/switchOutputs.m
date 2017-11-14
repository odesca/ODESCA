function switchOutputs(obj, out1, out2)
% Switches the two outputs out1 and out2.
%
% SYNTAX
%   obj.switchOutputs(out1,out2)
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
%   out1:   Output to switch. Two options:
%               - String with the name of the output
%               - Index of the output in 'outputNames'
%
%   out2:   Output to switch. Two options:
%               - String with the name of the output
%               - Index of the output in 'outputNames'
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   Switches the two outputs out1 and out2 if they exist. The
%   input arguments can be the positions of the outputs in
%   the 'outputNames' array or the names of the outputs. But these
%   two patterns must not be used at once!
%
% NOTE
%   - IMPORTANT: The two input arguments 'out1' and 'out2' must
%     be either both of type string or both of type integer.
%   - If the two ways of input arguments are mixed, an error
%     occures
%
% SEE ALSO
%
% EXAMPLE
%   obj.switchOutputs('OutputName1', 'OutputName3')
%   obj.switchOutputs(1,3)
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
if( isa(out1, 'char') && size(out1, 1) == 1 && ...
        isa(out2, 'char') && size(out2, 1) == 1 )
    % If the input arguments are both strings, search for the
    % choosen Outputs.
    
    % Positions stay at -1 if the outputs are not found
    pos1 = -1;
    pos2 = -1;
    
    % Search for the outputs in the outputNames array
    for posCount = 1:numel(obj.outputNames)
        if( strcmp(obj.outputNames(posCount),out1) )
            pos1 = posCount;
        end
        if( strcmp(obj.outputNames(posCount),out2) )
            pos2 = posCount;
        end
    end
    
    % Check if matching output names were found
    if( pos1 == -1 )
        error('ODESCA_Object:switchOutputs:OutputNotFound',['There is no output with the name ''',out1,'''.']);
    end
    if( pos2 == -1 )
        error('ODESCA_Object:switchOutputs:OutputNotFound',['There is no output with the name ''',out2,'''.']);
    end 
    
elseif( isnumeric(out1) && isnumeric(out2) && numel(out1)==1 && numel(out2)==1  )
    % If the input arguments are both numeric, check if the array
    % index exists in 'outputNames'
    
    % Check if the input arguments are positiv integers and in
    % the range of the number of outputs
    l_out = numel(obj.outputNames);
    if( out1 <= 0 || mod(out1,1) ~= 0 || out1 > l_out || ...
            out2 <= 0 || mod(out2,1) ~= 0 || out2 > l_out)
        error('ODESCA_Object:switchOutputs:InvalidArryIndex','The indexs of the outputs must be integer values between 1 and the number of outputs.');
    end
    
    pos1 = out1;
    pos2 = out2;
    
else
    % If the input pair is no valid input, throw an error
    error('ODESCA_Object:switchOutputs:InvalidInputArguments','The input arguments must be either both of type string or both of type integer.');
end

%% Evaluation of the task
% Switch the equations
tempG = obj.g(pos1);
obj.g(pos1) = obj.g(pos2);
obj.g(pos2) = tempG;

% Switch the names
tempName = obj.outputNames(pos1);
obj.outputNames(pos1) = obj.outputNames(pos2);
obj.outputNames(pos2) = tempName;

% Switch the units
tempUnit = obj.outputUnits(pos1);
obj.outputUnits(pos1) = obj.outputUnits(pos2);
obj.outputUnits(pos2) = tempUnit;

% Call the method to signal that the parts of the equations were changed
obj.reactOnEquationsChange();

end