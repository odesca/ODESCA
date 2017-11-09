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

function allParamSet = checkConstructionParam(obj)
% Checks if all construction parameters are set.
%
% SYNTAX
%   allParamSet = obj.checkConstructionParam()
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%   allParamSet: True, if all construction parameters are set.
%                False otherwise.
%
% DESCRIPTION
%   This method checks if all construction parameters are set.
%   If this condition is fulfilled the method returns true. If
%   one or more construction parameters are empty, the method
%   returns false. It also returns true if there aren't any
%   construction parameters.
%
% NOTE
%   - If there are no parameters the method returns true.
%
% SEE ALSO
%   constructionParam
%
% EXAMPLE
%

%% Evaluation of the task
% If no empty parameter is found the return value stayes true.
allParamSet = true;

% Check if there are unset parameters
if( ~isempty(obj.constructionParam) )
    existingParam = fieldnames(obj.constructionParam);
    for num = 1:numel(existingParam)
        
        paramName = existingParam{num,1};
        if( isempty( obj.constructionParam.(paramName) ) )
            allParamSet = false;
        end
    end
end

end