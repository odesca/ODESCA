function removeSteadyState(sys, toRemove)
% Removes a steady state and its link to the system
%
% SYNTAX
%   sys.removeSteadyState(toRemove)
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%   toRemove: Name or position of the steady state to be removed.
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   This method removes a steady state from the system. The argument
%   'toRemove' can either be a string with the name of the steady state or
%   the position of the steady state in the list of steady states of the
%   system. The method furthermore can be called without any input
%   arguments. In this case, all steady states which are structural invalid
%   get removed.
%
% NOTE
%   - If the method is called without any input argument, all structural
%     invalid steady states are removed 
%
% SEE ALSO
%   steadyStates
%
% EXAMPLE
%   sys.removeSteadyState('Name1');
%   sys.removeSteadyState(1);
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
% Check if the system has steady states
if( isempty(sys.steadyStates) )
    warning('ODESCA_System:removeSteadyState','The system has no steady states to be removed.');
    return;
end

% If no input argument is given, remove all structural invalid steady
% states
if( nargin < 2 )
    % Get a list of all structural invalid steadyStates
    invalidNames = {sys.steadyStates(~[sys.steadyStates.structuralValid]').name}'; 
    invalidNum = numel(invalidNames);
    for numName = 1:invalidNum
       sys.removeSteadyState(invalidNames{numName}); % Recursion
    end
    return;
end

% Position of the steady state
pos = -1;
% Check if toRemove is a string or a number
if( ischar(toRemove) && size(toRemove,1) == 1 )
    % Find the position of the steady state
    if( ~isempty(sys.steadyStates) )
        for num = 1:numel(sys.steadyStates)
            sso = sys.steadyStates(num);
            if( strcmp(toRemove,sso.name) )
                pos = num;
            end
        end
    end
elseif( isnumeric(toRemove) && numel(toRemove) == 1 && mod(toRemove,1) == 0)
    % Check if a steady state with the index exists
    if( ~isempty(sys.steadyStates) && toRemove > 0 && toRemove <= numel(sys.steadyStates) )
        pos = toRemove;
    end
else
    error('ODESCA_System:removeSteadyState:argumentInvalid','The argument ''toRemove'' has to be a string or an integer number.');
end

% Check if the steady state was found
if( pos == -1 )
    error('ODESCA_System:removeSteadyState:steadyStateNotFound','The steady state was not found.');
end

%% Evaluation of the task
% Remove the link from the steady state and set it structural invalid
sys.steadyStates(pos).delete();

end