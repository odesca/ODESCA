function [funF, funG] = createMatlabFunction(sys,varargin)
% Creates Matlab functions funF and funG out of the equations of the system
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
%     type            | - 'euler', 'heun2', 'heun3', 'rk2', 'rk3', 'rk4'
%                     |   or 'continuous'
%                     |   'euler' is the explicit Euler Method
%                     |   All of the following Methods are implemented,
%                     |   such that the states get discretised correctly, 
%                     |   if there are no or only constant inputs.
%                     |   Otherwise it is assumed that the inputs are
%                     |   stairs like, that means that the value is 
%                     |   constant from one time step to the next one. If
%                     |   the value of the inputs changes a lot, it could 
%                     |   be better to use 'euler' for discretisation.
%                     |   'heun2' is the Heun Method of order 2
%                     |   'heun3' is the Heun Method of order 3
%                     |   'rk2' is the Runge-Kutta Method of order 2
%                     |   'rk3' is the Runge-Kutta Method of order 3
%                     |   'rk4' is the Runge-Kutta Method of order 4
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
%     makeFile        | - boolean, if false the function handels funF and
%                     |   funG will be created directly. If it is true,
%                     |   there will be created Matlabfunction scripts 
%                     |   first, with the choosen names. The function 
%                     |   handels funF and funG are based on the created
%                     |   Matlabfunction scripts. This is necessary, when
%                     |   you use e.g. piecewise, because than it is not 
%                     |   possible to create a function handle directly.
%     nameFileF       | - character vector for the name of Matlabfunction 
%                     |   script for the state changes, only necessary if 
%                     |   makeFile is true
%     nameFileG       | - character vector for the name of Matlabfunction 
%                     |   script for the outputs, only necessary if 
%                     |   makeFile is true
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
%     makeFile        | - false
%     nameFileF       | - 'fileF'
%     nameFileG       | - 'fileG'
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
%   [funF, funG] = createMatlabFunction(sys,'type','euler');
%

% Copyright 2017 Tim Grunert, Christian Schade, Lars Brandes, Sven Fielsch,
% Claudia Michalik, Matthias Stursberg, Julia Sudhoff
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
makeFile = false;               % Option: 'makeFile'
nameFileF = 'fileF';            % Option: 'nameFileF'
nameFileG = 'fileG';            % Option: 'nameFileG'

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
                        if ( ~(strcmp(value,'euler') || strcmp(value,'heun2') || strcmp(value,'heun3') || strcmp(value,'rk2') || strcmp(value,'rk3') || strcmp(value,'rk4') || strcmp(value,'continuous')) )
                            warning('ODESCA_System:createMatlabFunction:invalidType','Type has to be ''euler'', ''heun2'', ''heun3'', ''rk2'', ''rk3'', ''rk4'' or ''continuous''. The default type was selected.');
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
                    case 'makefile'
                        if ( ~isa(value, 'logical') || numel(value) ~= 1)
                            warning('ODESCA_System:createMatlabFunction:invalidOptionMakeFile','The value for ''makeFile'' is not a scalar logical value. The default option was selected.');
                        else
                            makeFile = value;
                        end
                    case 'namefilef'
                        if ( ~ischar(value))
                            warning('ODESCA_System:createMatlabFunction:invalidOptionNameFileF','The value for ''nameFileF'' is not a character vector. The default option was selected.');
                        else
                            nameFileF = value;
                        end
                    case 'namefileg'
                        if ( ~ischar(value))
                            warning('ODESCA_System:createMatlabFunction:invalidOptionNameFileG','The value for ''nameFileG'' is not a character vector. The default option was selected.');
                        else
                            nameFileG = value;
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
        if isempty(info.inputs) && isempty(info.states)
            xu_str = [];
        elseif isempty(info.inputs)
            xu_str = info.states(:,1)';
        elseif isempty(info.states)
            xu_str = info.inputs(:,1)';
        else
            xu_str = [info.states(:,1)',info.inputs(:,1)'];
        end
    else
        % Create an array with strings for the N parameter:
        % {p1;p2;...;pN}
        numStr = numel(sys.p);
        paramString = cell([numStr,1]);
        for num = 1:numStr
            paramString{num} = ['p(',num2str(num),')'];
        end
        % Create the array with all inputs of the function
