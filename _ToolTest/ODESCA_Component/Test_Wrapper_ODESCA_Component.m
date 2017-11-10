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

classdef Test_Wrapper_ODESCA_Component < ODESCA_Component
    %CLASSNAME ODESCA_Component_Wrapper
    %
    % DESCRIPTION
    %   This class enambles a set access to the protected properties and
    %   methods for testing cases.
    %
    % ODESCA_Object_Wrapper
    %
    % PROPERTIES:
    %
    % CONSTRUCTOR:
    %
    % METHODS:
    %
    % LISTENERS
    %
    % NOTE:
    %   This class is for testing the Framework only. It should not be used
    %   to create an component for the system in the working process.
    %
    % SEE ALSO
    %
    
    properties  
        
    end
    
    % Constructor and Wrapped methods
    methods
        function set_f(obj, value)
            obj.f = value;
        end
        
        function set_g(obj, value)
            obj.g = value;
        end
        
        function obj = Test_Wrapper_ODESCA_Component()
           obj = obj@ODESCA_Component();
        end
        
        function wrapped_addConstructionParameter(obj, parameterNames)
            obj.addConstructionParameter(parameterNames);
        end
        
        function wrapped_initializeBasics(obj, stateNames, inputNames, outputNames, paramNames, stateUnits, inputUnits, outputUnits, paramUnits)
            obj.initializeBasics(stateNames, inputNames, outputNames, paramNames, stateUnits, inputUnits, outputUnits, paramUnits);
        end
         
        function wrapped_calculateEquations(obj, calculationHandle, stateNames, stateUnits, inputNames, inputUnits, outputNames, outputUnits, paramNames, paramUnits)
            obj.calculateEquations(obj, calculationHandle, stateNames, stateUnits, inputNames, inputUnits, outputNames, outputUnits, paramNames, paramUnits);
        end
        
        
        % This method evaluates prepareCreationOfEquations and checks if
        % the given variables in the array varNames are known in the
        % method workspace and are the same symbolic as in varSym. It 
        % returns two arrays with the same size as symVar where 0 means 
        % false and 1 means true. The array exists shows if a variable with 
        % the name exists, the array correctSym shows if the variable 
        % stores the correct symbolic variable.
        % varNames has to be a cell array with strings in the same size as
        % varSym which has to be a symbolic array.
        function [exists, correctSym] = test_prepareCreationOfEquations(obj, varNames, varSym)
            obj.prepareCreationOfEquations();
            
            exists = zeros(size(varNames));
            correctSym = zeros(size(varNames));
            for i = 1:numel(varNames)
                name = varNames{i};
                
                % Check if the variable with this name exists
                if( exist(name, 'var'))
                    var = eval(name);
                    exists(i) = 1;
                    % Check if the variabl constains the symbolic correct
                    % symbolic variable
                    if( isequal(varSym(i),var))
                        correctSym(i) = 1;
                    end
                end
            end
        end
        
    end    
      
    % Implementation of abstract method
    methods(Access = protected)

        function calculateEquations(obj)
            % Template Code
            obj.initializeBasics({'state1','state2'}, {'input1','input2'}, {'output1','output2'},{'param1','param2'}, {'si_1','si_2'}, {'si_1','si_2'}, {'si_1','si_2'}, {'si_1','si_2'});
            obj.prepareCreationOfEquations();
            
            % Calculation of equations
            obj.f(1) = state1 + input1 + param1;
            obj.f(2) = state2 + input2 + param2;
            obj.g(1) = state2;
            obj.g(2) = input2;
            
            % Sort the equations so they are n x 1 vectors
            if(~isempty(obj.f))
                obj.f = reshape(obj.f,[numel(obj.f),1]);
            end
            if(~isempty(obj.g))
                obj.g = reshape(obj.g,[numel(obj.g),1]);
            end
        end
    end
    
end