function setAllParamAsInput(obj)
% Sets all parameters as inputs of the object.
%
% SYNTAX
%   obj.setAllParamAsInput(paramName)
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   This function sets all parameters of a ODESCA_Object as
%   inputs.
%
% NOTE
%   - If the ODE does not have any parameters nothing will happen.
%
% SEE ALSO
%   setParamAsInput(paramName)
%
% EXAMPLE
%   Pipe = OCLib_Pipe('MyPipe');
%   Pipe.setConstructionParam('Nodes',2);
%   parameters_before = Pipe.param
%   inputs_before = Pipe.inputNames
%   Pipe.setAllParamAsInput;
%   parameters_after = Pipe.param
%   inputs_after = Pipe.inputNames
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
% Check if the ODE has parameters
if( ~isempty(obj.param) )
    paramNames = fieldnames(obj.param);
    for num = 1:numel(paramNames)
        obj.setParamAsInput(paramNames{num});
    end
end

end