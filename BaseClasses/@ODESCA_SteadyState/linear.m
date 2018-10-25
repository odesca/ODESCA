function lin = linear(obj, index)
% Returns the instances of the ODESCA_Linear class
%
% SYNTAX
%   lin = obj.linear()
%   lin = obj.linear(index)
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
% OPTIONAL INPUT ARGUMENTS
%   index:  Index like in array which gets certain linearizations. E.g.:
%           index = 3 get the linearization of the third steady state and
%           index = 1:3 gets the first three linearizations
%
% OUTPUT ARGUMENTS
%   lin:    Array with the linear approximations.
%
% DESCRIPTION
%    This method returns the instances of the ODESCA_Linear class attached
%    to an array of ODESCA_SteadyStates if they where calculated. The
%    optional input argument index can be used to adress the returned
%    linearizations like a normal array.
%
% NOTE
%
% SEE ALSO
%   linearize
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
%     ss2 = PipeSys.createSteadyState([40; 40],[40; 0.2],'ss2');
%     ss3 = PipeSys.createSteadyState([40; 40],[40; 0.25],'ss3');
%     PipeSys.steadyStates.linearize();
%     allLinearizations = PipeSys.steadyStates.linear(1:3)
%     secondLinearization = PipeSys.steadyStates.linear(2)
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

%% Evaluation of the task
arrLin = [];
numNoLin = 0;

% Choose from which steady states the linearizations should be taken
if( nargin == 1 )
    stdysts = obj;
else
    % Check if the index is valid for the object array
    numStdysts = numel(obj);
    if( any(~isnumeric(index) | mod(index,1) ~= 0 | index < 1 | index > numStdysts | isinf(index) | isnan(index)) )
        error('ODESCA_SteadyState:linear:invalidIndex','The input argument ''index'' has to be a valid index for the array of steady states.');
    end    
    stdysts = obj(index);
end

for numSS = 1:numel(stdysts)
    steadyState = stdysts(numSS);
    lin = [];
    % Search for an instance of the class ODESCA_Linear in the
    % approximations of the steady state
    for numApprox = 1:numel(steadyState.approximations)
        if(isa(steadyState.approximations(numApprox),'ODESCA_Linear'))
            lin = steadyState.approximations(numApprox);
        end
    end
    
    % Add the instance of the linear approximation to the list to be
    % returned
    if(~isempty(lin))
        if(isempty(arrLin))
            arrLin = lin;
        else
            arrLin = [arrLin; lin];  %#ok<AGROW>
        end
    else
        numNoLin = numNoLin + 1;
    end
end
% Display a warning when there are steady states without a linearization
if(numNoLin ~= 0)
    warning('ODESCA_SteadyState:linear:notAllLinearized',['There are steady states where no linearization was found. Number: ',num2str(numNoLin)]);
end

% Set the return value
lin = arrLin;

end