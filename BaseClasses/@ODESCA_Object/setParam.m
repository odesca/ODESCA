function setParam(obj, paramName, value)
% Sets the value of a parameter
%
% SYNTAX
%   obj.setParam(paramName, value)
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
%   paramName: Name of the parameter to be set.
%
%   value: Value the parameter should be set to.
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   Sets the parameter specified by the string 'paramName' to
%   the numeric value or to empty. If the parameter was set as input it is
%   removed from the list of parameters as input.
%
% NOTE
%   - Setting a parameter which was set as input removes the parameter from
%     the input list
%
% SEE ALSO
%   param
%   paramAsInput
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

%% Check of the conditions
% Check if 'paramName' is a string
if( ~isa(paramName,'char') || size(paramName,1) ~= 1 )
    error('ODESCA_Object:setParam:parameterNameIsNoString','The input argument ''paramName'' has to be a string.');
end

% Check if 'value' is either empty or scalar and a numeric value
if( ~isempty(value) && ~(numel(value)==1 && isnumeric(value))  ) 
    error('ODESCA_Object:setParam:valueIsNoScalarNumeric','The input argument ''value'' has to be a scalar numeric value or empty.');
end

% Check if the object has parameters
if( isempty(obj.param) )
    error('ODESCA_Object:setParam:noParametersFound','This object has no parameters added to it.');
end

existingParam = fieldnames(obj.param);

% Check if the parameter exists
if( sum(strcmp(existingParam,paramName)) == 0 )
    error('ODESCA_Object:setParam:parameterDoseNotExist',['The parameter ''',paramName,''' dose not exist in this object.'])
end

%% Evaluation of the task
% Set the parameter
if( isempty(value) )
    obj.param.(paramName) = [];
else
    obj.param.(paramName) = value;
end

end