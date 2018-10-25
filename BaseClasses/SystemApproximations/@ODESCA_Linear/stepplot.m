function h = stepplot(obj, varargin)
% Plots the step response for the linearization
%
% SYNTAX
%   obj.stepplot()
%   obj.stepplot(varargin)
%   h = obj.stepplot(___)
%
% INPUT ARGUMENTS
%   obj: array of ODESCA_Linear instances
%
% OPTIONAL INPUT ARGUMENTS
%   varargin:   Array with the name-value-pair arguments:
%
%     Options:
%     =====================================================================
%     name            |  value
%     ----------------|----------------------------------------------------
%     timeOptions     |  Instance of the timeoptions class to customize
%                     |  the plot. Use the method timeoptions() to create
%                     |  such an instance.
%     from            |  Array to define which inputs should be plotted
%                     |     Example: [1:2] to plot all plots from the first
%                     |              and second input.
%                     |
%     to              |  Array to define which outputs should be plotted
%                     |     Example: [1,3] to plot all plots to the first
%                     |              and third output.
%
%     NOTE: - The array has to be either empty or filled with an even number
%             of entries because the arguments have to be an option and its
%             value
%
%     Default value (chosen if the option is not given as argument)
%     =====================================================================
%     name            |  default
%     ----------------|----------------------------------------------------
%     timeOptions     |  Default options except the Interpreter for the
%                     |  labels of the inputs and outputs where the option
%                     |  'none' is chosen
%     from            |  1:end
%     to              |  1:end
%
% OUTPUT ARGUMENTS
%   h:  resppack.timeplot which belongs to the created plot
%
% DESCRIPTION
%   This method creates a stepplot for the linearizations. It can take
%   multiple name-value-pair arguments to specify the plotting behavior. It
%   makes use of the method stepplot() of the control system toolbox.
%
% NOTE
%
% SEE ALS
%   stepplot() [Method of the control system toolbox]
%   
% EXAMPLE
%   Pipe = OCLib_Pipe('MyPipe');
%   Pipe.setConstructionParam('Nodes',2);
%   Pipe.setParam('cPipe',500);
%   Pipe.setParam('mPipe',0.5);
%   Pipe.setParam('VPipe',0.001);
%   Pipe.setParam('RhoFluid', 998);
%   Pipe.setParam('cFluid',4182);
%   PipeSys = ODESCA_System('MySystem',Pipe);
%   ss1 = PipeSys.createSteadyState([40; 40],[40; 0.1] ,'ss1');
%   sys_lin = ss1.linearize();
%   sys_lin.stepplot('from', 1, 'to', 1)
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

%% Condition used in the method
% =========================================================================
% Set the default arguments for the method
% =========================================================================
timeOptions = timeoptions();
timeOptions.InputLabels.Interpreter = 'none';
timeOptions.OutputLabels.Interpreter = 'none';
% from defined below
% to defined below

% =========================================================================

%% Check of the conditions
% Check if all linearizations have the same dimension:
sizeIn  = arrayfun(@(x) size(x.D,2),obj); % Number of inputs
sizeOut = arrayfun(@(x) size(x.D,1),obj); % Number of outputs
if( ~all(sizeIn == sizeIn(1)) || ~all(sizeOut == sizeOut(1)) )
    % Create the string for the error
    maxDigits = numel(num2str(max(max(sizeIn),max(sizeOut)))); % Maximal number of digits in in-/outputs for better apperance
    errStr = sprintf('The number of inputs/outputs is not the same to all linearizations.\nDimensions:');
    for numLin = 1:numel(obj)
        errStr = [errStr,sprintf('\n[%*d x %*d] Name of associated steady state: %s',maxDigits,sizeOut(numLin),maxDigits,sizeIn(numLin)),obj(numLin).steadyState.name]; %#ok<AGROW>
    end
    error('ODESCA_Linear:stepplot:dimensionMismatch',errStr);
end
% Since all elements are the same, take the first
sizeIn = sizeIn(1);
sizeOut = sizeOut(1);

% Check if the linearization has inputs
if( sizeIn == 0 )
   error('ODESCA_Linear:stepplot:noInputs','A stepplot of a linear system without inputs can not be created'); 
end

% Set the number of inputs
inputs  = 1:sizeIn;  % Option: from
outputs = 1:sizeOut; % Option: to

