classdef ODESCA_SteadyState < ODESCA_BaseClass
    %ODESCA_SteadyState Class representing a steady state of a system
    %
    % DESCRIPTION
    %   This class represents a steady state of a dynamic system. It stores
    %   the the values of the states, inputs and outputs which define the
    %   steady state. This class can be used to create approximations of
    %   a nonlinear dynamic system like a linear or a bilinear model.
    %
    % ODESCA_SteadyState
    %
    % PROPERTIES:
    %     name
    %     x0
    %     u0
    %     approximations
    %     y0
    %     system
    %     structuralValid
    %     numericValid
    %     param
    %
    % CONSTRUCTOR:
    %     ODESCA_SteadyState(system, x0, u0, name)
    %
    % METHODS:
    %
    %     setName(obj, name);
    %     [valid, maxDerivative] = isNumericValid(obj, maximumVariance);
    %     linear = linearize(obj);
    %     linear = linear(obj);
    %
    % LISTENERS
    %
    % NOTE:
    %   - This object is used and modified in an instance of the class
    %     ODESCA_System. It may be deleted from there which renders the
    %     instance invalid.
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
        
        % Name of the steady state
        %
        % TYPE
        %   string
        %
        % DESCRIPTION
        %   Name to identify the instance under the number of steady state
        %   operation points in a system.
        %
        % NOTE
        %
        % SEE ALSO
        %
        name
        
        % Values of the states in the steady state
        %
        % TYPE
        %   numeric array
        %
        % DESCRIPTION
        %   This array stores the values of the states in the steady state.
        %
        % NOTE
        %   - The position of the states corresponds to the position they
        %     have in the system
        %
        % SEE ALSO
        %   ODESCA_System.stateNames
        %
        x0
        
        % Values of the inputs in the steady state
        %
        % TYPE
        %   numeric array
        %
        % DESCRIPTION
        %   This array stores the values of the inputs in the steady state.
        %
        % NOTE
        %   - The position of the inputs corresponds to the position they
        %     have in the system
        %
        % SEE ALSO
        %   ODESCA_System.inputNames
        %
        u0
        
        % Array of the system approximations at the steady state
        %
        % TYPE
        %   heterogenius class array
        %
        % DESCRIPTION
        %   This heterogenius class array stores all calculated
        %   approximations of the system. All approximations are subclasses
        %   of the class ODESCA_Approximation
        %
        % NOTE
        %
        % SEE ALSO
        %
        approximations
    end
    
    % The propteries of this section can only be set by an instance of the
    % class ODESCA_System
    properties(SetAccess = ?ODESCA_System)
        % Values of the outputs in the steady state
        %
        % TYPE
        %   numeric array
        %
        % DESCRIPTION
        %   This array stores the values of the outputs in the steady
        %   state.
        %
        % NOTE
        %   - The position of the outputs corresponds to the position they
        %     have in the system
        %
        % SEE ALSO
        %   ODESCA_System.outputNames
        %
        y0
        
        % System instance the steady state refers to
        %
        % TYPE
        %   ODESCA_System
        %
        % DESCRIPTION
        %   This property stores the system the steady state belongs to. It
        %   can only be set and reset by an instance of the class
        %   ODESCA_System.
        %
        % NOTE
        %   - A steady state which does not belong to a system can not be
        %     linearized.
        %
        % SEE ALSO
        %
        system
        
        % Flag to determine if the steady state is structural valid
        %
        % TYPE
        %   boolean
        %
        % DESCRIPTION
        %   This boolean value determines if the steady state is structural
        %   valid for the system. If the structure (not the parameter
        %   values) of the system change after the steady state was added
        %   to the system, this flag is false.
        %   The flag is set to true on adding the steady state to the
        %   system if the dimensions are correct.
        %
        % NOTE
        %   - If this flag is false, the steady state can not be linearized
        %     and no model can be created from it.
        %
        % SEE ALSO
        %
        structuralValid
        
        % Flag to determine if the steady state is numerical valid
        %
        % TYPE
        %   boolean
        %
        % DESCRIPTION
        %   This boolean value determines if the steady state operation
        %   point is numerical valid with the system. This is the case if
        %   the equations for the state changes (f) are equal to zero and
        %   the equations for the outputs (g) are equal to the given y0 on
        %   substitution with x0 and u0.
        %
        % NOTE
        %
        % SEE ALSO
        %
        numericValid
        
        % Parameter set of the system the steady state refers to
        %
        % TYPE
        %   structure
        %
        % DESCRIPTION
        %   This property stores the parameter set of the system at a
        %   certain point of time.
        %
        % NOTE
        %
        % SEE ALSO
        %
        param
    end
    
    %######################################################################
    %% Constructor
    %######################################################################
    
    methods(Access = ?ODESCA_System)
        % Constructor of the class ODESCA_SSOP
        %
        % SYNTAX
        %   obj = ODESCA_SSOP(x0, u0, name)
        %
        % INPUT ARGUMENTS
        %   x0: Values of the states in the steady state operation point
        %   u0: Values of the inputs in the steady state operation point
        %
        % OPTIONAL INPUT ARGUMENTS
        %   name: Name of the steady state operation point. If not given
        %         the default name is 'SteadyState'
        %
        % OUTPUT ARGUMENTS
        %
        % DESCRIPTION
        %   The constructor initializes the steady state object with all
        %   necessary data and sets the rest empty.
        %
        % NOTE
        %
        % SEE ALSO
        %
        % EXAMPLE
        %
        function obj = ODESCA_SteadyState(system, x0, u0, name)
            
            obj.name = name;
            obj.x0 = x0;
            obj.u0 = u0;
            obj.y0 = [];
            obj.approximations = [];
            
            obj.system = system;
            obj.param = [];
            obj.structuralValid = false;
            obj.numericValid = false;
        end
    end
    
    %######################################################################
    %% Methods
    %######################################################################
    
    methods
        setName(obj, name);
        [valid, maxDerivative] = isNumericValid(obj, maximumVariance);
    end
    
    %######################################################################
    %% Methods for the approximations
    %######################################################################
    
    methods
        linear   = linear(obj, index);
        linear   = linearize(obj);
        bilinear = bilinear(obj, index);
        bilinear = bilinearize(obj);
    end
    
    %######################################################################
    %% Class Restricted Access Method
    %######################################################################
    
    methods(Access = ?ODESCA_Approximation)
        removeApproximationFromList(obj, pos);
    end
    
    methods(Access = ?ODESCA_System)
        % Defines the copy behavior of the class
        %
        % SYNTAX
        %
        % INPUT ARGUMENTS
        %   oldSteadyStates:    Instance of the object where the methode 
        %                       was called. This parameter is given
        %                       automatically.
        %   newSystem: New system instance which was created durning the
        %              copy() method call at the system. The copied steady
        %              state is attached to the copied system.
        %
        % OPTIONAL INPUT ARGUMENTS
        %
        % OUTPUT ARGUMENTS
        %
        % DESCRIPTION
        %   This method defines the copy behavior of the class. Since
        %   copiing a steady state without a system does not make sence,
        %   the method can only by called by an instance of the class
        %   ODESCA_System when it is copied. The method creates copies of
        %   all the approximations attached to the old system.
        %
        % NOTE
        %
        % SEE ALSO
        %
        % EXAMPLE
        %
        function newSteadyStates = copy(oldSteadyStates,newSystem)
            newSteadyStates = [];
            for numSteadyState = 1:numel(oldSteadyStates)
                oldSS = oldSteadyStates(numSteadyState);
                newSS = ODESCA_SteadyState(newSystem, oldSS.x0, oldSS.u0, oldSS.name);
                newSS.param = oldSS.param;
                newSS.structuralValid = oldSS.structuralValid;
                newSS.numericValid = oldSS.numericValid;
                if( ~isempty(oldSS.approximations) )
                    newSS.approximations = oldSS.approximations.copy(newSS);
                end
                newSteadyStates = [newSteadyStates, newSS]; %#ok<AGROW>
            end
        end
    end
    
    %######################################################################
    %% Method Overwrite
    %######################################################################
    methods(Access = public)
        % Custom delete() method which overwrites the default delete()
        %
        % SYNTAX
        %   obj.delete()
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
        %   This delete behavior of the class ODESCA_SteadyState. Since
        %   the steady state class has approximations which can not exist
        %   without the steady state, the approximations have to be delete
        %   if the steady state is deleted.
        %
        % NOTE
        %
        % SEE ALSO
        %
        % EXAMPLE
        %
        function delete(obj)
            if(~isempty(obj.approximations))
                obj.approximations.delete();
            end
            sys = obj.system;
            pos = find(eq(sys.steadyStates,obj));
            sys.removeSteadyStateFromList(pos); %#ok<FNDSB>
        end
    end
    
end