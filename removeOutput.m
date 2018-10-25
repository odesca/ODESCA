function removeOutput(sys, output)
% Removes the output specified by the input argument
%
% SYNTAX
%   sys.removeOutput(output)
%
% INPUT ARGUMENTS
%   sys:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
%   output: Name of the output as string or position of the output as
%             number
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   This method removes an output from the system. Either the position or
%   the name of the output has to be given to the method.
%
% NOTE
%
% SEE ALSO
%
% EXAMPLE
%   Pipe = OCLib_Pipe('MyPipe');
%   Pipe.setConstructionParam('Nodes',2);
%   PipeSys = ODESCA_System('MySystem',Pipe);
%   outputs_before = PipeSys.outputNames
%   PipeSys.removeOutput(2); % or PipeSys.removeOutput('MyPipe_mDotOut');
%   outputs_after = PipeSys.outputNames
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
% Check if there is more than one input in the system
if( numel(sys.outputNames) == 1 )
    error('ODESCA_System:removeOutputs:cannotRemoveLastOutput','It is not possible to remove the last output of a system because a system has to have at least one output at any time.');
end

% Check if the argument 'toRemove' has one of the two valid types
if( isnumeric(output) && numel(output)==1 )
    % If the input is number ...
    
    %Check if the number is a positiv value unequal to NaN or Inf
    if( output <= 0 || isnan(output) || isinf(output) || mod(output,1) ~= 0 )
        error('ODESCA_System:removeOutputs:invalidOutputNumber','The position given as input is not a positiv interger value greater than zero.');
    end
    
    %Check if the system has the number of outputs.
    if( numel(sys.outputNames) < output )
        error('ODESCA_System:removeOutputs:outputNumberExceedsIndex','The position given as input exceeds the number of outputs');
    end
    
    % Save the position
    pos = output;
elseif( ischar(output) && size(output,1)==1 )
    % If the input is a string ...
    
    % Check if the system has an output with the name
    if( ~ismember(output, sys.outputNames) )
       error('ODESCA_System:removeOutputs:outputNotFound',['The system has no output with the name ''',output,'''']);
    end
    
    % Find the position of the output
    pos = -1;
    for num = 1:numel(sys.outputNames)
        if( strcmp(output,sys.outputNames{num}) )
            pos = num;
        end
    end
else
    error('ODESCA_System:removeOutputs:invalidInputArgument','The input argument ''toRemove'' has to be a scalar numeric value or string.');
end

%% Evaluation of the task
% If all checks are passed, remove the output
if( numel(sys.outputNames) == 1 )
    sys.g = [];
    sys.outputNames = {};
    sys.outputUnits = {};
else
    sys.outputNames = [sys.outputNames(1:(pos-1)); sys.outputNames((pos+1):end)];
    sys.outputUnits = [sys.outputUnits(1:(pos-1)); sys.outputUnits((pos+1):end)];
    sys.g = [sys.g(1:(pos-1)); sys.g((pos+1):end)];
end

% Call the method to signal that the parts of the equations were changed
sys.reactOnEquationsChange();

end