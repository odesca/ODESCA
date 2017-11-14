classdef(Abstract) ODESCA_Object < matlab.mixin.Copyable & ODESCA_BaseClass
    %ODESCA_Object Class for handling ordinary differential equations
    %
    % DESCRIPTION
    %   This class is the basic class for the ODESCA framework. It stores
    %   differential equation systems in the form
    %       xdot = f(x,u);
    %       y    = g(x,u);
    %   The Class provides a system to handle parameters and methodes to
    %   organize the equation system.
    %    
    % PROPERTIES:
    %     name
    %     param
    %     p
    %     paramUnits
    %     
    %     f
    %     g
    %     x
    %     u
    %     stateNames
    %     inputNames
    %     outputNames
    %     stateUnits
    %     inputUnits
    %     outputUnits
    %
    % CONSTRUCTOR:
    %   ODESCA_Object(name)
    %
    % METHODS: (Public|Protected|Private)
    %
    %   [f,g] = calculateNumericEquations(obj)
    %   allParamSet = checkParam(obj)
    %   newObj = copy(obj)
    %   info = getInfo(obj)
    %   [paramValues, paramNames] = getParamArray(obj);
    %   symStruct = getSymbolicStructure(obj)
    %   isValid = isValidSymbolic(obj, symbolicExpression)
    %
    %   show(obj, varargin)
    %   setName(obj, name)
    %   setAllParamAsInput(obj)
    %   setParamAsInput(obj, paramName)
    %   setParam(obj, paramName, value)
    %   switchOutputs(obj, out1, out2)
    %   switchInputs(obj, in1, in2)
    %
    % ---------------------------------------------------------------------
    %
    %   createdSymbolics = addParameters(obj, parameterNames, parameterUnits)
    %
    %   initializeObject(obj)
    %   removeSymbolicInput(obj, position)
    %   renameParam(obj, oldName,newName)
    %
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
    
    properties(SetAccess = private)
        
        % Stores the name of the instance of this class
        %
        % TYPE
        %   string
        %
        % DESCRIPTION
        %   This property stores the name of the instance for
        %   identification.
        %
        % NOTE
        %
        % SEE ALSO
        %
        name
        
        % Structure to store the parameters used in the equations
        %
        % TYPE
        %   structure
        %
        % DESCRIPTION
        %   This structure contains the parameter for the differential
        %   equations with their value. If they have no value they are 
        %   empty. If no parameter is added, 'param' is empty. For each 
        %   parameter in this structure there is a symbolic parameter in 
        %   the 'p' array.
        %
        % NOTE
        %   - The parameter is empty and not a structure if there are no
        %     parameters added. The structure is created in the method
        %     'addParameters()' automatically
        %
        % SEE ALSO
        %   p
        %   addParameters()
        %
        param

        % Array to store the symbolic counterparts for the parameters
        %
        % TYPE
        %   symbolic array
        %
        % DESCRIPTION
        %   This array stores the symbolic parameters which are
        %   counterparts of the parameters in the 'param' structure.
        %
        % NOTE
        %   - This array is created automatically in the method
        %     'addParameters()'.
        %
        % SEE ALSO
        %   param
        %   addParameters()
        %
        p
        
        % Cell array to store the units of the parameters
        %
        % TYPE
        %   string cell array
        %
        % DESCRIPTION
        %   This cell array stores the units of the parameters. Each unit
        %   correspondes to the parameters in the param structure by their
        %   order.
        %
        % NOTE
        %
        % SEE ALSO
        %   param
        %
        paramUnits
    end
    
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
        %   - This array is created by a subclass of ODESCA_Object.
        %
        % SEE ALSO
        %   x
        %   stateNames
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
        %   - This array is created by a subclass of ODESCA_Object.
        %
        % SEE ALSO
        %   outputNames
        %
        g
        
        % Array with the symbolic states of the system
        %
        % TYPE
        %   symbolic array
        %
        % DESCRIPTION
        %   This array stores the symbolic variables for the states of the
        %   differential equations system. Each element of the array 
        %   corresponds with the element of the property 'stateNames' with 
        %   the same index. For example x(1) is state with the name
        %   stateNames{1}.
        %
        % NOTE
        %   - This array is created by a subclass of ODESCA_Object
        %
        % SEE ALSO
        %   f
        %   stateNames
        %
        x
        
        % Array with the symbolic inputs of the system
        %
        % TYPE
        %   symbolic array
        %
        % DESCRIPTION
        %   This array stores the symbolic variables for the inputs of the
        %   differential equations system. Each element of the array 
        %   corresponds with the element of the property 'inputNames' with 
        %   the same index. For example u(1) is state with the name
        %   inputNames{1}.
        %
        % NOTE
        %   - This array is created by a subclass of ODESCA_Object
        %
        % SEE ALSO
        %   inputNames
        %
        u
        
        % Cell array to store the names of the states
        %
        % TYPE
        %   string cell array
        %
        % DESCRIPTION
        %   This cell array stores the names of the states. Each element of
        %   the array corresponds with the element of the property 'x' with
        %   the same index. For example x(1) is state with the name 
        %   stateNames{1}.
        %
        % NOTE
        %
        % SEE ALSO
        %   x
        %
        stateNames
         
        % Cell array to store the names of the inputs
        %
        % TYPE
        %   string cell array
        %
        % DESCRIPTION
        %   This cell array stores the names of the inputs. Each element of
        %   the array corresponds with the element of the property 'u' with
        %   the same index. For example u(1) is state with the name 
        %   inputNames{1}.
        %
        % NOTE
        %
        % SEE ALSO
        %   u
        %
        inputNames
            
        % Cell array to store the names of the outputs
        %
        % TYPE
        %   string cell array
        %
        % DESCRIPTION
        %
        % NOTE
        %   This cell array stores the names of the outputs. The equation
        %   for each output can be found in the array 'g' with the
        %   corresponding index. For example g(1) is the equation for
        %   outputNames{1}.
        %
        % SEE ALSO
        %   g
        %
        outputNames
        
        % Cell array to store the units of the states
        %
        % TYPE
        %   string cell array
        %
        % DESCRIPTION
        %   This cell array stores the units of the states. Each element of
        %   the array corresponds with the element of the property 'x' with
        %   the same index. For example x(1) is state with the unit 
        %   stateUnits{1}.
        %
        % NOTE
        %
        % SEE ALSO
        %   x
        %
        stateUnits
        
        % Cell array to store the units of the inputs
        %
        % TYPE
        %   string cell array
        %
        % DESCRIPTION
        %   This cell array stores the units of the states. Each element of
        %   the array corresponds with the element of the property 'u' with
        %   the same index. For example u(1) is input with the unit 
        %   inputUnits{1}.
        %
        % NOTE
        %
        % SEE ALSO
        %   u
        %
        inputUnits
        
        % Cell array to store the units of the outputs
        %
        % TYPE
        %   string cell array
        %
        % DESCRIPTION
        %   This cell array stores the units of the outputs. Each element 
        %   of the array corresponds with the element of the property 'g' 
        %   with the same index. For example g(1) is output with the unit 
        %   outputUnits{1}.
        %
        % NOTE
        %
        % SEE ALSO
        %   g
        %
        outputUnits
    end
    
    %######################################################################
    %% Constructor
    %######################################################################
    
    methods
        function obj = ODESCA_Object(name)
            % Constructor for the class ODESCA_Object()
            %
            % SYNTAX
            %   obj = ODESCA_Object(name)
            %
            % INPUT ARGUMENTS
            %   name: String to identify the object 
            %
            % OPTIONAL INPUT ARGUMENTS
            %
            % OUTPUT ARGUMENTS
            %   obj:    New instance of the class ODESCA_Object
            %
            % DESCRIPTION
            %   Initializes the properties  and returns a new instance of 
            %   the class ODESCA_Object
            %
            % NOTE
            %   - The class ODESCA_Object should not be initialized itself.
            %     It is meant to be a superclass for all classes used in 
            %     the ODESCA framework.
            %
            % SEE ALSO
            %
            % EXAMPLE
            %
            
            % Initialize the name empty
            obj.setName(name);
            
            % Initialize the properties empty
            obj.initializeObject();
        end
    end
    
    %######################################################################
    %% Public Methods
    %######################################################################
    
    methods(Access = public)      
        [f,g] = calculateNumericEquations(obj, partial)
        allParamSet = checkParam(obj)
        info = getInfo(obj)
        [paramValues, paramNames] = getParam(obj, useArray);
        symStruct = getSymbolicStructure(obj)
        isValid = isValidSymbolic(obj, symbolicExpression)
        
        show(obj, varargin)
        setName(obj, name)
        setAllParamAsInput(obj)
        setParamAsInput(obj, paramName)      
        setParam(obj, paramName, value)
        switchOutputs(obj, out1, out2)
        switchInputs(obj, in1, in2)    
        switchStates(obj, state1, state2)   
    end
    
    %######################################################################
    %% Protected Methods
    %######################################################################
    
    methods(Access = protected)
        createdSymbolics = addParameters(obj, parameterNames, parameterUnits)
        
        initializeObject(obj)
        removeSymbolicInput(obj, position)
        renameParam(obj, oldName,newName)
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
        %   ODESCA_Object. The method defines which steps should be taken
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
            %   cpObj: Copy of the ODESCA_Object obj
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