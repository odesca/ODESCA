function [t,x,y,u] = simulate(sys, tspan, x0, u, odeOptions)
% Simulates the system for the given inputs and initial states
%
% SYNTAX
%   sys.simulate(tspan, x0, u)
%   sys.simulate(tspan, x0, u, odeOptions)
%   [t,x,y,u] = sys.simulate(tspan, x0, u)
%   [t,x,y,u] = sys.simulate(tspan, x0, u, odeOptions)
%
% INPUT ARGUMENTS
%   sys:    Instance of the system where the methode was
%           called. This parameter is given automatically.
%   tspan:  Numeric array with two entries, which determines the interval
%           the step is simulated for.
%   x0:     Array with the values of the states at the beginning of the
%           simulation.
%
%   u:      Either: Inputs as function handle [u = @(t) ...] for the input
%                   values with as many rows as the system has inputs
%           or:     Array of numeric input values with the size [n+1 x m]
%                   where n is the number of inputs to the system and m is
%                   the number of time time steps. The first row of the
%                   array contains the time and the following rows contain
%                   the values for each input.
%
% OPTIONAL INPUT ARGUMENTS
%   odeOptions: Set of options for the ode-solver used in this method. It
%               is a structure which can be genereted with the method
%               odeset(). See odeset in the MATLAB help. By default, the
%               matlab standard is selected.
%
% OUTPUT ARGUMENTS
%   t:      Array with the points of time of the simulation.
%   x:      Matrix with the values of the states durning the simulation,
%           where each row corresponds with the states of the system and
%           each column corresponds with the column in the time vector t.
%   y:      Matrix with the values of the outputs durning the simulation,
%           where each row corresponds with the outputs of the system and
%           each column corresponds with the column in the time vector t.
%   u:      Matrix with the values of the inputs durning the simulation,
%           where each row corresponds with the inputs of the system and
%           each column corresponds with the column in the time vector t.
%
% DESCRIPTION
%   This methods simulates the system for a given timespan. The time steps,
%   the inputs, outputs and states during the simulation are given as
%   output arguments. If no output arguments are requested by the function
%   call, the result is shown in a plot. For the simulation to run, all
%   parameters of the system has to be set.
%
% NOTE
%   - The method requires all parameters of the system to be set.
%   - If the method is called without requesting any output arguments, the
%     result is shwon in a plot.
%
% SEE ALSO
%   odeset() [Function of MATLAB]
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
%   PipeSys.simulate([0 10],[10 10],@(t) [0.5*t+10; 0.1]);
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
% Create the structure for the options of the ode solver
defaultOdeOptions = odeset();

% =========================================================================
% Set the constants used in the method
% =========================================================================


%% Check of the conditions

% Check if the system has inputs and states
if( isempty(sys.x) || isempty(sys.u) )
    error('ODESCA_System:simulate:emptyStatesOrInputs','The method ''simulateStep'' can not be used for systems with no states or no inputs.');
end

% Check the number of input arguments
if( nargin == 4 )
    odeOptions = defaultOdeOptions;
    
elseif( nargin == 5)
    % do nothing
else
    error('ODESCA_System:simulate:wrongNumberOfInputArguments','The method was called with the wrong number of input arguments. See the section SYNTAX in the help for more information.');
end

% Check if the timespan has a valid typ
if( ~isnumeric(tspan) || numel(tspan) ~= 2 || any([isnan(tspan) isinf(tspan)]) || ~isreal(tspan) || tspan(2) <= tspan(1))
    error('ODESCA_System:simulate:invalidTimespan','The input argument ''tspan'' has to be a numeric array with two entries. The entries are not allowed to be complex or the values Inf or NaN. The startpoint of the timespan has to be before the endpoint.');
end

% Check if the initial state values given are valid
if( ~isnumeric(x0) || numel(x0) ~= numel(sys.x))
    error('ODESCA_System:simulate:invalidInitialState','The input argument ''x0'' has to be a numeric array where the number of entries has to match the number of states in the system.');
end
x0 = reshape(x0,[1,numel(x0)]);
if( any([isnan(x0) isinf(x0)]) || ~isreal(x0))
    error('ODESCA_System:simulate:invalidInitialState','The entries of the argument ''x0'' are not allowed to be complex or the values Inf or NaN.');
end

% Check if the input function given is valid
if(isa(u,'function_handle'))
    % Check if the number of inputs to the function is one
    if(nargin(u) ~= 1)
        error('ODESCA_System:simulate:wrongNumberOfInputFunctionInputs','The function for the input must have exactly one input.');
    end
    
    % Check if the number of outputs of the function is correct
    if(numel(u(0)) ~= numel(sys.u))
        error('ODESCA_System:simulate:wrongNumberOfInputFunctionOutputs','The function for the inputs must have as many outputs as the system has inputs.');
    end
    
