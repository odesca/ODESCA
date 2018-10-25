function discretize(obj, varargin)
% Calculates the discrete linear matrices
%
% SYNTAX
%   obj.discretize()
%   obj.discretize(varargin)
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
% OPTIONAL INPUT ARGUMENTS
%
%   varargin:   Array with the name-value-pair arguments:
%
%     Options:
%     =====================================================================
%     name            |  value
%     ----------------|----------------------------------------------------
%     sampleTime      | - Time the matrices should be created with.
%     method          | - Method of discretization:
%                     |     -> 'exact'
%                     |     -> 'approx'
%                     |
%
%     NOTE: - The array has to be either empty or filled with an even number
%             of entries because the arguments have to be an option and its
%             value
%
%     Default value (chosen if the option is not given as argument)
%     =====================================================================
%     name            |  default
%     ----------------|----------------------------------------------------
%     sampleTime      | - Default Sample time of the steady state, in an
%                     |   array from the first steady state
%     method          | - 'exact'
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   This method calculates the discrete matrices Ad and Bd for the
%   linearization. If the sample time is not specified with a
%   name-value-pair, the method takes the default sample time of the system
%   the steady state, this lineariziation belongs to, belongs to. There are
%   different methods for the discretization which can be chosen. The
%   results are saved in the properties Ad and Bd. The used sample time is
%   saved in the property discreteSampleTime.
%
% NOTE
%
% SEE ALSO
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
%   linearSystem_before = sys_lin
%   sys_lin.discretize('sampleTime', 0.1);
%   linear_system_after = sys_lin
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

sampleTime = obj(1).steadyState.system.defaultSampleTime;
chosenMethod = 'exact';

% =========================================================================

%% Check of the conditions
% List of methods which can be chosen
methodList = {'exact','forwardeuler','tustintransform'};

% Check the input parameters if there are input arguments given
if( nargin > 1 )
    numArg = nargin - 1; % Don't count the obj given as input
    % Check if the number of arguments is even (name-value pairs)
    if( mod(numArg,2) == 0 )
        for numPair = 1:(numArg/2)
            option = varargin{numPair*2 - 1};
            value = varargin{numPair*2};
            
            % Check if the option is a string
            if( ~ischar(option) || size(option,1) ~= 1 )
                warning('ODESCA_Linear:discretize:optionNotAString',['The input option number ',num2str(numPair),' is not a scalar string. The option was ignored.']);
            else
                
                % Search for the input option and set the function parameter
                switch(lower(option))
                    case 'sampletime' %####################################
                        % Check if value is numeric and greater than zero
                        if( ~isnumeric(value) || numel(value) ~= 1 || value <= 0)
                            error('ODESCA_Linear:discretize:invalidSampleTime','The sample time has to be a scalar numeric value greater than zero.');
                        end
                        
                        % Set the sample time to the value
                        sampleTime = value;                
                    
                    case 'method' %########################################
                        % Check if the value is a string
                        if( ~ischar(value) || size(value,1) ~= 1)
                            error('ODESCA_Linear:discretize:methodNotAString','The value for the option ''method'' has to be a string.');
                        end
                        
                        % Convert all letters to lower case
                        value = lower(value);
                         
                        % Check if the value matches one of the methods
                        if( ~ismember(value,methodList))
                            errStr = ['''',value,''' is not a valid method. Use one of the following: ''',strrep(strjoin(methodList),' ',''', '''),'''.'];
                            error('ODESCA_Linear:discretize:invalidMethod',errStr);
                        end
                        
                        % Set the chosen value 
                        chosenMethod = value;
                    otherwise %############################################
                        % Throw warning if the option does not exist
                        warning('ODESCA_Linear:linearizeDiscrete:invalidInputOption',['The option ''',option,''' does not exist.']); 

                end
            end
        end
    else
        % Throw error if the number of arguments is not even
        error('ODESCA_Linear:discretize:oddNumberOfInputArguments','The input arguments of this method have to come in name-value pairs and not in an odd number.');
    end
end

%% Evaluation of the task
for numObj = 1:numel(obj)
    linear = obj(numObj);
    
    % Get the needed parts of the calculation
    I = eye(size(linear.A,1));
    T = sampleTime;
    A = linear.A;
    B = linear.B;
    
    % Check which method was chosen and calculate the discrete matrices
    switch(chosenMethod)
        case 'exact'
            Ad = expm(A * T);
            Bd = A \ (Ad - I) * B;
            
        case 'forwardeuler'
            Ad = I + A * T;
            Bd = B * T;
            
        case 'tustintransform'
            Ad = (I + 0.5 * A * T )/(I - 0.5 * A * T);
            Bd = B * T;
    end
    
    % Save the calculated results
    linear.Ad = Ad;
    linear.Bd = Bd;
    linear.discreteSampleTime = sampleTime;
end

end