classdef(Abstract) ODESCA_Object < matlab.mixin.Copyable & ODESCA_BaseClass
    %ODESCA_Object Class for handling parameteric IO systems
    %
    % DESCRIPTION
    %   This class is the basic class for the ODESCA framework. It stores
    %   the information about inputs, outputs and parameters including
    %   symbolic expressions, names and units.
    %    
    % PROPERTIES:
    %     name
    %     x
    %     u
    %     p
    %     param
    %     paramUnits
    %
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
    %   allParamSet = checkParam(obj)
    %   newObj = copy(obj)
    %   info = getInfo(obj)
    %   [paramValues, paramNames] = getParam(obj);
    %   isValid = isValidSymbolic(obj, symbolicExpression)
    %   setName(obj, name)
    %   setParam(obj, paramName, value)
    %
    % ---------------------------------------------------------------------
    %
    %   createdSymbolics = addParameters(obj, parameterNames, parameterUnits)
    %   initializeObject(obj)
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
    end
    
    properties(SetAccess = protected)
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
        allParamSet = checkParam(obj)
        info = getInfo(obj)
        [paramValues, paramNames] = getParam(obj, useArray);
        isValid = isValidSymbolic(obj, symbolicExpression)
        setName(obj, name)    
        setParam(obj, paramName, value) 
    end
    
    %######################################################################
    %% Protected Methods
    %######################################################################
    
    methods(Access = protected)
        createdSymbolics = addParameters(obj, parameterNames, parameterUnits)
        initializeObject(obj)
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