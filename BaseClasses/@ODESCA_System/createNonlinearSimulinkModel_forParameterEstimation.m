function createNonlinearSimulinkModel(sys,varargin)
% Creates a Simulink model of the ODESCA_System instance
%
% SYNTAX
%   createNonlinearSimulinkModel(sys);
%   createNonlinearSimulinkModel(sys,name,value);
%
% INPUT ARGUMENTS
%   sys:    Instance of the class ODESCA_System.
%
% INPUT ARGUMENTS
%   varargin:   Array with the name-value-pair arguments:
%
%     Options:
%     =====================================================================
%     name            |  value
%     ----------------|----------------------------------------------------
%     name            | - name of the created Simulink model
%     type            | - 'discrete' or 'continuous'
%     sampleTime      | - size of the time steps in discrete systems
%     useNumericParam | - boolean, if true all parameters have to be set
%                     |   and the equations are calculated with the numeric
%                     |   values
%     initialCondition| - numeric array which contains the initial
%                     |   condition for the states, dimension nx1 where n
%                     |   is the number of states of the system
%     optimize        | - boolean, if true the code of the
%                     |   matlabFunctionBlock used inside the model will be
%                     |   optimized for a better runtime result. If false,
%                     |   no optimization will be done
%     notopensimulin  | - is a Option for the method
%                         Parameteridentification. Does not open simulik,
%                         just loead it
%
%     NOTE: - The array has to be either empty or filled with a even number
%             of entries because their arguments has to be an option and its
%             value
%
%     Default value (choosen if the option is not given as argument)
%     =====================================================================
%     name            |  default
%     ----------------|----------------------------------------------------
%     name            | - name of the system
%     type            | - 'continuous'
%     sampleTime      | - default sample time of the system
%     useNumericParam | - false
%     initialCondition| - 0
%     optimize        | - true
%     notopensimulink | - need to be 1 
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   This function creates a Simulink model of a ODESCA_System instance and 
%   opens it. The model contains a subsystem at the top level with a mask 
%   where the initial conditions of the states and the parameters can be 
%   changed. It has all inputs and outputs of the system.
%
%   Inside the subsytem the equations are modelled in a MATLAB Function
%   Block. The states are calculated by integration over the state changes
%   starting with the initial state values.
%
%   Depending on the options the model creation changes:
%       type: The option type determines if the model is build with a
%             continuous or a discrete integrator.
%       useNumericParam: The option useNumericParam allows the creation
%                        of the MATLAB Function Block with numeric
%                        parameters. This model is a bit faster but the
%                        parameters can not be changed once the model is
%                        created.
%
% NOTE
%   - The creation of the model is ONLY possible if the system has states
%     and outputs. If one of these parts is empty the system can not
%     be created.
%   - Setting the option useNumericParam to true removes the possiblity to
%     change parameters once the model is created
%
% SEE ALSO
%   matlabFunctionBlock()
%
% EXAMPLE
%   Pipe = OCLib_Pipe('MyPipe');
%   Pipe.setConstructionParam('Nodes',2);
%   PipeSys = ODESCA_System('MySystem',Pipe);
%   PipeSys 'type','discrete','sampleTime',0.01);
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
% Check if there is at least one input argument given to the method
if( nargin < 1 )
   error('ODESCA_Util:createNonlinearSimulinkModel:noInputArguments','The method has to get at least an instance of the class ODESCA_System as first input argument.'); 
end

% Check if the input argument is a ODESCA_System
if( ~isa(sys,'ODESCA_System') )
   error('ODESCA_Util:createNonlinearSimulinkModel:firstArgumentNotAODESCA_System','The argument ''sys'' has to be an instance of the class ''ODESCA_System''.'); 
end

% =========================================================================
% Set the default arguments for the methode
% =========================================================================

systemName = sys.name;                      % Option: 'name'
type = 'continuous';                        % Option: 'type'
sampleTime = sys.defaultSampleTime;         % Option: 'sampleTime'
useNumericParam = false;                    % Option: 'useNumericParam'
initialCondition = zeros(numel(sys.x),1);   % Option: 'initialCondition'
optimizeFunctionBlock = true;               % Option: 'optimize'
notopen = 0;                                % Option: 'notopensimulink'

