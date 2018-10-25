function addConstructionParameter(obj, parameterNames)
% Adds construction parameter to the caller instance.
%
% SYNTAX
%   obj.addConstructionParameter(parameterNames)
%
% INPUT ARGUMENTS
%   obj: Instance of the object where the method was called.
%        This parameter is given automatically.
%
%   parameterNames: Cell array with the names of the parameters
%                   as string. Can be empty if no parameters should be
%                   added.
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   This method creates the structure for the construction
%   parameters.
%
% NOTE
%   - This method should only be called once. It will trow an
%     error if the construction parameters have been created
%     already
%   - This method is meant to be called in the constructor of a subclass of 
%     ODESCA_Component.
%
% SEE ALSO
%   constructionParam
%
% EXAMPLE
%    An area is segmented in x- and y-direction. Each segment (node)
%    contains one state. So the number of states depends on the number of
%    nodes in each direction. Hence the number of nodes is a parameter that 
%    has to be known before the construction of the component.
%
%    --- inside the constructor of a subclass of ODESCA_Component ------
%    constructionParamNames = {'Nodes_x', 'Nodes_y'};
%    obj.addConstructionParameter(constructionParamNames);
%    -------------------------------------------------------------------
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
% Check if there are construction parameters which should be
% added. It this is not the case, exit the method without any action
if( isempty(parameterNames) )
    return;
end

% Check if the input argument is a cell array.
if( ~iscell(parameterNames) )
    error('ODESCA_Object:addParameters:inputNotACellArray','The input argument ''parameterNames'' has to be a cell array.');
end

% Get the construction parameter names in the right order
temp = {};
paramRows = size(parameterNames,1);
for row = 1:paramRows
    temp = [temp; parameterNames(row,:)'];  %#ok<AGROW>
end
parameterNames = temp;

% Check if all elements of 'parameterNames' are valid variable names
for num = 1:numel(parameterNames)
    paramName = parameterNames{num,1};
    if( ~isvarname(paramName) )
        error('ODESCA_Object:addParameters:parameterNameNotValid','The names for the parameters has to match the naming conventions of MATLAB variables.');
    end
end

% Check if there were already construction parameters.
if( ~isempty(obj.constructionParam) )
    error('ODESCA_Object:addParameters:constructionParameterAlreadySet','The construction parameters can not be set twice.');
end

%% Evaluation of the task
% Create the sturcture with the construction parameters
obj.constructionParam = struct;
for num = 1:numel(parameterNames)
    toAdd = parameterNames{num,1};
    obj.constructionParam.(toAdd) = [];
end

end