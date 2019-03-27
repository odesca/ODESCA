classdef OCLib_HeatTransferFit < ODESCA_Component
    % DESCRIPTION
    %   This component represents a static data fit for a heat transfer
    %   coefficient for a plate heat exchanger of the following form:
    %   k = c1 + c2*m_dot1 + c3*m_dot2
    %   There are no states
    %
    % PROPERTIES:
    %
    % CONSTRUCTOR:
    %   obj = OCLib_HeatTransferFit()
    %
    % METHODS:
    %
    % LISTENERS:
    %
    % NOTE:
    %   - It is possible to have components without states, inputs or
    %     without parameters.
    %   - Every component has to have at least one output.
    %
    % SEE ALSO
    %
    
    % FILE
    %
    % USED FILES
    %
    % AUTHOR
    %    C. Michalik
    %    IR-E, Model-based Software Design
    %    VAILLANT, Remscheid/Germany
    %    - www.vaillant.de -
    %
    % CREATED
    %    2017-Oct-16
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
        function obj = OCLib_HeatTransferFit(name)
            % Constructor of the component
            %
            % SYNTAX
            %   obj = OCLib_HeatTransferFit();
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
            
            constructionParamNames = {};
            
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
            
            stateNames  = {};
            stateUnits  = {};
            
            inputNames  = {'Massflow1In', 'Massflow2In'};
            inputUnits  = {'kg/s'       , 'kg/s'       };
            
            outputNames = {'k_Hex'   , 'Massflow1Out', 'Massflow2Out'};
            outputUnits = {'W/m^2*K' , 'kg/s'        , 'kg/s'        };
            
            paramNames  = {'c1'      , 'c2'          , 'c3'          };
            paramUnits  = {'W/m^2*K)', 'W*s/m^2*K*kg', 'W*s/m^2*K*kg'};
            
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
             
            obj.g(1) = c1 + c2*Massflow1In + c3*Massflow2In;
            
            obj.g(2) = Massflow1In;
            
            obj.g(3) = Massflow2In;
            
            %==============================================================
        end
    end
end