%         xu_str = [info.states(:,1)',info.inputs(:,1)',paramString'];
        if isempty(info.inputs) && isempty(info.states)
            xu_str = [paramString'];
        elseif isempty(info.inputs)
            xu_str = [info.states(:,1)',paramString'];
        elseif isempty(info.states)
            xu_str = [info.inputs(:,1)',paramString'];
        else
            xu_str = [info.states(:,1)',info.inputs(:,1)',paramString'];
        end
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
    [sym_f,sym_g] = sys.calculateNumericEquations();
    vars = [sys.x; sys.u];
else
    sym_f = sys.f;
    sym_g = sys.g;
    vars = [sys.x; sys.u; sys.p];
end

% Create the matlab functions
% f = matlabFunction(sym_f,'vars',vars);

% State Change Function
if( strcmp(type, 'continuous') )
    symF = sym_f;
elseif( strcmp(type, 'euler') )
    symF = sym_f * sys.defaultSampleTime + sys.x;
elseif( strcmp(type, 'heun2') )
    euler = sym_f * sys.defaultSampleTime + sys.x;
    f_neu = subs(sym_f, sys.x, euler);
    symF = 0.5 * sys.x + 0.5 * ( euler + sys.defaultSampleTime * f_neu);
elseif( strcmp(type, 'rk2') )
    k1 = sym_f;
    k2 = subs(sym_f, sys.x,  sys.x+sys.defaultSampleTime*0.5*k1);
    symF = sys.x + sys.defaultSampleTime * k2;
elseif( strcmp(type, 'heun3') )
    k1 = sym_f;
    k2 = subs(sym_f, sys.x, sys.x+sys.defaultSampleTime/3*k1);
    k3 = subs(sym_f, sys.x, sys.x+sys.defaultSampleTime*2/3*k2);
    symF = sys.x + sys.defaultSampleTime * (0.25 * k1 + 0.75 * k3);
elseif( strcmp(type, 'rk3') )
    k1 = sym_f;
    k2 = subs(sym_f, sys.x, sys.x+sys.defaultSampleTime*0.5*k1);
    k3 = subs(sym_f, sys.x, sys.x-sys.defaultSampleTime*k1+sys.defaultSampleTime*2*k2);
    symF = sys.x + sys.defaultSampleTime * (k1/6 + k2*4/6 + k3/6);
elseif( strcmp(type, 'rk4') )
    k1 = sym_f;
    k2 = subs(sym_f, sys.x, sys.x+sys.defaultSampleTime*0.5*k1);
    k3 = subs(sym_f, sys.x, sys.x+sys.defaultSampleTime*0.5*k2);
    k4 = subs(sym_f, sys.x, sys.x+sys.defaultSampleTime*k3);
    symF = sys.x + sys.defaultSampleTime * ((1/6) * k1 + (1/3) * k2 + (1/3) * k3 + (1/6) * k4);
end

% Create the matlab functions
if ( makeFile )
    F = matlabFunction(symF,'vars',vars,'File',nameFileF);
    G = matlabFunction(sym_g,'vars',vars,'File',nameFileG);
    
    if(arrayInputs)
        if( useNumericParam )
            funF =  eval(['@(x,u) ' nameFileF '(' args_str ')']);
            funG =  eval(['@(x,u) ' nameFileG '(' args_str ')']);
        else
            funF =  eval(['@(x,u,p) ' nameFileF '(' args_str ')']);
            funG =  eval(['@(x,u,p) ' nameFileG '(' args_str ')']);
        end
    else
        funF = F;
        funG = G;
    end
else
    F = matlabFunction(symF,'vars',vars);
    G = matlabFunction(sym_g,'vars',vars);

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

end