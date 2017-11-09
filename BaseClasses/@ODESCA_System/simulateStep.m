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

function [t,x,y] = simulateStep(sys, tspan, x0, u0, varargin)
% Simulates a step in the nonlinear system
%
% SYNTAX
%   simulateStep(tspan,x0,u0)
%   simulateStep(tspan,x0,u0,odeOptions)
%   simulateStep(tspan,x0,u0,tstep,u1)
%   simulateStep(tspan,x0,u0,tstep,u1,odeOptions)
%
% INPUT ARGUMENTS
%   sys:    Instance of the system where the methode was
%           called. This parameter is given automatically.
%   tspan:  Numeric array with two entries, which determines the interval
%           the step is simulated for.
%   x0:     Array with the values of the states at the beginning of the
%           simulation.
%   u0:     Array with the values of the inputs which determine the height
%           the step.
%
% OPTIONAL INPUT ARGUMENTS
%   odeOptions: Set of options for the ode-solver used in this method. It
%               is a structure which can be genereted with the method
%               odeset(). See odeset in the MATLAB help. 
%   tstep:      Time of the simulation at which a second step should happen. 
%               NOTE: if this argument is given, the input argument u1 has to
%               be given too.
%   u1:         Array with the values of the inputs for the second step.
%
%
% OUTPUT ARGUMENTS
%   t:      Array with the points of time of the simulation.
%   x:      Matrix with the values of the states durning the simulation,
%           corresponding with the points of time in the output argument t.
%   y       Matrix with the values of the outputs durning the simulation,
%           corresponding with the points of time in the output argument t.
%
% DESCRIPTION
%   This method simulates a step given to the inputs of a system. It uses
%   the ode45() solver to simulate the behavior. The simulation time and
%   the initial conditions have to be given as well as the input values
%   for the step. A seconde step can be performed after a certain time.
%   In addition, the way the ode45() solver runes can be modified by giving
%   the odeOptions (see odeset() for more information). The results can be
%   recived by the output arguments. If no output arguments are demanded,
%   the results are plotted.
%
% NOTE
%   - If NO output arguments are demanded durning the call of this method,
%     the results of the step simulation are plotted.
%     If output arguments ARE demanded, the results are not plotted.
%
% SEE ALSO
%   odeset() [Function of MATLAB]
%
% EXAMPLE
%   - [t,x,y] = simulateStep([0 20], [0 0 0], [1 1]) 
%       --> Example for a system with 3 states and 2 inputs
%   - simulateStep([0 20], [0 0 0], [1 1]) 
%       --> Same simulation, but now the results are plotted
%   - simulateStep([0 20], [0 0 0], [1 1], 10, [2 2]) 
%       --> Simulation with a second step at the time of 10 seconds
%   - odeOptions = odeset();
%     odeOptions.MaxStep = 0.01;
%     simulateStep([0 20], [0 0 0], [1 1], odeOptions) 
%       --> Simulation with a different ode option set. Here the maximal
%           step time for the simulation was limited to 0.01 
%

%% Condition used in the method
% =========================================================================
% Set the default arguments for the methode
% =========================================================================
% Create the structure for the options of the ode solver
defaultOdeOptions = odeset();
defaultOdeOptions.RelTol = 1e-20;
defaultOdeOptions.MaxStep = 0.001;

% =========================================================================
% Set the constants used in the method
% =========================================================================


%% Check of the conditions
secondStep = false;

% Check if the system has inputs and states
if( isempty(sys.x) || isempty(sys.u) )
   error('ODESCA_System:simulateStep:emptyStatesOrInputs','The method ''simulateStep'' can not be used for systems with no states or no inputs.'); 
end

% Check the number of input arguments
if( nargin == 4 )
    odeOptions = defaultOdeOptions;
    
elseif( nargin == 5)
    odeOptions = varargin{1};
    
elseif( nargin == 6) 
    tstep =      varargin{1};
    u1 =         varargin{2};
    odeOptions = defaultOdeOptions;
    
elseif(nargin == 7)
    tstep =      varargin{1};
    u1 =         varargin{2};
    odeOptions = varargin{3};
    
else
    error('ODESCA_System:simulateStep:wrongNumberOfInputArguments','The method was called with the wrong number of input arguments. See the section SYNTAX in the help for more information.');
end

% Check if the timespan has a valid typ
if( ~isnumeric(tspan) || numel(tspan) ~= 2 || any([isnan(tspan) isinf(tspan)]) || ~isreal(tspan) || tspan(2) <= tspan(1))
    error('ODESCA_System:simulateStep:invalidTimespan','The input argument ''tspan'' has to be a numeric array with two entries. The entries are not allowed to be complex or the values Inf or NaN. The startpoint of the timespan has to be before the endpoint.');
end

