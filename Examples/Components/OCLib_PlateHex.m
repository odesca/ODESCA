classdef OCLib_PlateHex < ODESCA_Component
    % DESCRIPTION
    %   The plate heat exchanger influences the behaviour of the domestic
    %   hot water heating significantly. The component is divided into a
    %   hot and a cold side, which again is divided into a number of Nodes
    %   n on each side. The heat exchanger can only be modeled in
    %   counter-current flow.
    %   Node numbering is defined as follows::
    %       ------------------------------
    %   --> |  1  |  2  |  3  | ... | n  | -->
    %       ------------------------------   
    %   <-- | n+1 | n+2 | n+3 | ... | 2n | <--
    %       ------------------------------
    %
    % PROPERTIES:
    %
    % CONSTRUCTOR:
    %   obj = OCLib_PlateHex()
    %
    % METHODS:
    %
    % LISTENERS:
    %
    % NOTE:
    %
    % SEE ALSO
    %
    
    % FILE
    %
    % USED FILES
    %
    % AUTHOR
    %    T. Grunert
    %    IR-E, Model-based Software Design
    %    VAILLANT, Remscheid/Germany
    %    - www.vaillant.de -
    %
    % CREATED
    %    2016-Mai-10
    %
    % VERSION CONTROL
    %    $Rev:
    %    $Date:
    %    $Author:
    %
    % © 2016 by Vaillant Group
    % All rights reserved.
    
    properties
    end
    
    methods
        function obj = OCLib_PlateHex(name)
            % Constructor of the component
            %
            % SYNTAX
            %   obj = OCLib_PlateHex();
            %
            % INPUT ARGUMENTS
            %
            % OPTIONAL INPUT ARGUMENTS
            %
            % OUTPUT ARGUMENTS
            %   obj: new instance of the class
            %
            % DESCRIPTION
            %   In the constructor the construction parameters needed for
            %   the calculation of the equations has to be specified.
            %
            % NOTE
            %
            % SEE ALSO
            %
            % EXAMPLE
            %
            
            % Set the name if a name was given
            if( nargin == 1 )
                obj.setName(name);
            end
            
            % ---- Instruction ----
            % Define the construction parameters which are needed for the
            % creation of the equations by filling in the names of the
            % construction parameters in the array below. If you don't want
            % to have construction parameters just leave the array empty.
            %
            % NOTE: To access the construction parameter in the sections
            % below use the command:
            %       obj.constructionParam.PARAMETERNAME
            %==============================================================
            %% DEFINITION OF CONSTRUCTION PARAMETERS (User editable)
            %==============================================================          
            
            constructionParamNames = {'Nodes'};
            
            %==============================================================
            %% Template Code
            obj.addConstructionParameter(constructionParamNames);
            if(isempty(constructionParamNames))
                obj.tryCalculateEquations();
            end 
        end
    end
    
    methods(Access = protected)
        function calculateEquations(obj)
            % Calculates the equations of the component
            %
            % SYNTAX
            %
            % INPUT ARGUMENTS
            %   obj:    Instance of the object where the method was
            %           called. This parameter is given automatically.
            %
            % OPTIONAL INPUT ARGUMENTS
            %
            % OUTPUT ARGUMENTS
            %
            % DESCRIPTION
            %   In this method the states, inputs, outputs and parameters
            %   are defined and the equations of the component are
            %   calculated.
            %
            % NOTE
            %   - This method is called by the method
            %     tryCalculateEquations() to avoid a call if not all
            %     construction parameters are set.
            %
            % SEE ALSO
            %
            % EXAMPLE
            %
            
            % ---- Instruction ----
            % Define the states, inputs, outputs and parameters in the
            % arrays below by filling in their names as strings. If you
            % don't want states, inputs or parameters, just leave the array
            % empty. It is not possible to create a component without
            % outputs. 
            % The corresponding arrays contain the unit strings for the 
            % states, inputs, outputs and parameters. These arrays must 
            % have the same size as the name arrays!
            %==============================================================
            %% DEFINITION OF EQUATION COMPONENTS (User editable)
            %==============================================================
            
            stateNames  = cellstr('');
            stateUnits  = cellstr('');
            for k = 1:obj.constructionParam.Nodes*2
                
               stateNames{k, 1} = ['Temperature', num2str(k)];
               stateUnits{k, 1} = '°C';
               
            end
            
            inputNames  = {'Temperature1In', 'Temperature2In', 'Massflow1In', 'Massflow2In','kHex'};
            inputUnits  = {'°C', '°C', 'kg/s', 'kg/s', 'W/m^2*K'};
            
            outputNames = {'Temperature1Out', 'Temperature2Out', 'Massflow1Out', 'Massflow2Out'};
            outputUnits = {'°C', '°C', 'kg/s', 'kg/s'};
            
            paramNames  = {'cHex', 'mHex', 'Volume1', 'Volume2', 'HexArea', 'RhoFluid', 'cFluid'};
            paramUnits  = {'J/kg*K', 'kg',  'm^3', 'm^3', 'm^2', 'kg/m^3', 'J/kg*K'};
            
            % =============================================================
            %% Template Code
            obj.initializeBasics(stateNames, inputNames, outputNames,...
                paramNames, stateUnits, inputUnits, outputUnits, paramUnits);
            obj.prepareCreationOfEquations();
            %
            %
            % ---- Instruction ----
            % Use 'obj.f(NUM)' for the state equations and 'obj.g(NUM) for 
            % the output equations e.g. obj.f(1) = ... to access state x1
            %
            % All parameters, states and inputs are in the function
            % workspace so if e.g. a paramter with the name 'radius' is
            % defined you can use the variable 'radius' without further
            % definition. You can also access the states by 'obj.x(NUM)', 
            % the inputs by 'obj.u(NUM)' and the parameter in the order
            % of the list paramNames by using 'obj.p(NUM)' where NUM
            % is the position.
            % Note that every component must have at least one output.
            %==============================================================
            %% DEFINITION OF EQUATIONS (User Editable)
            %==============================================================
             
            Nodes = obj.constructionParam.Nodes;
                     
            mHexNode = mHex / Nodes;
            Volume1Node = Volume1 / Nodes;
            Volume2Node = Volume2 / Nodes;
            HexAreaNode = HexArea / Nodes;
            
            CFluid1Node = RhoFluid * cFluid * Volume1Node;
            CFluid2Node = RhoFluid * cFluid * Volume2Node;
            
            CHexNode = cHex * mHexNode / 2;
                         
            for i = 1:Nodes
                if i == 1
                    HeatTransport1 = Massflow1In * cFluid * (Temperature1In - obj.x(1));
                else
                    HeatTransport1 = Massflow1In * cFluid * (obj.x(i - 1) - obj.x(i));
                end
                HeatExchange1 = kHex * HexAreaNode * (obj.x(Nodes + i) - obj.x(i));

                obj.f(i) = (HeatTransport1 + HeatExchange1) / (CHexNode + CFluid1Node);
            end

            for i = (Nodes+1):(Nodes*2)
                if i == (Nodes*2)
                    HeatTransport2 = Massflow2In * cFluid * (Temperature2In - obj.x(Nodes*2));
                else
                    HeatTransport2 = Massflow2In * cFluid * (obj.x(i + 1) - obj.x(i));
                end
                HeatExchange2 = kHex * HexAreaNode * (obj.x(i - Nodes) - obj.x(i));

                obj.f(i) = (HeatTransport2 + HeatExchange2) / (CHexNode + CFluid2Node);
            end

            obj.g(1) = obj.x(Nodes);
            obj.g(2) = obj.x(Nodes+1);
            obj.g(3) = Massflow1In;
            obj.g(4) = Massflow2In;

            %==============================================================
        end
    end
end