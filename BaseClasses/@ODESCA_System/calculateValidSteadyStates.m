function calculateValidSteadyStates(sys)
% Calculates all valid steady states and links them to the system
%
% SYNTAX
%   sys.calculateValidSteadyStates()
%
% INPUT ARGUMENTS
%   sys:    Instance of the object where the method was
%           called. This parameter is given automatically. 
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   calculates all possible steady states of a system
% 
% NOTE
%
% SEE ALSO
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
%     PipeSys.calculateValidSteadyStates();
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

% Check if the system has states
if( isempty(sys.x))
   error('ODESCA_System:calculateValidSteadyStates:noStates','The system has no states.');
end

% Check if all parameters of the systems are set to values
if( ~sys.checkParam() )
    error('ODESCA_System:calculateValidSteadyStates:notAllParametersSet','To find steady states, all parameters have to be set.');
end

%% Evaluation of the task
if ~isempty(sys.u)
    u_steady = sym('u_s',[length(sys.u),1]);
    eqns = subs(sys.f,sys.u,u_steady) == 0;
else
    eqns = sys.f == 0;
end

if ~isempty(sys.p)
    % get parameter
    temp = sys.getParam();
    paramVal = sym('p',size(temp));
    for num = 1:numel(temp)
        paramVal(num) = temp{num};
    end
    % set parameter
    eqns = subs(eqns,sys.p,paramVal);
end

sys.validSteadyStates = solve(eqns,sys.x,'ReturnConditions',true);

end