% Check if the initial state values given are valid
if( ~isnumeric(x0) || numel(x0) ~= numel(sys.x)) 
    error('ODESCA_System:simulateStep:invalidInitialState','The input argument ''x0'' has to be a numeric array where the number of entries has to match the number of states in the system.');
end
x0 = reshape(x0,[1,numel(x0)]);
if( any([isnan(x0) isinf(x0)]) || ~isreal(x0))
    error('ODESCA_System:simulateStep:invalidInitialState','The entries of the argument ''x0'' are not allowed to be complex or the values Inf or NaN.');
end

% Check if the first input values given are valid
if( ~isnumeric(u0) || numel(u0) ~= numel(sys.u))
    error('ODESCA_System:simulateStep:invalidFirstInput','The input argument ''u0'' has to be a numeric array where the number of entries has to match the number of inputs in the system.');
end
u0 = reshape(u0,[1,numel(u0)]);
if( any([isnan(u0) isinf(u0)]) || ~isreal(u0))
    error('ODESCA_System:simulateStep:invalidFirstInput','The entries of the argument ''u0'' are not allowed to be complex or the values Inf or NaN.');
end

% Check if the odeOptions are valid (structure containing all ode options)
if( ~isstruct(odeOptions) || ~all( ismember( fieldnames(odeset()), fieldnames(odeOptions) ) ) )
    error('ODESCA_System:simulateStep:invalidOdeOptions','The odeOptions given as argument does not match the required ode option set.');
end

% Check if the second step 
if(nargin >=  6)
    % Set the flag if a second step should be plotted
    secondStep = true;   
    
    % Check if the timespan has a valid typ
    if( ~isnumeric(tstep) || numel(tstep) ~= 1 || isnan(tstep) || isinf(tstep) || ~isreal(tstep) || tstep <= tspan(1)  || tstep >= tspan(2))
        error('ODESCA_System:simulateStep:invalidSteptime','The input argument ''tstep'' has to be a numeric scalar value. The value is not allowed to be complex or the values Inf or NaN. The steptime has to be inside the timespan for the step simulation.');
    end
    
    % Check if the second input values given are valid
    if( ~isnumeric(u1) || numel(u1) ~= numel(sys.u))
        error('ODESCA_System:simulateStep:invalidSecondInput','The input argument ''u1'' has to be a numeric array where the number of entries has to match the number of inputs in the system.');
    end
    u1 = reshape(u1,[1,numel(u1)]);
    if( any([isnan(u1) isinf(u1)]) || ~isreal(u1))
        error('ODESCA_System:simulateStep:invalidSecondInput','The entries of the argument ''u1'' are not allowed to be complex or the values Inf or NaN.');
    end
end

%% Evaluation of the task
% Prepare the needed variables for the function
p  = (sys.getParam(true))';
[funF,funG] = sys.createMatlabFunction();

% Create the function for the input values
if(secondStep)
    step = @(t) doStep(t, tstep, u0, u1);
else
    step = @(t) u0;
end

% Create the function for the ode45 solver
odeFun = @(t,x) funF(x, step(t), p);

% Simulate the dynamics of the system with the ode45 solver
[val_t,val_x] = ode45(odeFun,tspan,x0,odeOptions);

% Calculate the input and output values
val_y = zeros(size(sys.g,1),size(val_t,1));
val_u = zeros(size(sys.u,1),size(val_t,1));
for numRow = 1:size(val_t,1)
    val_y(:,numRow) = funG(val_x(numRow,:),u0,p);
    val_u(:,numRow) = step(val_t(numRow));
end
val_y = val_y';

% Check if the outputs are requested, if not, plot the results.
if(nargout == 0)
    figure;
    
    % Subplot for the dynamics of the outputs
    ax1 = subplot(3,1,1);
    plot(val_t,val_y)
    title('Values of the outputs');
    legend(strrep(sys.outputNames','_','\_'));
    grid on;
    
    % Subplot for the dynamics of the states
    ax2 = subplot(3,1,2);
    plot(val_t,val_x)
    title('Values of the states');
    legend(strrep(sys.stateNames','_','\_'));
    grid on;
    
    % Subplot for the dynamics of the states
    ax3 = subplot(3,1,3);
    plot(val_t,val_u)
    title('Values of the inputs');
    legend(strrep(sys.inputNames','_','\_'));
    grid on;
    
    % Link all axes so they get scaled the same
    linkaxes([ax1,ax2,ax3],'x');
else
    % Set the output values
    t = val_t;
    x = val_x;
    y = val_y;
end

end

%##########################################################################
%% Nested Function
%##########################################################################
function u = doStep(t,ts,u0,u1)
% This function simulates a step from the input 'u0' to the input 'u1' at 
% the time 'ts'
    if(t < ts)
        u = u0;
    else
        u = u1;
    end
end