% =========================================================================
% Set the constants used in the method
% =========================================================================

% ----- definition of block names -----
% Name of the matlab function block
matlabFcnBlkName = 'DifferentialEquations';
% Name of demux block for x vector
xDemuxName = 'XDemux';
% Name of demux block for y vector
yDemuxName = 'YDemux';
% Name of integrator block
integratorName = 'Xdot2X';
% Name of outport for system states
outXName = 'States';

% ----- definition of block sizes -----
% Width of the matlab function block
widthFcnBlock = 150;
% Width and height of the integrator block
sizeIntegrator = 30;
% Width of the port blocks
widthPort = 30;
% Height of the port blocks
heightPort = 14;
% Height of any block per input or output
minDistancePort = 40;
% Horizontal spacing between blocks
blockSpacing = 100;
% Offset position of subsystem in first layer
offsetPos = 300;

% Width of the subsystem per character of the input and output names
widthSubsystemPerCharacter = 5;
% Constant width added to the total width of the subsystem
widthSubsystemAdditionl = 60;
% Minimum width the subsystem should have 
widthSubsystemMinimum = 200;

% =========================================================================

%% Check of the conditions
% Check if neither states or outputs are empty
if( isempty(sys.stateNames) || isempty(sys.outputNames) )
    error('ODESCA_Util:createNonlinearSimulinkModel:SystemNotComplete','There are either not states, not inputs or not outputs to the system. Therefore the simulink model can not be created.');
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
                warning('ODESCA_Util:createNonlinearSimulinkModel:optionNotAString',['The input option number ',num2str(numPair),' is not a scalar string. The option was ignored.']);
            else
                
                % Search for the input option and set the function parameter
                switch(lower(option))
                    case 'name'
                        if( ~isvarname(value) )
                            warning('ODESCA_Util:createNonlinearSimulinkModel:invalidName','The name for the model has to match the naming conventions for MATLAB variables. The default name was selected.');
                        else
                            systemName = value;
                        end
                    case 'type'
                        value = lower(value);
                        if ( ~(strcmp(value,'discrete') || strcmp(value,'continuous')) )
                            warning('ODESCA_Util:createNonlinearSimulinkModel:invalidType','Type has to be ''discrete'' or ''continuous''. The default type was selected.');
                        else
                            type = value;
                        end
                    case 'sampletime'
                        if( ~isnumeric(value) || numel(value) ~= 1)
                            warning('ODESCA_Util:createNonlinearSimulinkModel:invalidTimeStep','The sample time is not a scalar numeric value. The default sample time was selected.');
                        else
                            sampleTime = value;
                        end
                    case 'usenumericparam'
                        if ( ~isa(value, 'logical') || numel(value) ~= 1)
                            warning('ODESCA_Util:createNonlinearSimulinkModel:invalidOptionUseNumericParam','The value for ''useNumericParam'' is not a scalar logical value. The default option was selected.');
                        else
                            if( value && ~sys.checkParam())
                                error('ODESCA_Util:createNonlinearSimulinkModel:notAllParamSet','The ''useNumericParam'' option is choosen but not all parameters are set.')
                            end
                            useNumericParam = value;
                        end
                    case 'initialcondition'
                        if ( isnumeric(value) && numel(value) == numel(sys.x))
                            initialCondition = value;
                        else
                            error('ODESCA_Util:createNonlinearSimulinkModel:invalidInitialCondition','The initial condition has to be a numeric array that matches the number of states of the system.');
                        end   
                    case 'optimize'
                        if ( ~isa(value, 'logical') || numel(value) ~= 1)
                            warning('ODESCA_Util:createNonlinearSimulinkModel:invalidOptionOptimize','The value for ''optimize'' is not a scalar logical value. The default option was selected.');
                        else
                           optimizeFunctionBlock = value; 
                        end
                    case 'notopensimulink'
                       if ( value ~= 1)
                           warning('ODESCA_Util:createNonlinearSimulinkModel:invalidOptionOptimize','The value for ''notopensimulink'' is not 1. The default option was selected.');
                       else
                          notopen = value; 
                       end
                    otherwise
                        warning('ODESCA_Util:createNonlinearSimulinkModel:invalidInputOption',['The option ''',option,''' does not exist.']);
                end
            end
        end
    else
        % Throw error if the number of arguments is not even
        error('ODESCA_Util:createNonlinearSimulinkModel:oddNumberOfInputArguments','The input arguments of this method has to come in name-value pairs and not in an odd number.');
    end
end

% Check if there is a simulink model with the same name already loaded
if( bdIsLoaded(systemName) )
    error('ODESCA_Util:createNonlinearSimulinkModel:simulinkModelNameConflict', ...
        'A simulink model with the name ''%s'' is already loaded.\nClose the loaded model [ close_system(''%s'') ] or choose a new name for model creation to proceed.',systemName,systemName);
end

%% Evaluation of the task
% ===== Preperation for the model creation ================================

% Get the number of inputs, states and outputs of the system
numInputs = numel(sys.u);
numStates = numel(sys.x);
numOutputs = numel(sys.g);

% Define info structurs for naming the states, inputs and outputs
info = sys.getInfo();

% Length of the longest output name
charactersOutputs = max(cellfun(@length, info.outputs(:,2)));

% Width the position of the outputs has to be increased in first layer
outputPosAdd = charactersOutputs * 2;

if numInputs
    % Length of the longest input name
    charactersInputs = max(cellfun(@length, info.inputs(:,2)));

    % Width the position of the inputs has to be decreased in first layer
    inputPosSub = charactersInputs * 2;
else
    % If there are no inputs
    charactersInputs = 0;
end

% Height of subsystem in first layer
heightSubsystem = minDistancePort * max(numInputs,numOutputs+1);
% Width of subsystem in first layer
widthSubsystem = (charactersInputs + charactersOutputs) ...
    * widthSubsystemPerCharacter + widthSubsystemAdditionl;
% Set the minimum width of the subsystem if the calculated width is below
widthSubsystem = max(widthSubsystem, widthSubsystemMinimum);


%% ===== Simulink model generation ========================================
% Create and load new Simulink model ( invisible while the time of creation )
new_system(systemName)
load_system(systemName)

% Surround the creation with try-catch-block to have the possibility to
% close the model if an error occurres.
try
    % Activate Inlineparameters for use in Model-Reference-Block
    set_param(systemName,'InlineParams','on')
    
    %% Create subsystem
    add_block('simulink/Ports & Subsystems/Subsystem',[systemName,'/',systemName],...
        'position',[offsetPos, offsetPos,...
        offsetPos + widthSubsystem, offsetPos + heightSubsystem]);
    
    % Remove all standart components of the subsystem
    delete_line([systemName,'/',systemName],'In1/1','Out1/1');
    delete_block([systemName,'/',systemName,'/In1']);
    delete_block([systemName,'/',systemName,'/Out1']);
    
    %% Mask the subsystem
    hMask = Simulink.Mask.create([systemName,'/',systemName]);
    
    
    % Add a description to the mask
    if(~isempty(sys.param))
        numParam = numel(fieldnames(sys.param));
    else
        numParam = 0;
    end
    hMask.set('Type',systemName,'Description',...
        [sprintf('This system consists of: \n\n'),...
        sprintf('%s Components \n', num2str(numel(sys.components))),...
        sprintf('%s States \n', num2str(numel(sys.x))),...
        sprintf('%s Inputs \n', num2str(numel(sys.u))),...
        sprintf('%s Outputs \n', num2str(numel(sys.g))),...
        sprintf('%s Parameters \n', num2str(numParam))]);
    
    % Add field for sample time if the system is discrete
    if ~strcmp(type,'continuous')
        hMask.addParameter('Name','Ts','Prompt','Sampling Time',...
            'Value',num2str(sampleTime),'TabName','System Properties');
    end
    
    % Calculate the string of the initial conditions of the states
    initialString = '[';
    for i = 1:(numel(sys.x)-1)
       initialString = [initialString,num2str(initialCondition(i)),','];  %#ok<AGROW>
    end
    initialString = [initialString,num2str(initialCondition(numel(sys.x))),']'];
    
    % Add tab for initial state values
    maskDesc = shiftdim(info.states,1);
    hMask.addParameter('Name','initState','Prompt',[sprintf('Initial State is a column vector of %s elements:\n\n',...
        num2str(length(info.states))),...
        sprintf('%s = %s [%s]\n',maskDesc{:}),...
        sprintf('\nInitial State:')],...
        'Value',initialString,'TabName','Initial Conditions');
    
    % Add the parameter tabs if the parameters are not forced as values
    if( ~useNumericParam )
        if( ~isempty(sys.param) )
            % Add tabs for parameter
            paramNames = fieldnames(sys.param);
            for paramNum = 1:numel(paramNames)
                fullName = paramNames{paramNum};
                % search for the component name inside fullName
                for componentNum = 1:numel(sys.components)
                    if contains(fullName,sys.components{componentNum})
                        break;
                    end
                end
                tab = sys.components{componentNum};
                name = fullName(length(tab)+2:end);
                unit = sys.paramUnits{paramNum};
                value = sys.param.(fullName);
                promt = [name,newline,'[',unit,']'];
                
                % Add the parameter to the mask
                hMask.addParameter('Name',fullName,'Prompt', promt,...
                    'Value',num2str(value),'TabName',tab);
            end
        end
    end
    
    %% create matlab function block
    % Check if numeric parameters should be used
    if( useNumericParam )
        [numericF,numericG] = sys.calculateNumericEquations();
        % Create matlab function block with all parameters as numeric values
        matlabFunctionBlock([systemName,'/',systemName,'/',matlabFcnBlkName],numericF,numericG,...
            'vars',[sys.x;sys.u],'outputs',{'f','g'})
    else % If the numeric parameters are not mandatory ...
        
        if( ~isempty(sys.param) )
            % List with the names of the parameters
            paramNames = fieldnames(sys.param);
            
            
            % Create list of parameter for adding them as parameters to the
            % MATLAB Function Block
            paramForFunctionBlock = {};
            paramCount = 1; % Count number parameters for function block
            for num = 1:numel(paramNames)
                paramForFunctionBlock{paramCount,1} = sys.p(num); %#ok<AGROW>
                paramCount = paramCount + 1;
            end
        else
            paramForFunctionBlock = {};
        end
        
        % create matlab function block with parameters from the mask and
        % symbolic parameters
        % NOTE:
        %   - The creation of the matlab function block with the method
        %     matlabFunctionBlock() is extremly slow. It takes half of the
        %     total runtime of this method
        matlabFunctionBlock([systemName,'/',systemName,'/',matlabFcnBlkName],sys.f,sys.g,...
            'vars',[sys.x;sys.u;paramForFunctionBlock],'outputs',{'f','g'},'Optimize',optimizeFunctionBlock)
        
        if( ~isempty(sys.param) )
            % Get stateflow root object (root for every stateflow object)
            S = sfroot();
            % Get Stateflow.EMChart for the MatlabFunktionBlock
            B = S.find('Name','DifferentialEquations','-isa','Stateflow.EMChart');
            
            % Check if there is more than one Stateflow.EMChart with the
            % given search parameters in the stateflow root.
            if( numel(B) > 1 )
                % Find the correct Stateflow.EMChart
                Inputs = [];
                for num = 1:numel(B)
                    EMChart = B(num);
                    % Check if the current EMChart has the correct path
                    if(strcmp([systemName,'/',systemName,'/',matlabFcnBlkName],EMChart.Path))
                       Inputs = EMChart.Inputs;
                    end
                end
                
                % Throw an error if the correct stateflow EMChart was not
                % found
                if(isempty(Inputs))
                   error('ODESCA_Util:createNonlinearSimulinkModel:StateflowEMChartNotFound','The stateflow EMChart for the MatlabFunktionBlock of the created Model was not found.'); 
                end
            else
            % Get the list of Inputs
            Inputs = B.Inputs;
            end
            
            % Check for each input if it is a parameter and set the scope of
            % the input to be a parameter searched in the workspace inside the
            % mask of the subsystem containing the function block
            %
            % NOTE:
            %   - The function block will search for the parameter in the
            %     matlab workspace if it is not found in the workspace of the
            %     mask of the subsystem
            %   - See WARNING above!
            %   - This loop is extremly slow! It takes about 1/3 of the total
            %     runtime of this method
            for numInputsB = numel(Inputs):-1:1
                in = Inputs(numInputsB);
                if( ismember(in.Name, paramNames) )
                    set(Inputs(numInputsB),'Scope','Parameter');
                end
            end
        end
    end
    
    % resize matlab function block according to number of inputs to the block
    fcnBlkPos = [offsetPos,offsetPos,offsetPos + widthFcnBlock,...
        offsetPos + minDistancePort * (numInputs + numStates)];
    set_param([systemName,'/',systemName,'/',matlabFcnBlkName],'position',fcnBlkPos);
    
    %% Create Ports and route the signals
    % Check if the system has inputs
    if numInputs
        % add inports, calculate their positions and connect them to the
        % matlab function block
        for i = 1:numInputs
            inputName = ['In_',info.inputs{i,2}];
            % first layer inputs
            add_block('built-in/Inport',[systemName,'/',inputName],'Position',...
                [offsetPos - blockSpacing - inputPosSub,...
                offsetPos + (2*i-1)*heightSubsystem/(2*numInputs) - heightPort/2, ...
                offsetPos - blockSpacing - inputPosSub + widthPort, ...
                offsetPos + (2*i-1)*heightSubsystem/(2*numInputs) + heightPort/2]);
            % second layer inputs
            add_block('built-in/Inport',[systemName,'/',systemName,'/',inputName]);
            inputPos = [fcnBlkPos(1) - blockSpacing*2,...
                fcnBlkPos(2) + minDistancePort * (numStates + i - 1) + ...
                heightPort, ...
                fcnBlkPos(1) - blockSpacing*2 + widthPort, ...
                fcnBlkPos(2) + minDistancePort * (numStates + i - 1) + ...
                2*heightPort];
            set_param([systemName,'/',systemName,'/',inputName],'Position',inputPos);
            % routing of first layer
            add_line(systemName,[inputName,'/1'],...
                [systemName,'/',num2str(i)],...
                'autorouting','on');
            % routing of second layer
            add_line([systemName,'/',systemName],[inputName,'/1'],...
                [matlabFcnBlkName,'/',num2str(i + numStates)],...
                'autorouting','on');
        end
    end
    
    % Create the outputs of the system
    % calculate position and size of demux block for y vector
    yDemuxPos = [fcnBlkPos(3) + blockSpacing, ...
        fcnBlkPos(2) + (fcnBlkPos(4) - fcnBlkPos(2)) * 3 / 4 - ...
        (minDistancePort * numOutputs)/2,...
        fcnBlkPos(3) + blockSpacing + 5,...
        fcnBlkPos(2) + (fcnBlkPos(4) - fcnBlkPos(2)) * 3 / 4 + ...
        (minDistancePort * numOutputs)/2];
    
    % add demux block for y vector
    add_block('built-in/Demux',[systemName,'/',systemName,'/',yDemuxName],'position',...
        yDemuxPos,'Outputs',num2str(numOutputs),'DisplayOption','bar')
    
    % connect matlab function block second output with y demux
    add_line([systemName,'/',systemName],[matlabFcnBlkName,'/2'],[yDemuxName,'/1'],...
        'autorouting','on');
    
    % create outports for y vector and connect them with y demux
    for i = 1:numOutputs
        outputName = ['Out_',info.outputs{i,2}];
        % first layer outputs
        add_block('built-in/Outport',[systemName,'/',outputName],'Position',...
            [offsetPos + widthSubsystem + blockSpacing + outputPosAdd,...
            offsetPos + (2*i-1)*heightSubsystem/(2*(numOutputs+1)) - heightPort/2, ...
            offsetPos + widthSubsystem + blockSpacing + outputPosAdd + widthPort, ...
            offsetPos + (2*i-1)*heightSubsystem/(2*(numOutputs+1)) + heightPort/2]);
        % second layer outputs
        add_block('built-in/Outport',[systemName,'/',systemName,'/',outputName]);
        outputPos = [fcnBlkPos(3) + blockSpacing*2,...
            yDemuxPos(2)+minDistancePort/2+minDistancePort*(i-1)-heightPort/2,...
            fcnBlkPos(3)+blockSpacing*2+widthPort,...
            yDemuxPos(2)+minDistancePort/2+minDistancePort*(i-1)+heightPort/2];
        set_param([systemName,'/',systemName,'/',outputName],'Position',outputPos);
        % routing of first layer
        add_line(systemName,[systemName,'/',num2str(i)],...
            [outputName,'/1'],...
            'autorouting','on');
        % routing of second layer
        add_line([systemName,'/',systemName],[yDemuxName,'/',num2str(i)],...
            [outputName,'/1'],'autorouting','on');
    end
    
    
    %% Create integrator block and demux and route these components
    % calculate position and size of demux block for x vector
    xDemuxPos = [fcnBlkPos(1) - blockSpacing,fcnBlkPos(2),...
        fcnBlkPos(1) - blockSpacing + 5,...
        fcnBlkPos(4) - minDistancePort * numInputs ];
    
    % add demux block for x vector
    add_block('built-in/Demux',[systemName,'/',systemName,'/',xDemuxName],'position',xDemuxPos,...
        'Outputs',num2str(numStates),'DisplayOption','bar')
    
    % connect outputs of x demux with matlab function block
    for i = 1:numStates
        add_line([systemName,'/',systemName],[xDemuxName,'/',num2str(i)],...
            [matlabFcnBlkName,'/',num2str(i)],'autorouting','on');
    end
    
    % calculate position and size of integrator block
    integratorPos = ...
        [fcnBlkPos(1) + (fcnBlkPos(3) - fcnBlkPos(1) - sizeIntegrator) / 2,...
        fcnBlkPos(2) - blockSpacing,...
        fcnBlkPos(1) + (fcnBlkPos(3) - fcnBlkPos(1) + sizeIntegrator) / 2,...
        fcnBlkPos(2) - blockSpacing + sizeIntegrator];
    
    % add integrator block and set InitialCondition to mask parameter
    if strcmp(type,'continuous')
        add_block('built-in/Integrator',[systemName,'/',systemName,'/',integratorName],'position',...
            integratorPos,'Orientation','left','InitialCondition','initState');
    elseif strcmp(type,'discrete')
        add_block('simulink/Discrete/Discrete-Time Integrator',...
            [systemName,'/',systemName,'/',integratorName],'position',integratorPos,'Orientation',...
            'left','InitialCondition','initState','gainval','1.0',...
            'SampleTime','Ts');
    end
    
    % connect matlab function block with integrator block
    add_line([systemName,'/',systemName],[matlabFcnBlkName,'/1'],[integratorName,'/1'],...
        'autorouting','on');
    
    % connect integrator block with x demux
    add_line([systemName,'/',systemName],[integratorName,'/1'],[xDemuxName,'/1'],'autorouting','on');
    
    % calculate position and size of outport for x vector
    outXPos = [fcnBlkPos(3) + blockSpacing,...
        integratorPos(2) - blockSpacing - heightPort / 2,...
        fcnBlkPos(3) + blockSpacing + widthPort,...
        integratorPos(2) - blockSpacing + heightPort / 2];
    
    % add outport for x vector
    add_block('built-in/Outport',[systemName,'/',outXName],'position',...
        [offsetPos + widthSubsystem + blockSpacing + outputPosAdd,...
        offsetPos + (2*(numOutputs+1)-1)*heightSubsystem/(2*(numOutputs+1)) - heightPort/2, ...
        offsetPos + widthSubsystem + blockSpacing + outputPosAdd + widthPort, ...
        offsetPos + (2*(numOutputs+1)-1)*heightSubsystem/(2*(numOutputs+1)) + heightPort/2]);
    add_block('built-in/Outport',[systemName,'/',systemName,'/',outXName],'position',outXPos)
    
    % connect integrator with outport for x vector
    add_line(systemName,[systemName,'/',num2str(numOutputs+1)],[outXName,'/1'],'autorouting','on');
    add_line([systemName,'/',systemName],[integratorName,'/1'],[outXName,'/1'],'autorouting','on');
    
catch err
    % Close the model if the model creation failed
    close_system(systemName,0);
    rethrow(err);
end

% Open the created system after the creation is finished
if notopen == 1
    load_system(systemName);
else
    open_system(systemName);
end
end