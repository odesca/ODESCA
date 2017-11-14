classdef(Abstract) ODESCA_Approximation < ODESCA_BaseClass & matlab.mixin.Heterogeneous
    %ODESCA_Approximation Super class for all system approximations
    %
    % DESCRIPTION
    %   This class is the super class for all approximations of a nonlinear
    %   system in a steady state. The approximations are meant to be
    %   instanciated inside an instance of the ODESCA_SteadyState class.
    %   This class provides base functionalities which all approximations
    %   have in common like copy- and delete-operations and the dependence
    %   on an instance of the ODESCA_SteadyState class.
    %
    % ODESCA_Approximation
    %
    % PROPERTIES:
    %   steadyState
    %
    % CONSTRUCTOR:
    %   ODESCA_Approximation(steadyState)
    %
    % METHODS:
    %   copy(oldApproximations, newSteadyState)
    %   delete(obj)
    %
    % LISTENERS
    %
    % NOTE:
    %   - An approximation CAN NOT exist without a steady state! It is
    %     deleted if the steady state gets deleted.
    %   - In all subclasses the method
    %     copyElement(oldApproximation, newSteadyState) has to be
    %     overwritten to define the copy behavior of the approximation
    %     class. It is important to create a new instance of the
    %     approximation class to be returned as output argument of the
    %     method to ensure that the copy operation will work correctly.
    %   - In all subclasse the method deleteElement(obj) has to be
    %     overwritten. If no special properties (like pointers) have to be
    %     deleted, this method can be left empty.
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
    
    properties
        % Steady State the approximation belongs to
        %
        % Type
        %   instance of the class ODESCA_SteadyState
        %
        % DESCRIPTION
        %   This property stores the instance of the class
        %   ODESCA_SteadyState the linearization belongs to.
        %
        % NOTE
        %
        % SEE ALSO
        %
        steadyState
    end
    
    %######################################################################
    %% Constructor
    %######################################################################
    
    methods
        function obj = ODESCA_Approximation(steadyState)
            % Constructor of the class
            %
            % SYNTAX
            %   ODESCA_Approximation(steadyState)
            %
            % INPUT ARGUMENTS
            %   steadyState: instance of the class ODESCA_SteadyState this
            %                approximation belongs to.
            %
            % OPTIONAL INPUT ARGUMENTS
            %
            % OUTPUT ARGUMENTS
            %   obj:    Instance of the object that was created in the
            %           constructor.
            %
            % DESCRIPTION
            %   This is the constructor of the class ODESCA_Approximation.
            %   It takes the instance of the class ODESCA_SteadyState it
            %   belongs to as input argument.
            %
            % NOTE
            %   - The constructor of a approximation should only be
            %     accessed by the class ODESCA_SteadyState so it should
            %     have the following access: Access = ?ODESCA_SteadyState
            %
            % SEE ALSO
            %
            % EXAMPLE
            %
            obj.steadyState = steadyState;
        end
    end
    
    %######################################################################
    %% Class Restricted Access Method
    %######################################################################
    
    methods(Access = ?ODESCA_SteadyState)
        function newApproximations = copy(oldApproximations, newSteadyState)
            % Creates copies of all instances in a heterogenous array
            %
            % SYNTAX
            %
            % INPUT ARGUMENTS
            %   oldApproximations: Instance where the method was called.
            %                      This parameter is given automatically.
            %   newSteadyState: Because an approximation can only exist 
            %                   with a steady state, the new steady state
            %                   which was copied has to be given to the new
            %                   approximation.
            %
            % OPTIONAL INPUT ARGUMENTS
            %
            % OUTPUT ARGUMENTS
            %   newApproximations: Array of the copies of the
            %                      approximations
            %
            % DESCRIPTION
            %
            % NOTE
            %   - The copy method can only be called on an instance of the
            %     class ODESCA_System. On copying all steady states and
            %     therefore all approximations of the steady states are
            %     copied.
            %
            % SEE ALSO
            %
            % EXAMPLE
            %
            
            sizeApproximations = numel(oldApproximations);
            newApproximations = [];
            
            % Create a copy for every instance of the oldApproximations and
            % combine them in a heterogenous array
            for numApprox = 1:sizeApproximations
                newApprox = oldApproximations(numApprox).copyElement(newSteadyState);
                newApprox.steadyState = newSteadyState;
                newApproximations  = [newApproximations,newApprox]; %#ok<AGROW>
            end
        end
    end
    
    %######################################################################
    %% Method Overwrite
    %######################################################################
    methods(Access = public)
        function delete(obj)
            % Custom delete() method which overwrites the default delete()
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
            %   This method defines a delete behavior for all
            %   approximations.
            %
            % NOTE
            %   WARNING: do not overwrite this method in subclasses. To
            %   define the a special behavior for the deletion, overwrite
            %   the method deleteElement(obj).
            %
            % SEE ALSO
            %
            % EXAMPLE
            %
            obj.deleteElement();
            ss = obj.steadyState;
            for i = 1:numel(ss.approximations)
               if(eq(ss.approximations(i),obj))
                  pos = 1; 
               end
            end
            ss.removeApproximationFromList(pos);
        end
    end
    
    %######################################################################
    %% Abstract Methods
    %######################################################################
    
    methods(Access = protected, Abstract)
        newApproximation = copyElement(oldApproximation, newSteadyState);
        % This method has to be overwritten to define the copy
        % behavior of the approximation subclasses. It is only called on a
        % scalar variable and not on an array.
        
        deleteElement(obj);
        % This method has to be overridden to define special deletion
        % behavior of the approximation subclasses. It is only called on a
        % scalar variable and not on an array.
    end
    
end