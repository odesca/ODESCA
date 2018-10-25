function bilin = bilinearize(obj)
% Calculate the bilinear approximation of the system in the steady state
%
% SYNTAX
%   bilin = obj.bilinearize();
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%   bilin:    Array with the created bilinear approximations
%
% DESCRIPTION
%   This method calculates the bilinearizations of all steady states in a
%   list. Steady states which are structural invalid can not be 
%   bilinearized.
%
% NOTE
%
% SEE ALSO
%   bilinear
%
% EXAMPLE
%     Pipe = OCLib_Pipe('MyPipe');
%     Pipe.setConstructionParam('Nodes',2);
%     Pipe.setParam('cPipe',500);
%     Pipe.setParam('mPipe',0.5);
%     Pipe.setParam('VPipe',0.001);
%     Pipe.setParam('RhoFluid', 998);
%     Pipe.setParam('cFluid',4182);
%     PipeSys = ODESCA_System('MySystem',Pipe);
%     ss1 = PipeSys.createSteadyState([40; 40],[40; 0.1],'ss1');
%     bilin = PipeSys.steadyStates.bilinearize
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

% Call the method in a loop if it is called for multiple instances
approxs = [];
for numSS = 1:numel(obj)
    steadyState = obj(numSS);
    
    %% Check of the conditions
    % Check if the steady state belongs to a system
    if(~steadyState.structuralValid)
        warning('ODESCA_SteadyState:bilinearize:structuralInvalid',['The steady state with the name ''',steadyState.name,''' is structural invalid. Therefore the bilinearization can not be calculated.']);
        continue; % Pass to next loop
    end
    
    % Check if the given steady state is valid
    if(~steadyState.numericValid)
        warning('ODESCA_SteadyState:bilinearize:steadyStateInvalid',['The steady state ''',steadyState.name,''' is numerical invalid. This can lead to numerical problems.']);
    end
    
    %% Evaluation of the task
    % Check if the steady state was already bilinearized
    index = -1;
    numApprox = numel(steadyState.approximations);
    for num = 1:numApprox
        if( isa(steadyState.approximations(num),'ODESCA_Bilinear') )
            index = num;
        end
    end
    if(index ~= -1)
        if( nargout == 1)
            approxs = [approxs,steadyState.approximations(index)]; %#ok<AGROW>
        end
        continue; %TODO different reaction if bilinear approximation exists
    end
    
    % Get the symbolic linearization
    sys = steadyState.system;
    [symA,symB,symC,symD,symG,symN,symM] = sys.symBilinearize();
    
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
    
    % Substitute the values in the matrix for input-input bilinearity.
    if( ~isempty(symG) )
        G = subs(symG,toSubstitute,substitution);
        G = double(vpa(G));
    else
        G = [];
    end
    
    % Substitute the values in the matrix for input-state bilinearity.
    if( ~isempty(symN) )
        N = subs(symN,toSubstitute,substitution);
        N = double(vpa(N));
    else
        N = [];
    end
    
    % Substitute the values in the matrix for state-state bilinearity.
    if( ~isempty(symM) )
        M = subs(symM,toSubstitute,substitution);
        M = double(vpa(M));
    else
        M = [];
    end
    
    % Create a new instance of the bilinear approximation class and add it 
    % to the steady state
    approx = ODESCA_Bilinear(steadyState, A,B,C,D,G,N,M);
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
    bilin = approxs;
end

end