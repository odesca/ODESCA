function equalizeParam(sys, paramKeep, paramReplace)
% Equalizes parameter values in the same units
%
% SYNTAX
%   sys.equalizeParam(paramKeep, paramReplace)
%
% INPUT ARGUMENTS
%   sys:    Instance of the system where the method was
%           called. This parameter is given automatically.
%
%   paramKeep:      Name of the parameter to be kept.
%   paramReplace:   Cell of Names of the parameters to be replaced by 
%                   paramKeep.
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   Equalizes parameter values in the same units.
%   The parameters specified by the string 'paramReplace' will be replaced
%   by the parameter specified by the string 'paramKeep' in the equations
%   and 'paramReplace' will be deleted from the parameter list.
%   This function should be used when two parameters are identical in a 
%   system, not only to prevent mistakes in parameter settings but also for
%   speed.
%
% NOTE
%   - You can only equalize parameters in the same units.
%   - You can only equalize parameters that are not set as inputs before.
%
% SEE ALSO
%   param
%
% EXAMPLE
%   Pipe = OCLib_Pipe('MyPipe');
%   Pipe.setConstructionParam('Nodes',2);
%   Pipe.setParam('cPipe',500);
%   Pipe.setParam('cFluid',4182);
%   PipeSys = ODESCA_System('MySystem',Pipe);
%   param_before = PipeSys.param
%   PipeSys.equalizeParam('MyPipe_cPipe',{'MyPipe_cFluid'});
%   param_after = PipeSys.param
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
% Check if 'paramKeep' is a string and 'paramReplace' is a cell
if( ~isa(paramKeep,'char') || size(paramKeep,1) ~= 1 )
    error('ODESCA_System:equalizeParam:parameterNameIsNoString','The input argument ''paramKeep'' has to be a string.');
end
if( ~isa(paramReplace,'cell') )
    error('ODESCA_System:equalizeParam:parameterNameIsNoCell','The input argument ''paramReplace'' has to be a cell of strings.');
end

% Check if the 'paramReplace' cell only contains strings
for num=1:length(paramReplace)
    if ( ~isa(paramReplace{num},'char') )
        error('ODESCA_System:equalizeParam:parameterNameIsNoString','The input argument ''paramReplace'' has to be a cell of strings.');
    end
end

existingParam = fieldnames(sys.param);

% Check if the system has at least the numbers of parameters accessed
if( length(existingParam) < 1 + length(paramReplace) )
    error('ODESCA_System:equalizeParam:notEnoughParametersFound','This system has less parameters than accessed.');
end

% Check if the parameter exists
if( sum(strcmp(existingParam,paramKeep)) == 0 )
    error('ODESCA_System:equalizeParam:parameterDoesNotExist',['The parameter ''',paramKeep,''' does not exist in this system.'])
end
for num=1:length(paramReplace)
    if( sum(strcmp(existingParam,paramReplace{num})) == 0 )
        error('ODESCA_System:equalizeParam:parameterDoesNotExist',['The parameter ''',paramReplace{num},''' does not exist in this System.'])
    end
end

% Check if 'paramKeep' equals one of the parameters in 'paramReplace'
if( sum(contains(paramReplace,paramKeep)) > 0 )
    error('ODESCA_System:equalizeParam:replaceParamAndKeepParamEqual',['One of the parameters in ''paramReplace'' equals ''',paramKeep,'''.']);
end

% Check if the units are equal
for num=1:length(paramReplace)
    if ~( strcmp(sys.paramUnits(strcmp(existingParam,paramKeep)),sys.paramUnits(strcmp(existingParam,paramReplace{num}))) )
        error('ODESCA_System:equalizeParam:unitsNotEqual','The units of the parameters to be equalized have to be equal.')
    end
end

%% Evaluation of the task

for num=1:length(paramReplace)
    % substitute the parameter inside the equations (f,g)
    sys.f = subs(sys.f,paramReplace{num},paramKeep);
    sys.g = subs(sys.g,paramReplace{num},paramKeep);
    % remove the parameter
    sys.removeParam(paramReplace{num});
end

% Call the method to signal that the parts of the equations were changed
sys.reactOnEquationsChange();

end