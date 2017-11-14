function lin = linearize(obj)
% Calculate the linear approximation of the system in the steady state
%
% SYNTAX
%   obj.linearize();
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%   lin:    Array with the created linear approximations
%
% DESCRIPTION
%   This method calculates the linearizations of all steady states in a
%   list. Steady states which are structural invalid can not be linearized.
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

% Check if the control system toolbox is available
try
    var = ss(); %#ok<NASGU>
catch err
    error('ODESCA_SteadyState:linearize:licenseNotAvailable','The license for the control system toolbox, which is needed for the linearization, is not available.\n\nLicense Error:\n##############################\n\n%s',err.message);
end

% Call the method in a loop if it is called for multiple instances
approxs = [];
for numSS = 1:numel(obj)
    steadyState = obj(numSS);
    
    %% Check of the conditions
    % Check if the steady state belongs to a system
    if(~steadyState.structuralValid)
        warning('ODESCA_SteadyState:linearize:structuralInvalid',['The steady state with the name ''',steadyState.name,''' is structural invalid. Therefore the linearization can not be calculated.']);
        continue; % Pass to next loop
    end
    
    % Check if the given steady state is valid
    if(~steadyState.numericValid)
        warning('ODESCA_SteadyState:linearize:steadyStateInvalid',['The steady state ''',steadyState.name,''' is numerical invalid. This can lead to numerical problems.']);
    end
    
    %% Evaluation of the task
    % Check if the steady state was already linearized
    index = -1;
    numApprox = numel(steadyState.approximations);
    for num = 1:numApprox
        if( isa(steadyState.approximations(num),'ODESCA_Linear') )
            index = num;
        end
    end
    if(index ~= -1)
        if( nargout == 1)
            approxs = [approxs,steadyState.approximations(index)]; %#ok<AGROW>
        end
        continue; %TODO different reaction if linear approximation exists
    end
    
    % Get the symbolic linearization
    sys = steadyState.system;
    [symA,symB,symC,symD] = sys.symLinearize();
    
    % Get the values for the steady states and the parameters
    x0 = steadyState.x0;
    u0 = steadyState.u0;
    if( ~isempty(steadyState.param) )
        paramName = fieldnames(steadyState.param);
        paramValue = sym(zeros(numel(paramName),1));
        for num = 1:numel(paramName)
            paramValue(num) = steadyState.param.(paramName{num});
        end
        p = sym(fieldnames(steadyState.param));
    else
        paramValue = [];
        p = [];
    end
    toSubstitute = [sys.x; sys.u; p];
    substitution = [x0; u0; paramValue];
    
    % Substitute the values in the system matrix
    if( ~isempty(symA) )
        A = subs(symA,toSubstitute,substitution);
        A = double(vpa(A));
    else
        A = [];
    end

    % Substitute the values in the input matrix
    if( ~isempty(symB) )
        B = subs(symB,toSubstitute,substitution);
        B = double(vpa(B));
    else
        B = [];
    end

    % Substitute the values in the output matrix
    if( ~isempty(symC) )
        C = subs(symC,toSubstitute,substitution);
        C = double(vpa(C));
    else
        C = [];
    end
    
    % Substitute the values in the feedthrough matrix
    if( ~isempty(symD) )
        D = subs(symD,toSubstitute,substitution);
        D = double(vpa(D));
    else
        D = [];
    end
    
    % Create a new instance of the linear approximation class and add it to the
    % steady state
    approx = ODESCA_Linear(steadyState, A,B,C,D);
    if(numApprox == 0)
        steadyState.approximations = approx;
    else
        steadyState.approximations(numApprox + 1) = approx;
    end
    
    if( nargout == 1)
        approxs = [approxs,approx]; %#ok<AGROW>
    end
% End of the method loop
end

% Check if an output argument is asked for
if( nargout == 1)
    lin = approxs;
end

end