function stable = isAsymptoticStable(obj)
% Checks if the linearizations are asymptotically stable
%
% SYNTAX
%   stable = obj.isAsymptoticStable()
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%   stable: boolean array, true for every linearization which is 
%           asymptotically stable, false otherwise.
%
% DESCRIPTION
%   This method checks if the linearizations are asymptotically stable. In
%   this case the corresponding value in the output array will be true. 
%   If a linearization is unstable or marginally stable the value will be 
%   false. 
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
stable = boolean(zeros(size(obj)));
for numLin = 1:numel(obj)
    lin = obj(numLin);
    % Get the eigenvalues of the system matrix
    eigenvalues = eig(lin.A);
    
    % Check if all eigenvalues have strict negative real parts
    if( real(eigenvalues) < 0 )
        stable(numLin) = true;
    end
    
    % If the linear system is a static gain, assume it is stable
    if( isempty(lin.A) )
       stable(numLin) = true; 
    end
end

end