classdef ODESCA_ControlAffineSystem < ODESCA_Object
    %ODESCA_ControlAffineSystem Class for handling ordinary differential equations
    %
    % DESCRIPTION
    %   This class contains the control affine representation of a 
    %   nonlinear dynamic system. It stores differential equation systems 
    %   in the form
    %       xdot = f0(x)+f1(x)*u;
    %       y    = g(x,u);
    %   If the system equations are already in the control affine form,
    %   the property approxflag is set to false. Otherwise, first order low
    %   passes with a small time constant are added in order to get a control
    %   affine approximation. In this case, the property approxflag is set
    %   to true.
    %
    %   This class can only be created with the method 
    %   createControlAffineSystem() of the class ODESCA_System.
    %
    %   An instance of this class has to belong to an ODESCA_System 
    %   instance at every time. If the instance is deleted, the instance of
    %   this class will be deleted too. 
    %    
    % PROPERTIES:  
    %     f0
    %     f1
    %     approxflag
    %     system
    %
    % CONSTRUCTOR:
    %   ODESCA_ControlAffineSystem(system, f0, f1, approxflag)
    %
    % METHODS: (Public|Protected|Private)
    %
    %   []
    %
    % ---------------------------------------------------------------------
    %
    %   []
    %
    % ---------------------------------------------------------------------
    %       
    %   []
    %
    % LISTENERS
    %
    % NOTE:
    %   - An instance of this class is always linked to a systene. If
    %   the system is deleted, the instance of this class will be
    %   deleted as well.
    %
    % SEE ALSO
    %   ODESCA_System
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
        % Array with the part f0(x) of the symbolic equations for the state changes
        %
        % TYPE
        %   symbolic array
        %
        % DESCRIPTION
        %   This array stores the part f0(x) of the symbolic equations 
        %   which describe the change of the states in the form of
        %       xdot = f0(x)+f1(x)*u
        %   Each element of the array corresponds with the element of the
        %   property 'x' and the property 'stateNames' with the same index. 
        %   For example f0(1) is the part f0 of the equation for the 
        %   derivative of x(1) or stateNames{1}.
        %
        % NOTE
        %   - This array is created by a subclass of ODESCA_ODE.
        %
        % SEE ALSO
        %
        f0
        
        % Array with the part f1(x) of the symbolic equations for the state changes
        %
        % TYPE
        %   symbolic array
        %
        % DESCRIPTION
        %   This array stores the part f1(x) of the symbolic equations 
        %   which describe the change of the states in the form of
        %       xdot = f0(x)+f1(x)*u
        %   Each element of the array corresponds with the element of the
        %   property 'x' and the property 'stateNames' with the same index. 
        %   For example f1(1) is the part f1 of the equation for the 
        %   derivative of x(1) or stateNames{1}.
        %
        % NOTE
        %   - This array is created by a subclass of ODESCA_ODE.
        %
        % SEE ALSO
        %
        f1
        
        approxflag
        
        system
    end
    
    %######################################################################
    %% Constructor
    %######################################################################
    
    methods(Access = ?ODESCA_System)
        function obj = ODESCA_ControlAffineSystem(system, f0, f1, approxflag, name)
            
            if(nargin == 4)
                initialName = 'UnnamedControlAffineSystem';
            else
                initialName = name;
            end
            
            % Initialize the name empty
            obj = obj@ODESCA_Object(initialName);
            
            obj.system = system;
            obj.f0 = f0;
            obj.f1 = f1;
            obj.approxflag = approxflag;
            obj.p = system.p;
            obj.param = system.param;
            obj.outputNames = system.outputNames;
            obj.outputUnits = system.outputUnits;
        end
    end
    
    %######################################################################
    %% Public Methods
    %######################################################################
    

    
    %######################################################################
    %% Protected Methods
    %######################################################################
    
    
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
            %   cpObj: Copy of the ODESCA_ControlAffineSystem obj
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