function connectInput(sys, input, connection)
% Substituts the choosen input with a symbolic expression
%
% SYNTAX
%   sys.connectInput(input, connection)
%
% INPUT ARGUMENTS
%   sys:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
%   input:  name or position of the input to be substituted
%
%   connection: symbolic expression the input is replaced with
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   This method substitutes the choosen input with the symbolic expression
%   given or the outputs specified and removes the input from the system.
%
% NOTE
%
% SEE ALSO
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

%% Check of the conditions
% Check if the input name is a scalar string or a number
if( ischar(input) && size(input,1) == 1 )
    % Check if the input exists
    if( ~ismember(input, sys.inputNames) )
        error('ODESCA_System:connectInput:inputNotFound',['There is no input with the name ''',input,''' in the system.'])
    end
    
    % Find the position and the symbolic variable of the input
    inputPosition = 0;
    inputSymbolic = [];
    for pos = 1:numel(sys.inputNames)
        if( strcmp(input,sys.inputNames{pos}) )
            inputPosition = pos;
            inputSymbolic = sys.u(pos);
        end
    end
elseif( isnumeric(input) && numel(input) == 1 )
    %Check if the number is a positiv value unequal to NaN or Inf
    if( input <= 0 || isnan(input) || isinf(input))
        error('ODESCA_System:connectInput:invalidOutputNumber','The position given as input is not a positiv value greater than zero.');
    end
    
    %Check if the system has the number of inputs.
    if( numel(sys.inputNames) < input )
        error('ODESCA_System:connectInput:inputNumberExceedsIndex','The position given as input exceeds the number of inputs.');
    end
    
    % Get the symolic variabl of the input and set the input number
    inputPosition = input;
    inputSymbolic = sys.u(input);
else
    error('ODESCA_System:connectInput:toConnectInvalid','The argument ''toConnect'' has to be a scalar string or a numeric scalar value.');
end

% Check if the argument 'connection' is a symbolic expression or a string
% (Logic: Throw error if it is NOT a symbolic expression OR a string)
if( ~((isa(connection,'sym') && numel(connection) == 1) || (ischar(connection) && size(connection,1) == 1)) )
    error('ODESCA_System:connectInput:connectionInvalidType','The argument ''connection'' has to be a scalar symbolic expression or a string.');
end
    
% If connection is a char, search for an output with the name
if( ischar(connection) )
    
    % Check if an output with the name exists
    if( ~ismember(connection,sys.outputNames))
        error('ODESCA_System:connectInput:outputNotFound',['The system has no output with the name ''',connection,'''.']);
    end
    
    % Set connection to the selected output
    symOutput = [];
    for num = 1:numel(sys.outputNames) 
        if( strcmp(connection, sys.outputNames{num}) )
           symOutput = sys.g(num); 
        end
    end
    connection = symOutput;
end

% Check it the input to be substituted is in the connection
if( ismember(inputSymbolic, symvar(connection)) )
   error('ODESCA_System:connectInput:substitutionLoop',['The symbolic variable ''',char(inputSymbolic),''' is the input which shell be substitued and therefore not allowed to be in ''connection''.']); 
end

% Check if all symbolic variables in connection are part of the system
if( ~sys.isValidSymbolic(connection))
    error('ODESCA_System:connectInput:symbolicVariablesNotInSystem','There are symbolic variables in ''connection'' which are not inputs, outputs or parameters of the system.');
end

%% Evaluation of the task
% Replace symbolic input and delete it from input list
sys.f = subs(sys.f, inputSymbolic, connection);
sys.g = subs(sys.g, inputSymbolic, connection);

% Remove the input from the system
sys.removeSymbolicInput(inputPosition);

% Call the method to signal that the parts of the equations were changed
sys.reactOnEquationsChange();

end