function bilin = bilinear(obj, index)
% Returns the instances of the ODESCA_Bilinear class
%
% SYNTAX
%   bilin = obj.bilinear()
%   bilin = obj.bilinear(index)
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
% OPTIONAL INPUT ARGUMENTS
%   index:  Index like in array which gets certain bilinearizations. E.g.:
%           index = 3 get the bilinearization of the third steady state and
%           index = 1:3 gets the first three bilinearizations
%
% OUTPUT ARGUMENTS
%   bilin:    Array with the bilinear approximations.
%
% DESCRIPTION
%    This method returns the instances of the ODESCA_Bilinear class 
%    attached to an array of ODESCA_SteadyStates if they where calculated. 
%    The optional input argument index can be used to adress the returned 
%    bilinearizations like a normal array.
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

%% Evaluation of the task
arrBilin = [];
numNoBilin = 0;

% Choose from which steady states the linearizations should be taken
if( nargin == 1 )
    stdysts = obj;
else
    % Check if the index is valid for the object array
    numStdysts = numel(obj);
    if( any(~isnumeric(index) | mod(index,1) ~= 0 | index < 1 | index > numStdysts | isinf(index) | isnan(index)) )
        error('ODESCA_SteadyState:bilinear:invalidIndex','The input argument ''index'' has to be a valid index for the array of steady states.');
    end    
    stdysts = obj(index);
end

for numSS = 1:numel(stdysts)
    steadyState = stdysts(numSS);
    bilin = [];
    % Search for an instance of the class ODESCA_Bilinear in the
    % approximations of the steady state
    for numApprox = 1:numel(steadyState.approximations)
        if(isa(steadyState.approximations(numApprox),'ODESCA_Bilinear'))
            bilin = steadyState.approximations(numApprox);
        end
    end
    
    % Add the instance of the bilinear approximation to the list to be
    % returned
    if(~isempty(bilin))
        if(isempty(arrBilin))
            arrBilin = bilin;
        else
            arrBilin = [arrBilin; bilin];  %#ok<AGROW>
        end
    else
        numNoBilin = numNoBilin + 1;
    end
end
% Display a warning when there are steady states without a bilinearization
if(numNoBilin ~= 0)
    warning('ODESCA_SteadyState:bilinear:notAllBilinearized',['There are steady states where no bilinearization was found. Number: ',num2str(numNoBilin)]);
end

% Set the return value
bilin = arrBilin;

end