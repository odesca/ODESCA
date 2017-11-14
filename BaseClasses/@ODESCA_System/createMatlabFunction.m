function [funF, funG] = createMatlabFunction(sys,varargin)
% Creates a Matlab functions out of the equations of the system
%
% SYNTAX
%   [funF, funG] = createMatlabFunction(sys,varargin)
%
% INPUT ARGUMENTS
%   sys:    Instance of the ODESCA_System whose equation should be
%           transformed into matlab functions.
%
% OPTIONAL INPUT ARGUMENTS
%   varargin:   Array with the name-value-pair arguments:
%
%     Options:
%     =====================================================================
%     name            |  value
%     ----------------|----------------------------------------------------
%     type            | - 'discrete' or 'continuous'
%     useNumericParam | - boolean, if true all parameters have to be set
%                     |   and the equations are calculated with the numeric
%                     |   values. If it is false, the parameters are not 
%                     |   substituted in the functions. The appear as an 
%                     |   extra input for the functions, the argument 'p'. 
%                     |   p is an array, where the order of the
%                     |   parameters corresponds to the order of the param
%                     |   structur in the system.
%     arrayInputs     | - boolean, if true the input arguments of the
%                     |   functions are grouped into states, inputs and 
%                     |   (if parameters are not numeric) parameters.
%                     |   In this case the inputs has to be given as
%                     |   vecotrs. If the option is false, every input,
%                     |   output and parameter (if not numeric) has to be
%                     |   given seperatly. Example:
%                     |     true  --> f(x,u,p) [x,u and p are vectors]
%                     |     false --> f(x1,x2,...,u1,u2,...,p1,p2,...)
%                     |
%
%     NOTE: - The array has to be either empty or filled with a even number
%             of entries because they arguments has to be an option and its
%             value
%
%     Default value (choosen if the option is not given as argument)
%     =====================================================================
%     name            |  default
%     ----------------|----------------------------------------------------
%     type            | - 'continuous'
%     useNumericParam | - false
%     arrayInputs     | - true
%
% OUTPUT ARGUMENTS
%   funF:   Matlabfunction for the state changes
%   funG:   Matlabfunction for the outputs
%
% DESCRIPTION
%   This function creates Matlabfunctions out of the equations of a given
%   instance of the ODESCA_System class. The created functions take the
%   values for the states, inputs and the parameters as arrays, where the
%   order corresponds to the order in the system. E.g. the function funF
%   takes the arrays x, u and p as inputs:
%       funF(x,u,p);
%   
% NOTE
%   
% SEE ALSO
%
% EXAMPLE
%   [funF, funG] = createMatlabFunction(sys,'type','discrete');
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
% Set the default arguments for the methode
% =========================================================================

type = 'continuous';            % Option: 'type'
useNumericParam = false;        % Option: 'useNumericParam'
arrayInputs = true;             % Option: 'arrayInputs'

% =========================================================================
% Set the constants used in the method
% =========================================================================

%% Check of the conditions
% Check if the system is empty
if( isempty(sys.f) && isempty(sys.g) )
   error('ODESCA_System:createMatlabFunction:emptySystem','For an empty system, no matlab function can be created.'); 
end

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
                warning('ODESCA_System:createMatlabFunction:optionNotAString',['The input option number ',num2str(numPair),' is not a scalar string. The option was ignored.']);
            else
                
                % Search for the input option and set the function parameter
                switch(lower(option))
                    case 'type'
                        value = lower(value);
                        if ( ~(strcmp(value,'discrete') || strcmp(value,'continuous')) )
                            warning('ODESCA_System:createMatlabFunction:invalidType','Type has to be ''discrete'' or ''continuous''. The default type was selected.');
                        else
                            type = value;
                        end
                    case 'usenumericparam'
                        if ( ~isa(value, 'logical') || numel(value) ~= 1)
                            warning('ODESCA_System:createMatlabFunction:invalidOptionUseNumericParam','The value for ''useNumericParam'' is not a scalar logical value. The default option was selected.');
                        else
                            if( value && ~sys.checkParam())
                                error('ODESCA_System:createMatlabFunction:notAllParamSet','The ''useNumericParam'' option is choosen but not all parameters are set.')
                            end
                            useNumericParam = value;
                        end
                    case 'arrayinputs'
                        if ( ~isa(value, 'logical') || numel(value) ~= 1)
                            warning('ODESCA_System:createMatlabFunction:invalidOptionArrayInputs','The value for ''arrayInputs'' is not a scalar logical value. The default option was selected.');
                        else
                           arrayInputs = value; 
                        end
                    otherwise
                        warning('ODESCA_System:createMatlabFunction:invalidInputOption',['The option ''',option,''' dose not exist.']);
                end
            end
        end
    else
        % Throw error if the number of arguments is not even
        error('ODESCA_System:createMatlabFunction:oddNumberOfInputArguments','The input arguments of this method has to come in name-value pairs and not in an odd number.');
    end
end


%% Evaluation of the task
% Get the structure with the information about the system
info = sys.getInfo();

if(arrayInputs)
    %---------- Prepare the string for vectorial inputs -----------------------
    % By default, the matlabFunction() function creates an input for every
    % symbolic variable in the given function e.g:
    %   f(x1,x2,x3,...,u1,u2,u3,...)
    % For the use of the function it is easier to use vectors for like:
    %   f(x,u)
    % Therefore a string is created, where for every symbolic variable in the
    % function, a call of an array is used:
    %   'x(1),x(2),x(3),...,u(1),u(2),u(3)'
    % This string is used later to encapsulate the function created by
    % matlabFunctinon()-Call:
    %   F(x,u) = f(x(1),x(2),x(3),...,u(1),u(2),u(3))
    
    % Create a cell array of strings for every symbolic function input
    if( useNumericParam )
        xu_str = [info.states(:,1)',info.inputs(:,1)'];
    else
        % Create an array with strings for the N parameter:
        % {p1;p2;...;pN}
        numStr = numel(sys.p);
        paramString = cell([numStr,1]);
        for num = 1:numStr
            paramString{num} = ['p(',num2str(num),')'];
        end
        % Create the array with all inputs of the function
        xu_str = [info.states(:,1)',info.inputs(:,1)',paramString'];
    end
    
    % genertate comma seperated list of input arguments (e.g.
    % translate 'x1' 'x2' to 'x(1),x(2)'
    args_cell = regexprep(xu_str,'u([\d]+)','u\($1\)');
    args_cell = regexprep(args_cell,'x([\d]+)','x\($1\)');
    args_cell = [args_cell',[repmat({','},numel(args_cell)-1,1);{[]}]]';
    args_str = [args_cell{:}];
end

%---------- Create the matlabfunctions ------------------------------------
% Get the equations
if( useNumericParam )
    [f,g] = sys.calculateNumericEquations();
    vars = [sys.x; sys.u];
else
    f = sys.f;
    g = sys.g;
    vars = [sys.x; sys.u; sys.p];
end

% State Change Function
if( strcmp(type, 'continuous') )
    symF = f;
elseif( strcmp(type, 'discrete') )
    symF = f * sys.defaultSampleTime + sys.x;
end

% Create the matlab functions
F = matlabFunction(symF,'vars',vars);
G = matlabFunction(g,'vars',vars);

if(arrayInputs)
    if( useNumericParam )
        funF =  eval(['@(x,u) F(' args_str ')']);
        funG =  eval(['@(x,u) G(' args_str ')']);
    else
        funF =  eval(['@(x,u,p) F(' args_str ')']);
        funG =  eval(['@(x,u,p) G(' args_str ')']);
    end
else
   funF = F;
   funG = G;
end

end