elseif(isnumeric(u))
    % Check if the right number of inputs was given for the array
    if(size(u,1) ~= (numel(sys.u)+1))
        error('ODESCA_System:simulate:wrongDimensionOfInputs','The array with the values of the inputs does not have the correct dimension. See the method description for more information.');
    end
    
    % Check if the array does not contain the values NaN or Inf
    if(any(any(isnan(u))) || any(any(isinf(u))))
        error('ODESCA_System:simulate:valueOfInputsNaNOrInf','The array with the values of the inputs must not contain any entry which is NaN or Inf.');
    end
    
    % Check for the causality of the time vector is given
    if(any((u(1,2:end) - u(1,1:end-1)) <= 0))
        error('ODESCA_System:simulate:causalityOfTimeVectorNotGiven','The time vector of the input array (the first row) does not fulfill the criteria of causality. Make sure every entry is greater than the pervious one.');
    end
else
    error('ODESCA_System:simulate:wrongTypeOfInput','The argument ''u'' has to be either a function_handle or a numeric array.');
end

% Check if the odeOptions are valid (structure containing all ode options)
if( ~isstruct(odeOptions) || ~all( ismember( fieldnames(odeset()), fieldnames(odeOptions) ) ) )
    error('ODESCA_System:simulate:invalidOdeOptions','The odeOptions given as argument does not match the required ode option set.');
end

%% Evaluation of the task
% Prepare the needed variables for the function
[funF,funG] = sys.createMatlabFunction('useNumericParam', true);

% If the input u is a numeric array, create a function out of it
if(isnumeric(u))
    u = @(t) interp1(u(1,:)',u(2:end,:)',t);
end

% Create the function for the ode45 solver
odeFun = @(t,x) funF(x, u(t));

% Simulate the dynamics of the system with the ode45 solver
[val_t,val_x] = ode45(odeFun,tspan,x0,odeOptions);

% Calculate the output values
val_u = zeros(size(sys.u,1),numel(val_t));
val_y = zeros(size(sys.g,1),numel(val_t));
for numRow = 1:numel(val_t)
    val_u(:,numRow) = u(val_t(numRow));
    val_y(:,numRow) = funG(val_x(numRow,:),val_u(:,numRow));
end
val_y = val_y';

% Create the output variables
t = val_t';
x = val_x';
y = val_y';
u = val_u;

if(nargout == 0)
    f = figure('Name',['Simulation of system ''',sys.name,'''']);
    % Create a tabgroup for different tabs in on figure
    %     tabgp = uitabgroup(f,'Position',[0 0 1 1]);
    %
    %     %% Tabgroup for the results
    %     tab1 = uitab(tabgp,'Title','Simulationsergebnisse');
    %     % Create axes to avoid plotting behind the tabs
    %     axes('parent',tab1);
    
    ax(1) = subplot(3,1,1);
    title('Inputs');
    hold on;
    for num = 1:size(u,1)
        plot(t,u(num,:));
    end
    legendNames = cellfun(@(x){strrep(x,'_','\_')},sys.inputNames);
    legend(legendNames);
    
    ax(2) = subplot(3,1,2);
    title('States');
    hold on;
    for num = 1:size(x,1)
        plot(t,x(num,:));
    end
    legendNames = cellfun(@(x){strrep(x,'_','\_')},sys.stateNames);
    legend(legendNames);
    
    ax(3) = subplot(3,1,3);
    title('Outputs');
    hold on;
    for num = 1:size(y,1)
        plot(t,y(num,:));
    end
    legendNames = cellfun(@(x){strrep(x,'_','\_')},sys.outputNames);
    legend(legendNames);
    
    linkaxes(ax,'x');
    
    %     %% Tabgroup for other information
    %     tab1 = uitab(tabgp,'Title','Informationen');
    %     % Create axes to avoid plotting behind the tabs
    %     axes('parent',tab1);
    %     set(gca,'xtick',[])
    %     set(gca,'ytick',[])
    %     set(gca,'xticklabel',{[]});
    %     set(gca,'yticklabel',{[]});
    %
    %     % TODO
    %     paramDescription = [sys.getInfo.param(:,2:3),sys.getParam()];
    %     info = cell([size(paramDescription,1),1]);
    %     for num = 1:size(paramDescription,1)
    %         info{num} = [strrep(paramDescription{num,1},'_','\_'),' [',paramDescription{num,2},']: ',num2str(paramDescription{num,3})];
    %     end
    %     text(0.05,0.5,info)
end

end