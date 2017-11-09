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

classdef ODESCA_Linear < ODESCA_Approximation
    %ODESCA_Linear Linear approximation of a system in a given steady state
    %
    % DESCRIPTION
    %   This class represents the linearization of a nonlinear dynamic
    %   system in a steady state. It uses the control system toolbox of
    %   MATLAB to provide analysis methods. The linearization is described
    %   with the matrices A,B,C and D like shown below:
    %       xdot = A*x + B*u
    %       y    = C*x + D*u
    %   This represents the time continous linearization. For the discrete
    %   lineariziation, the discrete matrices Ad and Bd and the
    %   discretization sample time discreteSampleTime can be stored.
    %   Furthermore the continous linear system is stored as a state space
    %   object (ss) of the control system toolbox in the property ss. The
    %   transfer functions of the linearization are stored in the field tf.
    %   
    %   This class can only be created with the method linearize() of the
    %   class ODESCA_SteadyState.
    %
    %   An instance of this class has to belong to an ODESCA_SteadyState 
    %   instance at every time. If the instance is deleted, the instance of
    %   this class will be deleted too. 
    %
    % ODESCA_SteadyState
    %
    % PROPERTIES:
    %   A
    %   B
    %   C
    %   D
    %   Ad
    %   Bd
    %   discreteSampleTime
    %   ss
    %   tf
    %
    % CONSTRUCTOR:
    %   obj = ODESCA_Linear(steadyState, A, B, C, D)
    %
    % METHODS: (Public|Protected|Private)
    %   h = bodeplot(obj, varargin);
    %   h = nyquistplot(obj, varargin);
    %   h = stepplot(obj,varargin);
    %            
    %   stable = isAsymptoticStable(obj);
    %   observable = isObservable(obj, method);
    %   controllable = isControllable(obj, method);
    %         
    %   [Ad, Bd] = discretize(obj, varargin);
    %
    % ---------------------------------------------------------------------
    %
    %   newApproximation = copyElement(oldApproximation, newSteadyState)
    %   deleteElement(obj) %#ok<MANU>
    %
    % ---------------------------------------------------------------------
    %
    %   []
    %
    % LISTENERS
    %
    % NOTE:
    %   - An instance of this class is always linked to a steady state. If
    %   the steady state is deleted, the instance of this class will be
    %   deleted as well.
    %
    % SEE ALSO
    %   ODESCA_SteadyState
    %
    
    %######################################################################
    %% Properties
    %######################################################################
    
    properties(SetAccess = private)
        % Time continuous system matrix
        %
        % TYPE
        %   numeric matrix
        %
        % DESCRIPTION
        %   This matrix stores the values wich desribe how the
        %   state changes depend on the states. The matrix belongs to a
        %   time continuous system.
        %
        % NOTE
        %
        % SEE ALSO
        %   Ad
        %
        A
        
        % Time continuous input matrix
        %
        % TYPE
        %   numeric matrix
        %
        % DESCRIPTION
        %   This matrix stores the values which describe how the
        %   state changes depend on the inputs. The matrix belongs to a
        %   time continuous system.
        %
        % NOTE
        %
        % SEE ALSO
        %   Bd
        %
        B
        
        % Output matrix
        %
        % TYPE
        %   numeric matrix
        %
        % DESCRIPTION
        %   This matrix stores the values which describe how the outputs
        %   depend on the states.
        %
        % NOTE
        %
        % SEE ALSO
        %
        C
        
        % Feedthrough matrix
        %
        % TYPE
        %   numeric matrix
        %
        % DESCRIPTION
        %   This matrix stores the values which describe how the outputs
        %   depend on the inputs.
        %
        % NOTE
        %
        % SEE ALSO
        %
        D
        
        % Time discrete system matrix
        %
        % TYPE
        %   numeric matrix
        %
        % DESCRIPTION
        %   This matrix stores the values which describe how the
        %   state are in the next time step. The matrix belongs to a
        %   time discrete system.
        %
        % NOTE
        %
        % SEE ALSO
        %   A
        %
        Ad
        
        % Time discrete input matrix
        %
        % TYPE
        %   numeric matrix
        %
        % DESCRIPTION
        %   This matrix stores the values which describe how the
        %   inputs are in the next time step. The matrix belongs to a
        %   time discrete system.
        %
        % NOTE
        %
        % SEE ALSO
        %   B
        %
        Bd
        
        % Default sample time of the system the steady state refers to
        %
        % TYPE
        %   numeric
        %
        % DESCRIPTION
        %   This property stores the sample time of the discrete matrices.
        %
        % NOTE
        %
        % SEE ALSO
        %
        discreteSampleTime
        
        % State space model of the linearization
        %
        % Type
        %   instance of the class ss
        %
        % DESCRIPTION
        %   This property stores an instance of the class ss (state space)
        %   of the control system toolbox.
        %
        % NOTE
        %
        % SEE ALSO
        %
        ss
    end
    
    properties(Dependent)
        % transfer functions of the linearization
        %
        % Type
        %   instance of the class tf
        %
        % DESCRIPTION
        %   This property stores an instance of the class tf (transfer
        %   function) of the control system toolbox.
        %
        % NOTE
        %
        % SEE ALSO
        %
        tf
    end
    
    %######################################################################
    %% Constructor
    %######################################################################
    
    methods(Access = ?ODESCA_SteadyState)
        function obj = ODESCA_Linear(steadyState, A, B, C, D)
            
            obj = obj@ODESCA_Approximation(steadyState);
            
            obj.A  = A;
            obj.B  = B;
            obj.C  = C;
            obj.D  = D;
            obj.Ad = [];
            obj.Bd = [];
            obj.discreteSampleTime = [];
            
            sys = steadyState.system;
            stateSpace = ss(A,B,C,D);
            stateSpace.StateName = sys.stateNames;
            stateSpace.StateUnit = sys.stateUnits;
            stateSpace.InputName = sys.inputNames;
            stateSpace.InputUnit = sys.inputUnits;
            stateSpace.OutputName = sys.outputNames;
            stateSpace.OutputUnit = sys.outputUnits;
            stateSpace.Name = [sys.name,'_-_',steadyState.name];
            stateSpace.UserData = struct;
            stateSpace.UserData.param = steadyState.param;
            obj.ss = stateSpace;
            
        end
    end
    
    %######################################################################
    %% Methods for dependent properties
    %######################################################################
    
    methods
        function value = get.tf(obj)
            % Dependent get method for the property tf
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
            %   value:  transfer function object (tf) of the control system
            %           toolbox
            %
            % DESCRIPTION
            %
            % NOTE
            %
            % SEE ALSO
            %
            % EXAMPLE
            %
            value = tf(obj.ss); %#ok<CPROP>
        end
    end
    
    %######################################################################
    %% Public Methods
    %######################################################################
    methods
        h = bodeplot(obj, varargin);
        h = nyquistplot(obj, varargin);
        h = stepplot(obj,varargin);
        
        stable = isAsymptoticStable(obj);
        observable = isObservable(obj, method);
        controllable = isControllable(obj, method);
        
        [Ad, Bd] = discretize(obj, varargin);
    end
    
    %######################################################################
    %% Method Overwrite
    %######################################################################
    
    methods(Access = protected)
        function newApproximation = copyElement(oldApproximation, newSteadyState)
            % Specification of the copy behavior for a single instance
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
            %   This method specifies the copy behavior for an instance of
            %   the class ODESCA_Linear
            %
            % NOTE
            %
            % SEE ALSO
            %
            % EXAMPLE
            %
            lin = oldApproximation;
            newApproximation = ODESCA_Linear(newSteadyState, lin.A, lin.B, lin.C, lin.D);
            newApproximation.Ad = lin.Ad;
            newApproximation.Bd = lin.Bd;
            newApproximation.discreteSampleTime = lin.discreteSampleTime;
        end
          
        function deleteElement(obj) %#ok<MANU>
            % No special delete behavior needed for the linearization
        end
    end
    
end