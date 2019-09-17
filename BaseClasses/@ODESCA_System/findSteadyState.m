function [x0] = findSteadyState(sys,varargin)
% Method to find steady states, can retrun one, multiple or no results
%
% SYNTAX
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the methode was
%           called. This parameter is given automatically.
%
% OPTIONAL INPUT ARGUMENTS
%   varargin:   Array with the name-value-pair arguments:
%     
%     Options:
%     =====================================================================
%     name            |  value
%     ----------------|----------------------------------------------------
%     method          | 'simulate', 'analytically'
%     inputs          |
%     simulationTime  | 
%     showSimulation  |
%
%     NOTE: - The array has to be either empty or filled with a even number
%             of entries because they arguments has to be an option and its
%             value
%   
%     Default value (choosen if the option is not given as argument)
%     =====================================================================
%     name            |  default
%     ----------------|----------------------------------------------------
%     method          | - 'simulate'
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%
% NOTE
%
% SEE ALSO
%
% EXAMPLE
%     Pipe = OCLib_Pipe('MyPipe');
%     Pipe.setConstructionParam('Nodes',2);
%     Pipe.setParam('cPipe',500);
%     Pipe.setParam('mPipe',0.5);
%     Pipe.setParam('VPipe',0.001);
%     Pipe.setParam('RhoFluid', 998);
%     Pipe.setParam('cFluid',4182);
%     PipeSys = ODESCA_System('MySystem',Pipe);
%     x0 = PipeSys.findSteadyState('inputs',[40; 0.1],'showSimulation',...
%            true,'simulationTime',100)
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
method          = 'simulate';
xInit           = []; % Will be set to zeros by default
u0              = []; % Will be set to zeros by default
SimTime         = 20; % Defauls simulation time in [s]
showSimulation  = false;

% Set of default bode options
odeOptions = odeset();
odeOptions.RelTol = 1e-20;
odeOptions.MaxStep = 0.001;

% =========================================================================
% Set the constants used in the method
% =========================================================================


%% Check of the conditions
% Check if the system has states
if( isempty(sys.x))
   error('ODESCA_System:findSteadyState:noStates','The system has no states.');
end

% Check if all parameters of the systems are set to values
if( ~sys.checkParam() )
    error('ODESCA_System:findSteadyState:notAllParametersSet','To find a steady state, all parameters have to be set.');
end

% Create the variables to store the name-value-pair arguments

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
                warning('ODESCA_System:findSteadyState:optionNotAString',['The input option number ',num2str(numPair),' is not a scalar string. The option was ignored.']);
            else
                
                % Search for the input option and set the function parameter
                switch(lower(option))
                    case 'method'
                        value = lower(value);
                        if ( ~(strcmp(value,'simulate') || strcmp(value,'analytically')) ) 
                            error('ODESCA_System:findSteadyState:invalidMethod','Method has to be ''simulate'' or ''analytically''. The default method was selected.');
                        else
                            method = value;
                        end
                        
                    case 'inputs'
                        if( size(value) ~= size(sys.u))
                            error('ODESCA_System:findSteadyState:wrongInputNumber','The number of values for the argument ''inputs'' does not match the number of inputs of the system.')
                        end
                        if( ~isnumeric(value) || any(isnan(value)) || any(isinf(value)))   
                            error('ODESCA_System:findSteadyState:wrongInputType','The values for the argument ''inputs'' have to be numeric and must not contain NaN or Inf as entries.')
                        end
                        u0 = value;
                        
                    case 'simulationtime'
                        if( numel(value) ~= 1 || ~isnumeric(value) || isnan(value) || isinf(value))
                           error('ODESCA_System:findSteadyState:wrongSimulationTime','The value for the argument ''simulationTime'' has to be a scalar numeric value which must not be NaN or Inf.');
                        end    
                        SimTime = value;
                        
                    case 'showsimulation'
                        if( numel(value) ~= 1 || ~isa(value, 'logical'))
                           error('ODESCA_System:findSteadyState:showSimulationIncorrectLogical','The value for the argument ''showSimulation'' has to be a scalar logical value.')
                        end
                        showSimulation = value;
                        
                    otherwise
                        warning('ODESCA_System:findSteadyState:invalidInputOption',['The option ''',option,''' does not exist.']);
                end
            end
        end
    else
        % Throw error if the number of arguments is not even
        error('ODESCA_System:findSteadyState:oddNumberOfInputArguments','The input arguments of this method has to come in name-value pairs and not in an odd number.');
    end
end



%% Evaluation of the task

% Search for the steady state with the chosen option
switch(lower(method))
    %% Search for steady states with simulation
    case 'simulate'
        tspan = [0, SimTime];
        
        % Set the default initial state values (0) if necessary
        if( isempty(xInit) )
            xInit = zeros(size(sys.x));
        end
        
        % Set the default input values (0) if necessary
        if( isempty(u0) && ~isempty(sys.u) )
            u0 = zeros(size(sys.u)) + 20;  %TODO: + 20 entfernen
        end
        
        % Get the functions of the system
        [f,~] = sys.createMatlabFunction('useNumericParam',true);
        
        % Create the function needed by the ode-solver 
        odeFun = @(t,x) f(x,u0);
        
        % Simulate the function for a given time
        [val_t,val_x] = ode45(odeFun,tspan,xInit,odeOptions);
        
        % Visualtization of the simulation
        if(showSimulation)
            figure('Name','State-value curve');
            hold on;
            for num = 1:size(val_x,2)
                plot(val_t,val_x(:,num));
            end
            info = sys.getInfo();
            stateNames = info.states(:,2);
            for i = 1:numel(stateNames)
                stateNames{i} = strrep(stateNames{i},'_','\_');
            end
            legend(stateNames);
        end
        
        
        % Check, if the behavior of the simulation diverges
        % TODO
        
        % Return the final value of x
        x0 = val_x(end,:)';
        
    case 'analytically'    
        if ~isempty(sys.u)
            if u0
                u_steady = u0;
            else
                u_steady = sym('u_s',[length(sys.u),1]);
            end
            eqns = subs(sys.f,sys.u,u_steady) == 0;
        else
            eqns = sys.f == 0;
        end
        
        if ~isempty(sys.p)
            % get parameter
            temp = sys.getParam();
            paramVal = sym('p',size(temp));
            for num = 1:numel(temp)
                paramVal(num) = temp{num};
            end
            % set parameter
            eqns = subs(eqns,sys.p,paramVal);
        end
        
        sys.validSteadyStates = solve(eqns,sys.x,'ReturnConditions',true);
        x0 = [];
        for i=1:length(sys.x)
            eval(['x0 = [x0; sys.validSteadyStates.x',num2str(i),'];']);
        end
        if u0
            x0 = double(x0);
        end
        
    otherwise
        warning('No correct method selected!');
        x0 = [];
        return;
end

end