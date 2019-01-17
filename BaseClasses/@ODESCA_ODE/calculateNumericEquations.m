function [f,g] = calculateNumericEquations(obj, partial)
% Calculates the numeric equations if all parameters are set.
%
% SYNTAX
%   [f,g] = obj.calculateNumericEquations()
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
% OPTIONAL INPUT ARGUMENTS
%   partial: boolean value, if true, the equations are filled with all set
%            parameters and the unset parameters are left symbolic. Default
%            is false.
%
% OUTPUT ARGUMENTS
%   f: Numeric equations for the state changes
%   g: Numeric equations for the outputs
%
% DESCRIPTION
%   This function calculates the numeric equations f and g with
%   the parameters substituted with their numeric value and returns them.
%   If the input argument partial is true, the function returns the
%   equations even if not all parameters are set. The unset parameters
%   remain as symbolic expressions.
%
% NOTE
%
% SEE ALSO
%   obj.f
%   obj.g
%   obj.checkParam()
%
% EXAMPLE
%     Pipe = OCLib_Pipe('MyPipe');
%     Pipe.setConstructionParam('Nodes',2);
%     [f_sym,g_sym] = Pipe.calculateNumericEquations(true)
%     Pipe.setParam('cPipe',500);
%     Pipe.setParam('mPipe',0.5);
%     Pipe.setParam('VPipe',0.001);
%     Pipe.setParam('RhoFluid', 998);
%     Pipe.setParam('cFluid',4182);
%     [f_num,g_num] = Pipe.calculateNumericEquations(false)
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

%% Condition used in the method
% =========================================================================
% Set the default arguments for the methode
% =========================================================================
if(nargin == 1)
    partial = false;
end

%% Check of the conditions
if(~partial)
    % Check if all parameters are set
    if( ~obj.checkParam() )
        error('ODESCA_ODE:calculateNumericEquations:notAllParametersSet','The numeric equations can not be calculated because not all parameters have been set.');
    end
end

%% Evaluation of the task
% If no parameters exist, they don't have to be substituted
if( isempty(obj.param) )
    f = obj.f;
    g = obj.g;
else
    % Get the symbolic parameters to be replaced and the values of the
    % parameters which replace them
    p = obj.p;
    [paramValues, ~] = obj.getParam();
    
    % Find the array elements where parameters are set if partial is true
    if(partial)
        indexSet = ~cellfun(@isempty,paramValues);
        p = p(indexSet);
        paramValues = paramValues(indexSet);
    end
    
    % Substitute all symbolic parameters with their values
    if( ~isempty(obj.f) )
        f = subs(obj.f, p, paramValues);
    else
        f = [];
    end
    if( ~isempty(obj.g) )
        g = subs(obj.g, p, paramValues);
    else
        g = [];
    end
end

end