% Check the input parameters if there are name-value-pairs given
if( nargin > 1 )
    numArg = nargin - 1; % Don't count the instance itself
    % Check if the number of arguments is even (name-value pairs)
    if( mod(numArg,2) == 0 )
        for numPair = 1:(numArg/2)
            option = varargin{numPair*2 - 1};
            value = varargin{numPair*2};
            
            % Check if the option is a string
            if( ~ischar(option) || size(option,1) ~= 1 )
                warning('ODESCA_Linear:stepplot:optionNotAString',['The input option number ',num2str(numPair),' is not a scalar string. The option was ignored.']);
            else
                
                % Search for the input option and set the function parameter
                switch(lower(option))
                    case 'timeoptions'
                        % Check if the option is of the class timeoptions
                        if( ~isa(value,'plotopts.TimePlotOptions') || numel(value) ~= 1 )
                            warning('ODESCA_Linear:stepplot:timeOptionsNotCorrect','The input for the option ''timeOptions'' is not an instance of the class ''plotopts.TimePlotOptions''. The default option was chosen.');
                        else
                            timeOptions = value;
                        end
                        
                    case 'from'
                        % Check if value is a numeric array of integer
                        if( ~isnumeric(value) || max(mod(value,1) ~= 0) )
                            error('ODESCA_Linear:stepplot:invalidFromOption','The value for the option ''from'' has to be an array of integer values.');
                        end
                        value = reshape(value,[1,numel(value)]);
                        
                        % Check if the chosen inputs are in the range of
                        % existing inputs
                        if( min(value) < 1 || max(value) > sizeIn)
                            error('ODESCA_Linear:stepplot:invalidFromOption','The entries of the array for the option ''from'' have to be in the range of the number of inputs.');
                        end
                        
                        inputs = value;
                    
                    case 'to'
                        % Check if value is a numeric array of integer
                        if( ~isnumeric(value) || max(mod(value,1) ~= 0) )
                            error('ODESCA_Linear:stepplot:invalidToOption','The value for the option ''to'' has to be an array of integer values.');
                        end
                        value = reshape(value,[1,numel(value)]);
                        
                        % Check if the chosen inputs are in the range of
                        % existing inputs
                        if( min(value) < 1 || max(value) > sizeOut)
                            error('ODESCA_Linear:stepplot:invalidToOption','The entries of the array for the option ''to'' have to be in the range of the number of outputs.');
                        end
                        
                        outputs = value;
                        
                    otherwise
                        warning('ODESCA_Linear:stepplot:invalidInputOption',['The option ''',option,''' does not exist.']);
                end
            end
        end
    else
        % Throw error if the number of arguments is not even
        error('ODESCA_Linear:stepplot:oddNumberOfInputArguments','The input arguments of this method have to come in name-value pairs and not in an odd number.');
    end
end

% Check if there are linearizations with complex numbers
posReal = boolean(zeros(size(obj)));
for numObj = 1:numel(obj)
    lin = obj(numObj);
    posReal(numObj) = isreal(lin.A) && isreal(lin.B) && ...
                      isreal(lin.C) && isreal(lin.D);
end
% Throw an error if every linearization contains complex matrices
if(sum(posReal) == 0)
   error('ODESCA_Linear:stepplot:noRealLinearizations','All linearizations contain complex matrices. Therefore the step plot could not be created.'); 
end
% If linearizations with complex values are found, throw warning and remove
% the ones with complex values from the list to plot
if(sum(~posReal) ~= 0 )
    % Create the warning
    names = {obj(~posReal).steadyState.name};
    warnStr = sprintf('There are linearizations where the matrices contain complex values. They are not plotted in the stepplot.\nThese linearizations belong to the following steady states:\n');
    for numStr = 1:numel(names)
       warnStr = [warnStr,sprintf('%s\n',names{numStr})];  %#ok<AGROW>
    end
    warning('ODESCA_Linear:stepplot:linearizationsWithComplexMatrices',warnStr);
    % Remove the linearizations
    obj = obj(posReal);
end

%% Evaluation of the task
% Get the transfer functions of all linearizations
stateSpaceObjects = {obj.tf};
% Reduce the transfer functions to the demanded inputs and outputs
H = cellfun( @(x) x(outputs,inputs), stateSpaceObjects,'UniformOutput',false);
% Create the stepplot
handle = stepplot(H{:},timeOptions);
% Prepare the output argument
if(nargout == 1)
   h = handle;  
end

end