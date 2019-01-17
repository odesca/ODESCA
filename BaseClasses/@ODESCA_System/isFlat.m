function fl = isFlat(sys)
% Checks if the system is flat
%
% SYNTAX
%   fl = sys.isFlat()
%
% INPUT ARGUMENTS
%   sys:    Instance of the system where the method was
%           called. This parameter is given automatically.
%
% OUTPUT ARGUMENTS
%   fl:     boolean value, true if flat, false otherwise
%
% DESCRIPTION
%   This method checks if the system is flat. It returns a logical variable 
%   where true indicates that the system output is flat. If
%   the algorithm does not find an answer after some time, it determines
%   the system as non flat.
%
% NOTE
%
% SEE ALSO
%
% EXAMPLE
%   Pipe = OCLib_Pipe('MyPipe');
%   Pipe.setConstructionParam('Nodes',2);
%   Pipe.setParam('cPipe',500);
%   Pipe.setParam('mPipe',0.5);
%   Pipe.setParam('VPipe',0.001);
%   Pipe.setParam('RhoFluid', 998);
%   Pipe.setParam('cFluid',4182);
%   PipeSys = ODESCA_System('MySystem',Pipe);
%   fl = PipeSys.isFlat();
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
fl = false;

% calculate y,ydot,yddot...
syms y;
eq1 = y == sys.g(1);

% substitute y,ydot,yddot in sys.x
% if 

% 
    
end