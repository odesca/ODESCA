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

classdef Test_Wrapper_ODESCA_Object < ODESCA_Object
    %CLASSNAME ODESCA_Object_Wrapper
    %
    % DESCRIPTION
    %   This class enambles a set access to the protected properties for
    %   testing cases.
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
    %   to create an object for the system in the working process.
    %
    % SEE ALSO
    %
    
    properties
    end
    
    % Wrapper methods to enable a set access to the protected properties
    % and to enable access to the protected methods
    methods
        
        function obj = Test_Wrapper_ODESCA_Object()
           obj = obj@ODESCA_Object('Default');
        end

        function set_x(obj, value)
            obj.x = value;
        end
        
        function set_u(obj, value)
            obj.u = value;
        end
        
        function set_stateNames(obj, value)
            obj.stateNames = value;
        end
        
        function set_inputNames(obj, value)
            obj.inputNames = value;
        end
        
        function set_outputNames(obj, value)
            obj.outputNames = value;
        end
        
        function set_paramAsInputs(obj, value)
            obj.paramAsInputs = value;
        end
        
        
        function wrapped_initializeObject(obj)
            obj.initializeObject();
        end
        
        function returnValue = wrapped_addParameters(obj, parameterNames, parameterUnits)
            returnValue = obj.addParameters(parameterNames, parameterUnits);
        end
        
        % Sets the object to s states, i inputs, o outputs and p parameters
        %
        % The state equations are created the following:
        %   f(s) = sum[1->i: i*u(i)] - x(s) + sum[1->p: param(p)^p]
        %   g(o) = sum[1->i: i*u(i)] - sum[1->s: s*x(s)]  + sum[1->p: param(p)^p] + o
        %
        % where the names are:
        % 'state'  +s
        % 'input'  +i
        % 'output' +o
        % 'param'  +p
        %
        % The units are are titel si_NUM where NUM is the number of the
        % created unit for the states, inputs, outputs or parameters.
        %
        % NOTE:
        %   - If there are no states or no parameters the sums are replaced
        %     with the value 1. E.g.: sum[1->0: s*x(s)] = 1;
        %   - If there are no inputs the sum is replaced with 0. 
        %     E.g.: sum[1->0: i*u(i)] = 0;
        %   --> This leads to a behavior where all parts are in the
        %       equations. If states and parameter are empty this rules 
        %       lead to the part 1/1 so the scalar 1 is added to the 
        %       equations.  
        %
        function generateObject(obj, s, i, o, p, p_useless)
            
            % Initialize the object empty
            obj.initializeObject();
            
            % Add the states
            if(s > 0)
                stateNames = {};
                stateUnits = {};
                for num = 1:s
                    name = ['state',num2str(num)];
                    stateNames = [stateNames; name]; %#ok<AGROW>
                    stateUnits = [stateUnits; ['si_',num2str(num)]]; %#ok<AGROW>
                end
                obj.stateNames = stateNames;
                obj.stateUnits = stateUnits;
                obj.x = sym('x',[s,1]);
            end
            
            % Add the inputs
            if(i > 0)
                inputNames = {};
                inputUnits = {};
                for num = 1:i
                    name = ['input',num2str(num)];
                    inputNames = [inputNames; name]; %#ok<AGROW>
                    inputUnits = [inputUnits; ['si_',num2str(num)]]; %#ok<AGROW>
                end
                obj.inputNames = inputNames;
                obj.inputUnits = inputUnits;
                obj.u = sym('u',[i,1]);
            end
            
            % Add the outputs
            if(o > 0)
                outputNames = {};
                outputUnits = {};
                for num = 1:o
                    name = ['output',num2str(num)];
                    outputNames = [outputNames; name]; %#ok<AGROW>
                    outputUnits = [outputUnits; ['si_',num2str(num)]]; %#ok<AGROW>
                end
                obj.outputNames = outputNames;
                obj.outputUnits = outputUnits;
            end
            
            % Add the parameters
            if(p > 0)
                paramNames = {};
                paramUnits = {};
                for num = 1:p
                    name = ['param',num2str(num)];
                    paramNames = [paramNames; name]; %#ok<AGROW>
                    paramUnits = [paramUnits; ['si_',num2str(num)]]; %#ok<AGROW>
                end
                obj.addParameters(paramNames,paramUnits);
            end

            % Add the useless parameters
            if(p_useless > 0)
                paramNames = {};
                paramUnits = {};
                for num = 1:p_useless
                    name = ['param_u',num2str(num)];
                    paramNames = [paramNames; name]; %#ok<AGROW>
                    paramUnits = [paramUnits; ['si_',num2str(num)]]; %#ok<AGROW>
                end
                obj.addParameters(paramNames,paramUnits);
            end
            
        end
    end
    
end

