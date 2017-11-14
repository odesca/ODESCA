function allParamSet = checkParam(obj)
% Checks if all parameters are set to a value.
%
% SYNTAX
%   allParamSet = obj.checkParam()
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%   allParametersSet: true, if all parameters are set to a value. false
%                     otherwise
%
% DESCRIPTION
%   This method checks if all parameters are set to a numeric value. 
%   If this condition is fulfilled the method returns true. 
%   If one or more parameters are empty, the method returns false. 
%   It also returns true if there aren't any parameters
%
% NOTE
%   - If there are no parameters the method returns true.
%
% SEE ALSO
%   obj.param
%   obj.setParam(paramName, value)
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
% If no empty parameter is found the return value stays true.
allParamSet = true;

% Check if there are unset parameters
if( ~isempty(obj.param) )
    paramValue = obj.getParam();
    for num = 1:numel(paramValue)
        if( isempty( paramValue{num} ) )
            allParamSet = false;
            return;
        end
    end
end

end