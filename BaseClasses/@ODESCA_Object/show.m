function show(obj,varargin)
% Shows the equations, states, inputs, outputs and parameters of the object
%
% SYNTAX
%   obj.show()
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
% OPTIONAL INPUT ARGUMENTS
%   varargin{1}: number of digits of numeric values shown in the equations
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   Shows the equations of the states (f) and the output (g) for the object
%   in the console by using the pretty() command and displayes the
%   information for the states, inputs, outputs and parameters.
%
% NOTE
%
% SEE ALSO
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

%% Constants used in the method
% =========================================================================
% Set the default parameter for the function
% =========================================================================

defaultDigitNumber = 3;

% =========================================================================

%% Check of the conditions
numFracDigits = defaultDigitNumber;
% Check the input arguments
if nargin > 1
    % Set digit number if argument is scalar numeric
    if (isnumeric(varargin{1}) && isscalar(varargin{1}))
        numFracDigits = varargin{1};
    else
        error('ODESCA_System:show:wrongInputType','The input argument has to be a scalar numeric value');
    end
end
% more than two arguments are not needed
if nargin > 2
    warning('ODESCA_System:show:toManyInputArguments','There is more then one input argument. All arguments exapt the first are ignored');
end


%% Evaluation of the task
% save actual setting of fractional digits and set new value at the same
% time
oldNumDigits = digits(numFracDigits);
%--------------------------------------------------------------------------
info = obj.getInfo();

fprintf('\n');
disp('###############################');
disp(['System Name: ''',obj.name,'''']);
disp(['Created in Version: ',num2str(obj.version)]);
disp('-------------------------------');
fprintf('\n');

disp('States:');
if(isempty(obj.x)) 
    display('    No states');
    fprintf('\n'); 
else
    display(info.states);
end

disp('Inputs:');
if(isempty(obj.u)) 
    display('    No inputs');
    fprintf('\n'); 
else
    display(info.inputs);
end

disp('Outputs:');
if(isempty(obj.g)) 
    display('    No outputs');
    fprintf('\n'); 
else
    display(info.outputs);
end

disp('Parameter:');
if( isempty(obj.p) )
    display('    No parameters');
    fprintf('\n');
else
    infoParam = [info.param, obj.getParam()];
    disp(infoParam);
end

disp('-------------------------------');
fprintf('\n');

disp('State Equation:');
if( isempty(obj.x) )
    display('    No state change equations');
    fprintf('\n');
else
    pretty(vpa(obj.f))
end

disp('Output Equation:');
if( isempty(obj.g) )
    display('    No output equations');
    fprintf('\n');
else
    pretty(vpa(obj.g))
end
disp('###############################');

%--------------------------------------------------------------------------
% set the old digits value
digits(oldNumDigits);

end