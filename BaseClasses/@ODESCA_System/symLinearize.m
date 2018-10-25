function [A, B, C, D] = symLinearize(sys)
% Linearizes the equations symbolically
%
% SYNTAX
%   [A, B, C, D] = sys.symLinearize()
%
% INPUT ARGUMENTS
%   obj:    Instance of the system where the method was
%           called. This parameter is given automatically.
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%
%   A: Symbolic system matrix.
%
%   B: Symbolic input matrix.
%
%   C: Symbolic output matrix.
%
%   D: Symbolic feedthrough matrix.
%
% DESCRIPTION
%   This method returns the linearized matrices. It is important to notice
%   that in all matrices the symbolic variables x and u which are left
%   should be interpreted as the particular x0 and u0 values of a operation
%   point.
%
% NOTE
%   - In all matrices the symbolic variables x and u which are left
%   should be interpreted as the particular x0 and u0 values of a operation
%   point.
%
% SEE ALSO
%
% EXAMPLE
%   Pipe = OCLib_Pipe('MyPipe');
%   Pipe.setConstructionParam('Nodes',2);
%   PipeSys = ODESCA_System('MySystem',Pipe);
%   [A, B, C, D] = PipeSys.symLinearize
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
if( ~isempty(sys.f) )
    A = jacobian(sys.f, sys.x);
    B = jacobian(sys.f, sys.u);
else
    A = [];
    B = [];
end
if( ~isempty(sys.g) )
    C = jacobian(sys.g, sys.x);
    D = jacobian(sys.g, sys.u);
else
    C = [];
    D = [];
end

end