function [valid, maxDerivative] = isNumericValid(obj, maximumVariance)
% Checks if the steady state is numerically valid for the system
%
% SYNTAX
%   obj.isNumericValid()
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
% OPTIONAL INPUT ARGUMENTS
%   maximumVariance: The maximal difference between the values of the state
%                    equations for the given x0 and 0.
%                    E.g.: if it is set to 1e-5 the equations f must not be
%                    greater than this value with the given steady state.
%                    Otherwise the method returns false and the steady
%                    state is marked as invalid.
%
% OUTPUT ARGUMENTS
%   valid: boolean value, true if the steady state operation point is valid
%          to the system, false if it is not.
%   maxDerivative: numeric value of the maximal difference of the values
%                  the state equations have to 0.
%
% DESCRIPTION
%   This method checks if the steady state is valid for the system. It
%   returns true, if it is valid and false, if it is not. The flag
%   'numericalValid' of the steady state is set to this value too. If a
%   second output argument is demanded the maximal value the state
%   equations have for the given x0 is returned too.
%
% NOTE
%   - If the argument 'toCheck' is not given as argument, the steady state
%     operation point at the first position of the array steadyStates of
%     the system is chosen.
%   - To perform the check all parameters have to be set
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

%% Constants used in the method
% =========================================================================
% Set the default parameter for the function
% =========================================================================

% The default maximal variance when checking if the equations and
% output values are correct
default_maximalVariance = 1e-5;

% =========================================================================

%% Check of conditions
% Check if the maximal variance of the check (if given) is a scalar numeric
% value
if(nargin == 2)
    if( ~isnumeric(maximumVariance) || numel(maximumVariance) ~= 1 )
        error('ODESCA_SteadyState:isValidSteadyState:maximumVarianceNotAScalarNumericValue','The argument ''maximumVariance'' has to be a scalar numeric value.');
    end
else
    maximumVariance = default_maximalVariance;
end

%% Evaluation of the task
% Create a structure to store the result for each steady state in an array
result = struct;
result.valid = zeros(numel(obj),1);
result.maxDerivative = zeros(numel(obj),1);

% Loop for every steady statea
for numStdyst = 1:numel(obj) 
    
    stdyst = obj(numStdyst);
    sys = stdyst.system;
    
    % Check if the steady state is structural valid
    if( ~stdyst.structuralValid )
        stdyst.numericValid = false;
        result.valid(numStdyst) = false;
        result.maxDerivative(numStdyst) = NaN;
        continue;
    end
    
    % Check if the steadyState has states
    if( numel(sys.x) == 0 )
        stdyst.numericValid = true;
        result.valid(numStdyst) = false;
        result.maxDerivative(numStdyst) = NaN;
        continue;
    end
    
    % Create an array with the parameter values
    paramValues = [];
    if( ~isempty(stdyst.param) )
        paramNames = fieldnames(stdyst.param);
        for num = 1:numel(paramNames)
            paramValues = [paramValues; stdyst.param.(paramNames{num})]; %#ok<AGROW>
        end
        p = sym(fieldnames(stdyst.param));
    else
        p = [];
    end
    
    % Check what the outcome of the equations is with the given state and input
    % values and calculate the maximum value
    xdot = subs(sys.f,[sys.x; sys.u; p],[stdyst.x0; stdyst.u0; paramValues]);
    xdot = double(xdot);
    xdotMax = max(abs(xdot));
    
    % Set the boolean value to true if the maximum value of the equations is
    % below the maximum variance
    isValid = xdotMax <= maximumVariance;
    
    % Set the property valid of the steadyState to the calculated value
    stdyst.numericValid = isValid;
    
    % Store result for steady state
    result.valid(numStdyst) = isValid;
    result.maxDerivative(numStdyst) = xdotMax;

    
end % End of Loop

% Set output values
valid = result.valid;
if(nargout == 2)
   maxDerivative = result.maxDerivative; 
end

end