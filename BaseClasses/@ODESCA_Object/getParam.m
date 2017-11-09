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

function [paramValues, paramNames] = getParam(obj, useArray)
% Returns the values and names of the parameters as cell arrays
%
% SYNTAX
%   paramValues = obj.getParam();
%   [paramValues, paramNames] = obj.getParam();
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%   useArray: boolean value, if set to true, the function returns the
%             parameter values in a numeric array instead of a cell array.
%             Therefor all parameters have to be set. The default value is
%             false.
%
% OPTIONAL INPUT ARGUMENTS
%   useArray: Boolean, if true the values of the parameters are returned in
%             an array. Only possible if all parameters are set. 
%             Default value: false
%
% OUTPUT ARGUMENTS
%   paramValues: Cell array with the parameter values
%   paramNames:  Cell array with the parameter names
%
% DESCRIPTION
%   This method returns the values and the names of the parameters in cell
%   arrays with n rows and 1 column. If there are no parameters the arrays
%   are empty.
%
% NOTE
%
% SEE ALSO
%   param
%
% EXAMPLE
%

%% Condition used in the method
% =========================================================================
% Set the default arguments for the methode
% =========================================================================
useArrayChoise = false; % Option: useArray

%% Check of the conditions
if( nargin > 1 )
    % Check if the value of 'useArray' is logical scalar
    if( ~isa(useArray, 'logical') || numel(useArray) ~= 1)
        warning('ODESCA_Object:getParam:invalidValueForUseArray','The argument ''useArray'' has to be a scalar logical value. The default option was chosen.');
        
    else
       useArrayChoise = useArray;
        
       % Check if all parameters are set
       if(~obj.checkParam())
          error('ODESCA_Object:getParam:notAllParametersSet','The option ''useArray'' was set to true, but not all parameters of the object are set.');
       end
    end
end

%% Evaluation of the task
% Check if the parameters are empty
if( isempty(obj.param) )
    % Return empty arrays if there are no parameter
    paramValues = {};
    if( nargout == 2 )
        paramNames = {};
    end
else
    % Get the parameter names
    names = fieldnames(obj.param);
    
    % Fill the array with the parameter values
    paramValues = cell(numel(names),1);
    for num = 1:numel(names)
        name = names{num};
        paramValues{num} = obj.param.(name);
    end
    
    % If the output should be an array, change the format
    if( useArrayChoise )
        paramValues = [paramValues{:}]';
    end
    
    % Get the parameter names in the right order if the second ouput is
    % needed
    if( nargout == 2 )
        paramNames = reshape(names,[numel(names),1]);
    end
end

end