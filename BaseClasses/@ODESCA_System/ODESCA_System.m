classdef ODESCA_System < ODESCA_ODE
    %ODESCA_System Class for creation and analysis of ordinary differential equations systems
    %
    % DESCRIPTION
    %   This class represents a dynamic system of the form
    %       xdot = f(x,u);
    %       y    = g(x,u);
    %   The equations are created by adding components to the system and
    %   connecting the different equations of the components. 
    %   The system is the base for all analysis functions in ODESCA. It
    %   provides the possibility to work with steady states and approximate
    %   the system in the steady states.
    %
    % ODESCA_System
    %
    % PROPERTIES:
    %   defaultSampleTime
    %   components
    %   steadyStates
    %
    % CONSTRUCTOR:
    %   ODESCA_System(name, comp)
    %
    % METHODS:
    %   addComponent(sys, comp)
    %   addSystem(rootSys, newSys)
    %   connectInput(sys, toConnect, connection )
    %   equalizeParam(obj, paramName1, paramName2)
    %   createNonlinearSimulinkModel(sys,varargin)
    %   removeOutput(sys, toRemove)
    %   removeSteadyState(sys, toRemove)
    %   renameComponent(sys, oldName, newName)
    %   setDefaultSampleTime(sys, time)
    %   setFirstSteadyState(sys, name)
    %   show(sys, varargin)     
    %    
    %   [funF, funG] = createMatlabFunction(sys,varargin)
    %   [newSteadyState, valid] = createSteadyState(sys, x0, u0, name)
    %   [newControlAffineSystem, approxflag] = createControlAffineSystem(sys,timeConst)
    %   [t,x,y] = simulateStep(sys, tspan, x0, u0, varargin)
    %   [A,B,C,D] = symLinearize(sys)
    %
    % LISTENERS
    %
    % NOTE:
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
         % Default size of a time step for discrete systems
        %
        % TYPE
        %   numeric
        %
        % DESCRIPTION
        %   This propertie holds the default size of a single time step for
        %   a time discret systems. It is zero by default.
        %
        % NOTE
        %   - If defaultTimeStep is zero there is no default step size for
        %     discret systems spezified
        %
        % SEE ALSO
        %
        defaultSampleTime
        
        % Names of components which have been added to the system
        %
        % TYPE
        %   string cell array
        %
        % DESCRIPTION
        %   This property stores the names of the components which have
        %   been added to the system.
        %
        % NOTE
        %   - This array is created and filled in the function
        %     addComponent() automatically.
        %
        % SEE ALSO
        %
        components
    end
    
    properties(SetAccess = private, NonCopyable = true)
        % List of steady states linked to the system
        %
        % TYPE
        %   ODESCA_SteadyState array
        %
        % DESCRIPTION
        %   This array stores all steady state operation points attached to
        %   the sysem.
        %
        % NOTE
        %   - For default the first element of the array is used in any
        %     operations where a steady state is needed.
        %
        % SEE ALSO
        %
        steadyStates
        
        % List of all valid steady states
        %
        % TYPE
        %   ODESCA_validSteadyState structure
        %
        % DESCRIPTION
        %   This structure stores all valid steady state operation points.
        %
        % NOTE
        %
        % SEE ALSO
        %
        validSteadyStates
    end
    
    %######################################################################
    %% Constructor
    %######################################################################
    
    methods
        function obj = ODESCA_System(name, comp)
            % Constructor of the class ODESCA_System
            %
            % SYNTAX
            %   obj = ODESCA_System()
            %
            % INPUT ARGUMENTS
            %   name: name the system should have
            %   comp: first component to be added
            %
            % OPTIONAL INPUT ARGUMENTS
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
            %
            
            % Check if a name has been given as argument
            if(nargin == 0)
                initialName = 'System';
            else
                initialName = name;
            end
            
            % Set the name of the object
            obj = obj@ODESCA_ODE(initialName);
            
            % Initialize properties
            obj.defaultSampleTime = 1;
            obj.components = {};
            
            % Add the first component if it is given
            if(nargin == 2)
                obj.addComponent(comp);
            end
        end
    end
    
    %######################################################################
    %% Public Methods
    %######################################################################
    
    methods(Access = public)
        
        addComponent(sys, comp)
        addSystem(rootSys, newSys)
        connectInput(sys, toConnect, connection )
        equalizeParam(obj, paramName1, paramName2)
        createNonlinearSimulinkModel(sys, varargin)
        removeOutput(sys, toRemove)
        removeSteadyState(sys, toRemove)
        renameComponent(sys, oldName, newName)
        setDefaultSampleTime(sys, time)
        calculateValidSteadyStates(sys)
        createPIDController(sys,Kp,Ki,Kd)
        
        [x0] = findSteadyState(sys,varargin)
        [funF, funG] = createMatlabFunction(sys,varargin)
        [newSteadyState, valid] = createSteadyState(sys, x0, u0, name)
        [newControlAffineSystem, approxflag] = createControlAffineSystem(sys,timeConst)
        [t,x,y] = simulateStep(sys, tspan, x0, u0, varargin)
        [A,B,C,D] = symLinearize(sys)
    end
    
    %######################################################################
    %% Protected Methods
    %######################################################################
    
    methods(Access = protected)
        reactOnEquationsChange(sys)
    end
    
    %######################################################################
    %% Class Restricted Access Method
    %######################################################################
    
    methods(Access = ?ODESCA_SteadyState)
        removeSteadyStateFromList(sys, pos)
    end
    
    %######################################################################
    %% Method Overwrite
    %######################################################################
    
    methods(Access = public)
        function delete(sys)
            % Delete method which is called on destruction of the instance
            %
            % SYNTAX
            %   sys.delete()
            %
            % INPUT ARGUMENTS
            %   sys:    Instance of the object where the methode was
            %           called. This parameter is given automatically.
            %
            % OPTIONAL INPUT ARGUMENTS
            %
            % OUTPUT ARGUMENTS
            %
            % DESCRIPTION
            %   This method is called when an instance of the class
            %   ODESCA_System is destructed. It calls the delete()-Methods
            %   of all steady states added to the system to ensure no
            %   valid instance is left.
            %
            % NOTE
            %   - The delete method is called by matlab if the last
            %     reference to a handle class instance is deleted.
            %   
            % SEE ALSO
            %
            % EXAMPLE
            %
            if(~isempty(sys.steadyStates))
                sys.steadyStates.delete();
            end
        end
    end
    
    methods(Access = protected)
        function cpObj = copyElement(sys)
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
            %   cpObj: Copy of the ODESCA_System obj
            %
            % DESCRIPTION
            %   This method overwrites the copyElement()-Method of
            %   matlab.mixin.Copyable. This is neccessary to create copied
            %   versions of the steady state which do not belong to the
            %   wrong system.
            %
            % NOTE
            %
            % SEE ALSO
            %
            % EXAMPLE
            %
            
            % Call the copyElement()-Method of the superclass
            cpObj = copyElement@ODESCA_Object(sys);
            
            % Copy the array of steady states and add each one to the
            % system copy
            if( ~isempty(sys.steadyStates) )
                cpObj.steadyStates = sys.steadyStates.copy(cpObj);
            end
        end
    end
    
end