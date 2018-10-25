function setConstructionParam(obj, paramName, value)
% Sets a construction parameter to a numeric value.
%
% SYNTAX
%   obj.setConstructionParam(paramName, value)
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
%   paramName: Name of the construction parameter to be changed
%              as string.
%
%   value: value which the construction parameter should be set to.
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   Sets the construction parameter specified by the string
%   'paramName' to the numeric value in 'value'. If the construction
%   parameter is set the flag equationsCalculated is set to false and the 
%   component is reinitialized so all changes made to the component are 
%   lost!
%
% NOTE
%   - WARNING:  Set a construction parameter on a component where the 
%               equations have been already calculated leads to a complete 
%               reinitialization of the component which means every changes
%               made to the component are lost. 
%
% SEE ALSO
%   constructionParam
%   FLAG_EquationsCalculated
%
% EXAMPLE
%   Pipe = OCLib_Pipe('MyPipe');
%   Pipe.setConstructionParam('Nodes',2);
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
% Check if the object has parameters
if( isempty(obj.constructionParam) )
    error('ODESCA_Component:setParam:noConstructionParametersExist','This object has no construction parameters added to it.');
end

% Check if 'paramName' is a string
if( ~isa(paramName,'char') || size(paramName,1) ~= 1 )
    error('ODESCA_Component:setParam:parameterNameIsNoString','The input argument ''paramName'' has to be a string.');
end

% Check if 'value' is a scalar numeric value
if( ~isnumeric(value) || numel(value) ~= 1 )
    error('ODESCA_Component:setParam:valueIsNoScalarNumeric','The input argument ''value'' has to be a scalar numeric value.');
end

existingParam = fieldnames(obj.constructionParam);

% Check if the parameter exists
if( ~ismember(paramName,existingParam) )
    error('ODESCA_Component:setParam:constructionParameterDoesNotExist',['The construction parameter ''',paramName,''' does not exist in this object.'])
end

%% Evaluation of the task
% Set the construction parameter and reset the equations and the flag
obj.constructionParam.(paramName) = value;
obj.FLAG_EquationsCalculated = false;
obj.initializeObject();

% If all construction parameters are set, calculate the equations
if(obj.checkConstructionParam())
    obj.tryCalculateEquations();
end

end