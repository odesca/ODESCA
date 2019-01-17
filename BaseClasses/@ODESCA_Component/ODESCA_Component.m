classdef(Abstract) ODESCA_Component < ODESCA_ODE
    %ODESCA_Component Class representing a component of differential equations
    %
    % DESCRIPTION
    %   This class provides basic functionalities to easily set up a system
    %   of ordinary differential equations. It modifies the fields of the
    %   superclass ODESCA_Object and provides the functionality needed to
    %   add this class to a ODESCA_System. It is meant to be used as
    %   superclass for all components which sould be added to a system.
    %
    % ODESCA_Component
    %
    % PROPERTIES:
    %   constructionParam
    %   FLAG_EquationsCalculated
    %
    % CONSTRUCTOR:
    %   ODESCA_Component(name)
    %
    % METHODS: (Public|Protected|Private)
    %
    %   allParamSet = checkConstructionParam(obj)
    %   equationsCorrect = checkEquationsCorrect(obj)
    %   newObj = copy(obj);
    %   calculationPossible = tryCalculateEquations(obj)
    %
    %   setConstructionParam(obj, paramName, value)
    %
    % ---------------------------------------------------------------------
    %
    %   addConstructionParameter(obj, parameterNames)
    %   initializeBasics(obj, stateNames, inputNames, outputNames, paramNames, stateUnits, inputUnits, outputUnits, paramUnits)
    %   prepareCreationOfEquations(obj)
    %
    %   calculateEquations(obj);
    %
    % ---------------------------------------------------------------------
    %
    % 	[]
    %
    % LISTENERS
    %
    % NOTE:
    %   - This class is abstract and cannot be instanciated directly
    %   - Subclasses should be in the form of the ODESCA_Component_Template
    %
    % SEE ALSO
    %   ODESCA_Component_Template
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


    
    %######################################################################
    %% Properties
    %######################################################################
    
    properties(SetAccess = private)
        
        % Structure of parameters needed for construction of the equations
        %
        % TYPE
        %   numeric structure
        %
        % DESCRIPTION
        %   This structure contains all parameters which are needed for the
        %   construction of the equations. The equations can not be created
        %   if not all construction parameters are set. For example the
        %   number of nodes in a pipe would be a parameter needed for the
        %   equations.
        %
        % NOTE
        %   - This structure is created by the method
        %     addConstructionParameter() automatically.
        %
        % SEE ALSO
        %   addConstructionParameter()
        %
        constructionParam
        
        % Flag to determine if the equations have been calculated
        %
        % TYPE
        %   boolean
        %
        % DESCRIPTION
        %   This flag determines if the equations of the component have
        %   been calculated. It is reset to false if the construction
        %   parameters are set. It is set to true if the method
        %   tryCalculateEquations is called successfully.
        %
        % NOTE
        %
        % SEE ALSO
        %   tryCaculateEquations()
        %
        FLAG_EquationsCalculated
    end
    
    %######################################################################
    %% Constructor
    %######################################################################
    
    methods
        function obj = ODESCA_Component(name)
            % Constructor for the class ODESCA_Component
            %
            % SYNTAX
            %   obj = ODESCA_Component()
            %
            % INPUT ARGUMENTS
            %   obj:    Instance of the object where the methode was
            %           called. This parameter is given automatically.
            %
            % OPTIONAL INPUT ARGUMENTS
            %
            % OUTPUT ARGUMENTS
            %   obj:    New instance of the class ODESCA_Component
            %
            % DESCRIPTION
            %   Initializes the properties and the listeners and returns a
            %   new instance of the class ODESCA_Component
            %
            % NOTE
            %
            % SEE ALSO
            %
            % EXAMPLE
            %
            
            % Check if a name has been given as argument. Otherwise set the
            % name to 'Default'
            if(nargin == 0)
                initialName = 'UnnamedComponent';
            else
                initialName = name;
            end
            
            % Set the name of the object
            obj = obj@ODESCA_ODE(initialName);
            
            % Initialize the properties
            obj.constructionParam = [];
            obj.FLAG_EquationsCalculated = false;
        end
    end
    
    %######################################################################
    %% Public Methods
    %######################################################################
    
    methods(Access = public)
        
        setConstructionParam(obj, paramName, value)
        
        allParamSet = checkConstructionParam(obj)
        equationsCorrect = checkEquationsCorrect(obj)
        calculationPossible = tryCalculateEquations(obj)
        
    end
    
    %######################################################################
    %% Protected Methods
    %######################################################################
    
    methods(Access = protected)
        
        addConstructionParameter(obj, parameterNames)
        initializeBasics(obj, stateNames, inputNames, outputNames, paramNames, stateUnits, inputUnits, outputUnits, paramUnits)
        prepareCreationOfEquations(obj)
        
    end
    
    methods(Access = protected)
        function reactOnEquationsChange(obj) %#ok<MANU>
            % No need to react to a change in the equations on a component
        end
    end
    
    methods(Abstract, Access = protected)
        % Abstract method to ensure the equations can be calculated
        %
        % SYNTAX
        %
        % INPUT ARGUMENTS
        %   obj:    Instance of the object where the methode was
        %           called. This parameter is given automatically.
        %
        % OPTIONAL INPUT ARGUMENTS
        %
        % OUTPUT ARGUMENTS
        %
        % DESCRIPTION
        %   This method is meant to be implemented in a subclass of
        %   ODESCA_Component. Within the method the equations should be
        %   calculated.
        %
        % NOTE
        %   - This method is called by tryCalculateEquations()
        %   - Its neseccary to have the calculation in an extra method
        %     because on initialization the construction parameters may not
        %     be set.
        %   - How to implement this method can be seen in the
        %     ODESCA_Component_Template.
        %
        % SEE ALSO
        %   tryCalculateEquations()
        %   ODESCA_Component_Template
        %
        % EXAMPLE
        %
        calculateEquations(obj);
    end
    
end