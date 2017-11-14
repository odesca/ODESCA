function h = nyquistplot(obj, varargin)
% Plots the nyquist diagram for the linearization
%
% SYNTAX
%   obj.nyquistplot()
%   obj.nyquistplot(varargin)
%   h = obj.nyquistplot(___)
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
%     nyquistOptions  |  Instance of the nyquistoptions class to customize
%                     |  the plot. Use the method nyquistoptions() to 
%                     |  create such an instance.
%     from            |  Array to define which inputs to be plotted
%                     |     Example: [1:2] to plot all plots from the first
%                     |              and second input.
%                     |
%     to              |  Array to define which outputs to be plotted
%                     |     Example: [1,3] to plot all plots to the first
%                     |              and third output.
%
%     NOTE: - The array has to be either empty or filled with a even number
%             of entries because the arguments have to come in 
%             name-value-pairs.
%
%     Default value (chosen if the option is not given as argument)
%     =====================================================================
%     name            |  default
%     ----------------|----------------------------------------------------
%     nyquistOptions  |  Default options except the Interpreter for the
%                     |  labels of the inputs and outputs where the option
%                     |  'none' is chosen
%     from            |  1:end
%     to              |  1:end
%
% OUTPUT ARGUMENTS
%   h:  resppack.nyquistplot which belongs to the created plot
%
% DESCRIPTION
%   This method creates a nyquistplot for the linearizations. It can take
%   multiple name-value-pair arguments to specify the plotting behavior. It
%   makes use of the method nyquistplot() of the control system toolbox.
%
% NOTE
%
% SEE ALSO
%   nyquistplot() [Method of the control system toolbox]
%
% EXAMPLE
%   obj.nyquistplot('from', 1, 'to', 1)
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
nyquistOptions = nyquistoptions();
nyquistOptions.InputLabels.Interpreter = 'none';
nyquistOptions.OutputLabels.Interpreter = 'none';
nyquistOptions.ShowFullContour = 'off';
% inputs defined below
% outputs defined below

% =========================================================================

%% Check of the conditions
% Check if all linearizations have the same dimension:
sizeIn  = arrayfun(@(x) size(x.D,2),obj);
sizeOut = arrayfun(@(x) size(x.D,1),obj);
if( ~all(sizeIn == sizeIn(1)) || ~all(sizeOut == sizeOut(1)) )
    % Create the string for the error
    maxDigits = numel(num2str(max(max(sizeIn),max(sizeOut))));
    errStr = sprintf('The number of inputs/outputs is not the same to all linearisations.\nDimensions:');
    for numLin = 1:numel(obj)
        errStr = [errStr,sprintf('\n[%*d x %*d] Name of SteadyState: %s',maxDigits,sizeOut(numLin),maxDigits,sizeIn(numLin)),obj(numLin).steadyState.name]; %#ok<AGROW>
    end
    error('ODESCA_Linear:nyquistplot:dimensionMismatch',errStr);
end
sizeIn = sizeIn(1);
sizeOut = sizeOut(1);

% Set the number of inputs
inputs = 1:sizeIn;
outputs = 1:sizeOut;

% Check the input parameters if there are name-value-pairs given
if( nargin > 1 )
    numArg = nargin - 1; % Don't count the obj given as input
    % Check if the number of arguments is even (name-value pairs)
    if( mod(numArg,2) == 0 )
        for numPair = 1:(numArg/2)
            option = varargin{numPair*2 - 1};
            value = varargin{numPair*2};
            
            % Check if the option is a string
            if( ~ischar(option) || size(option,1) ~= 1 )
                warning('ODESCA_Linear:nyquistplot:optionNotAString',['The input option number ',num2str(numPair),' is not a scalar string. The option was ignored.']);
            else
                
                % Search for the input option and set the function parameter
                switch(lower(option))
                    case 'nyquistoptions'
                        % Check if the option is a nyquistoption
                        if( ~isa(value,'plotopts.NyquistPlotOptions') || numel(value) ~= 1 )
                            warning('ODESCA_Linear:nyquistplot:nyquistOptionsNotCorrect','The input for the option ''nyquistoptions'' is not an instance of the class ''plotopts.NyquistPlotOptions''. The default option was chosen.');
                        else
                            nyquistOptions = value;
                        end
                        
                    case 'from'
                        % Check if value is a numeric array of integer
                        if( ~isnumeric(value) || max(mod(value,1) ~= 0) )
                            error('ODESCA_Linear:nyquistplot:invalidInputOption','The value for the option ''from'' has to be an array of integer values.');
                        end
                        value = reshape(value,[1,numel(value)]);
                        
                        % Check if the chosen inputs are in the range of
                        % existing inputs
                        if( min(value) < 1 || max(value) > sizeIn)
                            error('ODESCA_Linear:nyquistplot:invalidInputOption','The entries of the array for the option ''from'' have to be in the range of the number of inputs.');
                        end
                        
                        inputs = value;
                    
                    case 'to'
                        % Check if value is a numeric array of integer
                        if( ~isnumeric(value) || max(mod(value,1) ~= 0) )
                            error('ODESCA_Linear:nyquistplot:invalidOutputOption','The value for the option ''to'' has to be an array of integer values.');
                        end
                        value = reshape(value,[1,numel(value)]);
                        
                        % Check if the chosen inputs are in the range of
                        % existing inputs
                        if( min(value) < 1 || max(value) > sizeOut)
                            error('ODESCA_Linear:nyquistplot:invalidOutputOption','The entries of the array for the option ''to'' have to be in the range of the number of outputs.');
                        end
                        
                        outputs = value;
                        
                    otherwise
                        warning('ODESCA_Linear:nyquistplot:invalidInputOption',['The option ''',option,''' does not exist.']);
                end
            end
        end
    else
        % Throw error if the number of arguments is not even
        error('ODESCA_Linear:nyquistplot:oddNumberOfInputArguments','The input arguments of this method have to come in name-value pairs and not in an odd number.');
    end
end

%% Evaluation of the task
% Get the transfer functions of all linearizations
stateSpaceObjects = {obj.tf};
% Reduce the transfer functions to the demanded inputs and outputs
H = cellfun( @(x) x(outputs,inputs), stateSpaceObjects,'UniformOutput',false);
% Create the nyquistplot
handle = nyquistplot(H{:},nyquistOptions);
% Prepare the output argument
if(nargout == 1)
   h = handle;  
end

end