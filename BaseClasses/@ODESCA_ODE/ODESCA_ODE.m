classdef(Abstract) ODESCA_ODE < ODESCA_Object
    %ODESCA_ODE Class for handling ordinary differential equations
    %
    % DESCRIPTION
    %   This class is the basic class for an ODE Object. It stores
    %   differential equation systems in the form
    %       xdot = f(x,u);
    %       y    = g(x,u);
    %   The Class provides a system to handle parameters and methods to
    %   organize the equation system.
    %    
    % PROPERTIES:  
    %     f
    %     g
    %
    % CONSTRUCTOR:
    %   ODESCA_ODE(name)
    %
    % METHODS: (Public|Protected|Private)
    %
    %   [f,g] = calculateNumericEquations(obj)
    %   newObj = copyElement(obj)
    %   show(obj, varargin)
    %   setAllParamAsInput(obj)
    %   setParamAsInput(obj, paramName)
    %   switchOutputs(obj, out1, out2)
    %   switchInputs(obj, in1, in2)
    %   switchStates(obj, state1, state2) 
    %   symStruct = getSymbolicStructure(obj)
    %
    % ---------------------------------------------------------------------
    %
    %   initializeODE(obj)
    %   removeSymbolicInput(obj, position)
    %   renameParam(obj, oldName,newName)
    %   removeParam(obj, parameter)
    %   reactOnEquationsChange(obj);
    %
    % ---------------------------------------------------------------------
    %       
    %   []
    %
    % LISTENERS
    %
    % NOTE:
    %   - This Class is meant to be used as superclass and not to be
    %     instanced itself.
    %   - The protected properties are meant to be changed inside a sub
    %     class in a way depending on the function of the subclass
    %
    % SEE ALSO
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
    
    properties(SetAccess = protected)
        % Array with the symbolic equations for the state changes
        %
        % TYPE
        %   symbolic array
        %
        % DESCRIPTION
        %   This array stores the symbolic equations which describe the
        %   change of the states in the form of
        %       xdot = f(x,y)
        %   Each element of the array corresponds with the element of the
        %   property 'x' and the property 'stateNames' with the same index. 
        %   For example f(1) is the equation for the derivative of x(1) or
        %   stateNames{1}.
        %
        % NOTE
        %   - This array is created by a subclass of ODESCA_ODE.
        %
        % SEE ALSO
        %
        f
        
        % Array with the symbolic equations for the outputs
        %
        % TYPE
        %   symbolic array
        %
        % DESCRIPTION
        %   This array stores the symbolic equations which describe the
        %   outputs of the system in the form of
        %       y = g(x,y)
        %   Each element of the array corresponds with the element of the
        %   property 'outputNames' with the same index. For example g(1) 
        %   is the equation for outputNames{1}.
        %
        % NOTE
        %   - This array is created by a subclass of ODESCA_ODE.
        %
        % SEE ALSO
        %
        g
    end
    
    %######################################################################
    %% Constructor
    %######################################################################
    
    methods
        function obj = ODESCA_ODE(name)
            % Constructor for the class ODESCA_ODE()
            %
            % SYNTAX
            %   obj = ODESCA_ODE(name)
            %
            % INPUT ARGUMENTS
            %   name: String to identify the object 
            %
            % OPTIONAL INPUT ARGUMENTS
            %
            % OUTPUT ARGUMENTS
            %   obj:    New instance of the class ODESCA_ODE
            %
            % DESCRIPTION
            %   Initializes the properties  and returns a new instance of 
            %   the class ODESCA_ODE
            %
            % NOTE
            %   - The class ODESCA_ODE should not be initialized itself.
            %     It is meant to be a superclass for all classes used in 
            %     the ODESCA framework.
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
            
            % Initialize the name empty
            obj = obj@ODESCA_Object(initialName);
            
            % Initialize the properties empty
            obj.initializeODE();
        end
    end
    
    %######################################################################
    %% Public Methods
    %######################################################################
    
    methods(Access = public)      
        [f,g] = calculateNumericEquations(obj, partial)
        show(obj, varargin)
        setAllParamAsInput(obj)
        setParamAsInput(obj, paramName)
        switchOutputs(obj, out1, out2)
        switchInputs(obj, in1, in2)    
        switchStates(obj, state1, state2)   
        symStruct = getSymbolicStructure(obj)
    end
    
    %######################################################################
    %% Protected Methods
    %######################################################################
    
    methods(Access = protected)
        initializeODE(obj)
        removeSymbolicInput(obj, position)
        renameParam(obj, oldName,newName)
        removeParam(obj, parameter)
    end
    
    methods(Abstract, Access = protected)
        % Abstract method called if parts of the euqations are changed
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
        %   ODESCA_ODE. The method defines which steps should be taken
        %   on a change of parts of the equations
        %
        % NOTE
        %
        % SEE ALSO
        %
        % EXAMPLE
        %
        reactOnEquationsChange(obj);
    end
    
    %######################################################################
    %% Method Overwrite
    %######################################################################
    
    methods(Access = protected)
        function cpObj = copyElement(obj)
            % Overwrite the copyElement()-Method of matlab.mixin.Copyable
            %
            % SYNTAX
            %   cpObj = obj.copyElement()
            %
            % INPUT ARGUMENTS
            %   obj:    Instance of the object where the methode was
            %           called. This parameter is given automatically.
            %
            % OPTIONAL INPUT ARGUMENTS
            %
            % OUTPUT ARGUMENTS
            %   cpObj: Copy of the ODESCA_ODE obj
            %
            % DESCRIPTION
            %   This method overwrites the copyElement()-Method of
            %   matlab.mixin.Copyable. 
            %
            % NOTE
            %
            % SEE ALSO
            %
            % EXAMPLE
            %
            
            % Call the copyElement()-Method of the superclass
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            
        end
    end
    
end