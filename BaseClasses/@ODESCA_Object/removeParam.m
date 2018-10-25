function removeParam(obj, parameter)
% Removes a parameter from the object
%
% SYNTAX
%   obj.removeParam(parameter)
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
%   parameter: Name of the parameter to be removed
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   This method removes the parameter with the name 'parameter' from the
%   object 'obj' in obj.p, obj.param and obj.paramUnits.
%
% NOTE
%   - This method is used by the tool and must not be used by a user
%     because it renders the system inoperable.
%
% SEE ALSO
%   equalizeParam
%
% EXAMPLE
%   There is no example provided because this method must not be used by a
%   user.
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
if( isempty(obj.param) )
    error('ODESCA_Object:removeParam:noParametersInObject','The object has no parameters.');
end

% Check if 'parameter' is a string
if( ~isa(parameter,'char') || size(parameter,1) ~= 1 )
    error('ODESCA_Object:removeParam:parameterNameIsNoString','The input argument ''parameter'' has to be a string.');
end

existingParam = fieldnames(obj.param);

% Check if a parameter with the name 'parameter' exists
if( ~ismember(parameter ,existingParam) )
    error('ODESCA_Object:removeParam:paramNameNotInObject',['The object has no parameter with the name ''',parameter,'''.']);
end

% Check if the parameter still appears in equations
if ( ~isequal(obj.f,subs(obj.f,parameter,'dummy')) )
    error('ODESCA_Object:removeParam:paramInEquations',['The parameter with the name ''',parameter,''' still appears in some of the equations.']);
end

%% Evaluation of the task
% find the position of the parameter
pos = double(strcmp(existingParam,parameter))'*(1:length(existingParam))';

% remove the entry in obj.paramUnits and obj.p
if(numel(obj.p) == 1)
    obj.paramUnits = {};
    obj.p = [];
else
    obj.paramUnits = [obj.paramUnits(1:(pos-1)); obj.paramUnits((pos+1):end)];
    obj.p = [obj.p(1:(pos-1)); obj.p((pos+1):end)];
end

% remove the entry in obj.param
obj.param = rmfield(obj.param,parameter); 

end