classdef ODESCA_Bilinear < ODESCA_Approximation
    %ODESCA_Bilinear Bilinear approximation of a system in a given steady state 
    %
    % DESCRIPTION
    %   This class represents the bilinearization of a nonlinear dynamic
    %   system in a steady state. The bilinearisation is described with the
    %   matices A, B, C, D, G, M and N.
    %
    % ODESCA_Bilinear
    %
    % PROPERTIES:
    % Time continuous system matrix
    %   A
    %   B
    %   C
    %   D
    %   G
    %   N
    %   M
    %   discreteSampleTime
    %
    % CONSTRUCTOR:
    %   obj = ODESCA_Bilinear(steadyState, A, B, C, D, G, N, M)
    %
    % METHODS: (Public|Protected|Private)
    % 
    %   []
    %
    % ---------------------------------------------------------------------
    %
    %   newApproximation = copyElement(oldApproximation, newSteadyState)    
    %   deleteElement(obj)
    %
    % ---------------------------------------------------------------------
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
        
        % Matrix for input-input bilinearity
        %
        % TYPE
        %   numeric 3-dimensionl matrix
        %
        % DESCRIPTION
        %
        % NOTE
        %
        % SEE ALSO
        %
        G
        
        % Matrix for input-state bilinearity
        %
        % TYPE
        %   numeric 3-dimensionl matrix
        %
        % DESCRIPTION
        %
        % NOTE
        %
        % SEE ALSO
        %
        N
        
        % Matrix for state-state bilinearity
        %
        % TYPE
        %   numeric 3-dimensionl matrix
        %
        % DESCRIPTION
        %
        % NOTE
        %
        % SEE ALSO
        %
        M
        
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
    end
    
    %######################################################################
    %% Constructor
    %######################################################################
    
    methods(Access = ?ODESCA_SteadyState)
        function obj = ODESCA_Bilinear(steadyState, A, B, C, D, G, N, M)
            
            obj = obj@ODESCA_Approximation(steadyState);
            
            obj.A = A;
            obj.B = B;
            obj.C = C;
            obj.D = D;
            obj.G = G;
            obj.N = N;
            obj.M = M;
            
            obj.discreteSampleTime = [];
        end
    end
    
    %######################################################################
    %% Public Methods
    %######################################################################
    
    methods
        
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
            %   the class ODESCA_Bilinear
            %
            % NOTE
            %
            % SEE ALSO
            %
            % EXAMPLE
            %
            bilin = oldApproximation;
            newApproximation = ODESCA_Bilinear(newSteadyState, bilin.A, bilin.B, bilin.C, bilin.D, bilin.G, bilin.N, bilin.M);
            newApproximation.discreteSampleTime = lin.discreteSampleTime;
        end
          
        function deleteElement(obj) %#ok<MANU>
            % No special delete behavior needed for the bilinearization
        end
    end
    
end