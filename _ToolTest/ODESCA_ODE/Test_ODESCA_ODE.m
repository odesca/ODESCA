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

classdef Test_ODESCA_ODE < matlab.unittest.TestCase
    %ODESCA_ODE_Test Class to test ODESCA_ODE
    %
    % DESCRIPTION
    %   This class test the class ODESCA_ODE for the correct working of
    %   all methods and properties.
    %
    % ODESCA_ODE_Test
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
    %
    % SEE ALSO
    %
    
    properties
        ODE
    end
    
    % Method to create new ODESCA_ODE for every test method
    methods(TestMethodSetup)
        function createODE(testCase)
            testCase.ODE = Test_Wrapper_ODESCA_ODE();
        end
    end
    
    % Method to remove instance of the ODESCA_ODE which was tested
    methods(TestMethodTeardown)
        function removeODE(testCase)
            testCase.ODE = [];
        end
    end
    
    methods(Test)
        % ---------- checks for the ODE itself -------------------------
        
        % Check if the properties can not be set public
        function check_PropertiesSetProhibited(testCase)
            % Create list of all parameters an the diagnostic displayed if
            % the set access is not prohibited and does not throw an error
            nameList = {...
                'name';
                'param';
                'p';
                'paramUnits';
                'f';
                'g';
                'x';
                'u';
                'stateNames';
                'inputNames';
                'outputNames';
                'stateUnits';
                'inputUnits';
                'outputUnits'
                };
            
            % Check the fields
            for num = 1:size(nameList,1)
                result = 'No Error';
                name = nameList{num};
                try
                    testCase.ODE.(name) = 1;
                catch err
                    result = err.identifier;
                end
                testCase.verifyEqual(result,'MATLAB:class:SetProhibited',['The public set access for the propertie ''',name,''' is not prohibited.']);
            end
        end
        
        % Check if the particular methods have a private access premission
        function check_MethodAccessProhibited(testCase)
            testCase.verifyError(@()testCase.ODE.initializeODE(), 'MATLAB:class:MethodRestricted', 'The method ''initializeODE'' of the class ''ODESCA_ODE'' don''t have a restricted access.');
            testCase.verifyError(@()testCase.ODE.removeSymbolicInput(1), 'MATLAB:class:MethodRestricted', 'The method ''removeSymbolicInput'' of the class ''ODESCA_ODE'' don''t have a restricted access.');
            testCase.verifyError(@()testCase.ODE.renameParam('Param1','Param2'), 'MATLAB:class:MethodRestricted', 'The method ''renameParam'' of the class ''ODESCA_ODE'' don''t have a restricted access.');
            testCase.verifyError(@()testCase.ODE.removeParam('Param1'), 'MATLAB:class:MethodRestricted', 'The method ''removeParam'' of the class ''ODESCA_ODE'' don''t have a restricted access.');
        end
              
        % Check if the name is set to the argument given in the constructor
        function check_NameSetInConstructor(testCase)
            testCase.verifyEqual(testCase.ODE.name,'Default', 'The property ''name'' of class ''ODESCA_ODE'' is not set correctly.');
        end
        
        % ---------- checks for initializeODE() ------------------------
        % Check if the properties are initialized empty in constructor
        
        function check_PropertiesInitializedEmpty(testCase)
            
            testCase.verifyEmpty(testCase.ODE.param,         'The property ''param'' of class ''ODESCA_ODE'' is not initialized emtpy.');
            testCase.verifyEmpty(testCase.ODE.p,             'The property ''p'' of class ''ODESCA_ODE'' is not initialized emtpy.');
            testCase.verifyEmpty(testCase.ODE.f,             'The property ''f'' of class ''ODESCA_ODE'' is not initialized emtpy.');
            testCase.verifyEmpty(testCase.ODE.g,             'The property ''g'' of class ''ODESCA_ODE'' is not initialized emtpy.');
            testCase.verifyEmpty(testCase.ODE.x,             'The property ''x'' of class ''ODESCA_ODE'' is not initialized emtpy.');
            testCase.verifyEmpty(testCase.ODE.u,             'The property ''u'' of class ''ODESCA_ODE'' is not initialized emtpy.');
            testCase.verifyEmpty(testCase.ODE.stateNames,    'The property ''stateNames'' of class ''ODESCA_ODE'' is not initialized emtpy.');
            testCase.verifyEmpty(testCase.ODE.inputNames,    'The property ''inputNames'' of class ''ODESCA_ODE'' is not initialized emtpy.');
            testCase.verifyEmpty(testCase.ODE.outputNames,   'The property ''outputNames'' of class ''ODESCA_ODE'' is not initialized emtpy.');
            testCase.verifyEmpty(testCase.ODE.stateUnits,    'The property ''stateUnits'' of class ''ODESCA_ODE'' is not initialized emtpy.');
            testCase.verifyEmpty(testCase.ODE.inputUnits,    'The property ''inputUnits'' of class ''ODESCA_ODE'' is not initialized emtpy.');
            testCase.verifyEmpty(testCase.ODE.outputUnits,   'The property ''outputUnits'' of class ''ODESCA_ODE'' is not initialized emtpy.');
            testCase.verifyEmpty(testCase.ODE.paramUnits,    'The property ''paramUnits'' of class ''ODESCA_ODE'' is not initialized emtpy.');
        end
              
        % ---------- checks for calculateNumericEquations -----------------
        
        function check_CalculateNumericEquations_Errors(testCase)
            % Prepare the ODE
            testCase.ODE.wrapped_addParameters({'param1','param2'},{'si_1','si_2'});
            testCase.assertEqual(fieldnames(testCase.ODE.param),{'param1';'param2'},'The adding of the initial parameters does not work correctly so the test is aborted.');
            
            % Check for the error because of unset parameters
            testCase.verifyError(@()testCase.ODE.calculateNumericEquations(),'ODESCA_ODE:calculateNumericEquations:notAllParametersSet','Calling the method ''calculateNumericEquations'' does not throw a correct error with unset parameters.');
        end
        
        function check_CalculateNumericEquations(testCase)
            % Check a ODE with no parameters
            % Prepare the ODE
            f = [5 * sym('x1'); sym('x2') / 2 - sym('x1')];
            g = sym('x1') + sym('x2');
            testCase.ODE.set_f(f);
            testCase.ODE.set_g(g);
            
            % Perform the calculation
            [actualF, actualG] = testCase.ODE.calculateNumericEquations();
            testCase.verifyEqual(actualF,f,'The equations ''f'' have changed also they should not.')
            testCase.verifyEqual(actualG,g,'The equations ''g'' have changed also they should not.')
            
            
            % Check a ODE with parameters
            % Create an empty ODE for the next part of the test
            testCase.ODE = Test_Wrapper_ODESCA_ODE();
            
            % Prepare the ODE
            testCase.ODE.wrapped_addParameters({'A','B'},{'si_A','si_B'});
            testCase.assertEqual(fieldnames(testCase.ODE.param),{'A';'B'},'The adding of the initial parameters does not work correctly so the test is aborted.');
            
            f = [sym('A') * sym('x1'); sym('x2') * sym('B') / 2 - sym('x1')];
            g = sym('x1') + sym('x2') + sym('B');
            testCase.ODE.set_f(f);
            testCase.ODE.set_g(g);
            
            f = [3 * sym('x1'); sym('x2') * 4 - sym('x1')];
            g = sym('x1') + sym('x2') + 8;
            testCase.ODE.setParam('A',3);
            testCase.ODE.setParam('B',8);
            
            % Perform the calculation
            [actualF, actualG] = testCase.ODE.calculateNumericEquations();
            testCase.verifyEqual(actualF,f,'The equations ''f'' are not calculated correctly.')
            testCase.verifyEqual(actualG,g,'The equations ''g'' are not calculated correctly.')
            
        end
        
        % ---------- checks for switchInputs ------------------------------
        
        function check_SwitchInputs_Errors(testCase)
            % Test if correct errors are thrown if no inputs exist
            testCase.ODE.generateEquations(3,0,3,3,0);
            testCase.verifyError(@()testCase.ODE.switchInputs(1,2),'ODESCA_ODE:switchInputs:InvalidArryIndex','The method ''switchInputs'' does not throw a correct error if there are no inputs and the arguments are integers.');
            testCase.verifyError(@()testCase.ODE.switchInputs('input1','input2'),'ODESCA_ODE:switchInputs:InputNotFound','The method ''switchInputs'' does not throw a correct error if there are no inputs and the arguments are strings.');

            % Test if correct errors are thrown on invalid inputs
            testCase.ODE.generateEquations(3,3,3,3,0);
            testCase.verifyError(@()testCase.ODE.switchInputs([1,3],2),'ODESCA_ODE:switchInputs:InvalidInputArguments','The method ''switchInputs'' does not throw a correct error if on input is a numeric array.');
            testCase.verifyError(@()testCase.ODE.switchInputs(1,sym('u2')),'ODESCA_ODE:switchInputs:InvalidInputArguments','The method ''switchInputs'' does not throw a correct error if on input is a symbolic variable.');
            
            % Test if correct errors are thrown on inputs that does not
            % exist or are out of index
            testCase.verifyError(@()testCase.ODE.switchInputs(2,4),'ODESCA_ODE:switchInputs:InvalidArryIndex','The method ''switchInputs'' does not throw a correct error if on input is out of bounds.');
            testCase.verifyError(@()testCase.ODE.switchInputs('inputNo',2),'ODESCA_ODE:switchInputs:InvalidInputArguments','The method ''switchInputs'' does not throw a correct error if on input is a numeric array.');
       end
        
        function check_SwitchInputs(testCase)
            % Prepare symbolic variables for the comparison
            u1 = sym('u1'); u2 = sym('u2'); u3 = sym('u3');
            x1 = sym('x1'); x2 = sym('x2');
            
            % Check with positions are arguments
            testCase.ODE.generateEquations(2,3,1,0,0);
            testCase.ODE.switchInputs(1,2);
            testCase.verifyEqual(testCase.ODE.inputNames,{'input2';'input1';'input3'},'The names of the inputs are not changed correctly if positions are used. (ODE: 2,3,1,0)');
            testCase.verifyEqual(testCase.ODE.inputUnits,{'si_2';'si_1';'si_3'},'The units of the inputs are not changed correctly if positions are used. (ODE: 2,3,1,0)');
            compare_f = [ ...
                u2 + 2*u1 + 3*u3 - x1;...
                u2 + 2*u1 + 3*u3 - x2];
            testCase.verifyEqual(testCase.ODE.f,compare_f,'The inputs in the equations f are not changed correctly if positions are used.. (ODE: 2,3,1,0)');
            testCase.verifyEqual(testCase.ODE.g,u2 + 2*u1 + 3*u3 - x1 - 2*x2 + 1,'The inputs in the equations g are not changed correctly if positions are used. (ODE: 2,3,1,0)');
            
            % Check with names as argument
            testCase.ODE.generateEquations(2,3,1,0,0);
            testCase.ODE.switchInputs('input3','input1');
            testCase.verifyEqual(testCase.ODE.inputNames,{'input3';'input2';'input1'},'The names of the inputs are not changed correctly if names are used. (ODE: 2,3,1,0)');
            testCase.verifyEqual(testCase.ODE.inputUnits,{'si_3';'si_2';'si_1'},'The units of the inputs are not changed correctly if names are used. (ODE: 2,3,1,0)');
            compare_f = [ ...
                u3 + 2*u2 + 3*u1 - x1;...
                u3 + 2*u2 + 3*u1 - x2];
            testCase.verifyEqual(testCase.ODE.f,compare_f,'The inputs in the equations f are not changed correctly if names are used. (ODE: 2,3,1,0)');
            testCase.verifyEqual(testCase.ODE.g,u3 + 2*u2 + 3*u1 - x1 - 2*x2 + 1,'The inputs in the equations g are not changed correctly if names are used. (ODE: 2,3,1,0)');
            
            % Check the equations for f are not changed if they are empty
            testCase.ODE.generateEquations(0,2,1,0,0);
            testCase.ODE.switchInputs(1,2);
            testCase.verifyEqual(testCase.ODE.f,[],'The equations f are not empty ([]) after the switch of the inputs. (ODE: 0,2,1,0)');
            
            % Check the equations for g are not changed if they are empty
            testCase.ODE.generateEquations(1,2,0,0,0);
            testCase.ODE.switchInputs(1,2);
            testCase.verifyEqual(testCase.ODE.g,[],'The equations g are not empty ([]) after the switch of the inputs. (ODE: 1,2,0,0)');
        end
        % ---------- checks for switchStates ------------------------------
        
        function check_SwitchStates_Errors(testCase)
            % Test if correct errors are thrown if no states exist
            testCase.ODE.generateEquations(0,3,3,3,0);
            testCase.verifyError(@()testCase.ODE.switchStates(1,2),'ODESCA_ODE:switchStates:InvalidArryIndex','The method does not throw a correct error if there are no states and the arguments are integers.');
            testCase.verifyError(@()testCase.ODE.switchStates('state1','state2'),'ODESCA_ODE:switchStates:InputNotFound','The method does not throw a correct error if there are no states and the arguments are strings.');

            % Test if correct errors are thrown on invalid inputs
            testCase.ODE.generateEquations(3,3,3,3,0);
            testCase.verifyError(@()testCase.ODE.switchStates([1,3],2),'ODESCA_ODE:switchStates:InvalidInputArguments','The method does not throw a correct error if on input is a numeric array.');
            testCase.verifyError(@()testCase.ODE.switchStates(1,sym('x2')),'ODESCA_ODE:switchStates:InvalidInputArguments','The method does not throw a correct error if on input is a symbolic variable.');
            
            % Test if correct errors are thrown on states that does not
            % exist or are out of index
            testCase.verifyError(@()testCase.ODE.switchStates(2,4),'ODESCA_ODE:switchStates:InvalidArryIndex','The method  does not throw a correct error if on input is out of bounds.');
            testCase.verifyError(@()testCase.ODE.switchStates('stateNo',2),'ODESCA_ODE:switchStates:InvalidInputArguments','The method does not throw a correct error if on input is a numeric array.');
        end
        
        function check_SwitchStates(testCase)
            % Prepare symbolic variables for the comparison
            syms u1 u2;
            syms x1 x2 x3;
            
            % Check with positions are arguments
            testCase.ODE.generateEquations(3,2,1,0,0);
            testCase.ODE.set_f([ ...
                u1 + 2*u2 - x1;...
                u1 + 2*u2 - x2^2;...
                u1 + 2*u2 - x3^3 + x1]);
            testCase.ODE.switchStates(1,2);
            testCase.verifyEqual(testCase.ODE.stateNames,{'state2';'state1';'state3'},'The names of the states are not changed correctly if positions are used. (ODE: 3,2,1,0)');
            testCase.verifyEqual(testCase.ODE.stateUnits,{'si_2';'si_1';'si_3'},'The units of the states are not changed correctly if positions are used. (ODE: 3,2,1,0)');
            compare_f = [ ...
                u1 + 2*u2 - x1^2;...
                u1 + 2*u2 - x2;...
                u1 + 2*u2 - x3^3 + x2];
            testCase.verifyEqual(testCase.ODE.f,compare_f,'The states in the equations f and the equations f are not changed correctly if positions are used.. (ODE: 3,2,1,0)');
            testCase.verifyEqual(testCase.ODE.g,u1 + 2*u2  - x2 - 2*x1 - 3*x3 + 1,'The states in the equations g are not changed correctly if positions are used. (ODE: 3,2,1,0)');
            
            % Check with names as argument
            testCase.ODE.generateEquations(3,2,1,0,0);
            testCase.ODE.set_f([ ...
                u1 + 2*u2 - x1;...
                u1 + 2*u2 - x2^2;...
                u1 + 2*u2 - x3^3 + x1]);
            testCase.ODE.switchStates('state3','state1');
            testCase.verifyEqual(testCase.ODE.stateNames,{'state3';'state2';'state1'},'The names of the states are not changed correctly if names are used. (ODE: 3,2,1,0)');
            testCase.verifyEqual(testCase.ODE.stateUnits,{'si_3';'si_2';'si_1'},'The units of the states are not changed correctly if names are used. (ODE: 3,2,1,0)');
            compare_f = ([ ...
                u1 + 2*u2 - x1^3 + x3;...
                u1 + 2*u2 - x2^2;...
                u1 + 2*u2 - x3]);
            testCase.verifyEqual(testCase.ODE.f,compare_f,'The states in the equations f and the equations f are not changed correctly if names are used. (ODE: 3,2,1,0)');
            testCase.verifyEqual(testCase.ODE.g,u1 + 2*u2  - x3 - 2*x2 - 3*x1 + 1,'The states in the equations g are not changed correctly if names are used. (ODE: 3,2,1,0)');
            
            % Check the equations for g are not changed if they are empty
            testCase.ODE.generateEquations(2,1,0,0,0);
            testCase.ODE.switchStates(1,2);
            testCase.verifyEqual(testCase.ODE.g,[],'The equations g are not empty ([]) after the switch of the states. (ODE: 2,1,0,0)');
        end
        
        % ---------- checks for switchOutputs -----------------------------
        
        function check_SwitchOutputs_Errors(testCase)
            % Test if correct errors are thrown if no outputs exist
            testCase.ODE.generateEquations(3,3,0,3,0);
            testCase.verifyError(@()testCase.ODE.switchOutputs(1,2),'ODESCA_ODE:switchOutputs:InvalidArryIndex','The method ''switchOutputs'' does not throw a correct error if there are no outputs and the arguments are integers.');
            testCase.verifyError(@()testCase.ODE.switchOutputs('output1','output2'),'ODESCA_ODE:switchOutputs:OutputNotFound','The method ''switchOutputs'' does not throw a correct error if there are no outputs and the arguments are strings.');

            % Test if correct errors are thrown on invalid outputs
            testCase.ODE.generateEquations(3,3,3,3,0);
            testCase.verifyError(@()testCase.ODE.switchOutputs([1,3],2),'ODESCA_ODE:switchOutputs:InvalidInputArguments','The method ''switchOutputs'' does not throw a correct error if on output is a numeric array.');
            testCase.verifyError(@()testCase.ODE.switchOutputs(1,sym('u2')),'ODESCA_ODE:switchOutputs:InvalidInputArguments','The method ''switchOutputs'' does not throw a correct error if on output is a symbolic variable.');
            
            % Test if correct errors are thrown on outputs that does not
            % exist or are out of index
            testCase.verifyError(@()testCase.ODE.switchOutputs(2,4),'ODESCA_ODE:switchOutputs:InvalidArryIndex','The method ''switchOutputs'' does not throw a correct error if on output is out of bounds.');
            testCase.verifyError(@()testCase.ODE.switchOutputs('outputNo',2),'ODESCA_ODE:switchOutputs:InvalidInputArguments', 'The method ''switchOutputs'' does not throw a correct error if on output is a numeric array.');
        end
        
        function check_SwitchOutputs(testCase)
            % Prepare symbolic variables for the comparison
            u1 = sym('u1'); u2 = sym('u2');
            x1 = sym('x1'); x2 = sym('x2');
            
            % Check with positions are arguments
            testCase.ODE.generateEquations(2,2,3,0,0);
            testCase.ODE.switchOutputs(1,2);
            compare_g = [...
                u1 + 2*u2 - x1 - 2*x2 + 2; ...
                u1 + 2*u2 - x1 - 2*x2 + 1; ...
                u1 + 2*u2 - x1 - 2*x2 + 3; ];
            testCase.verifyEqual(testCase.ODE.outputNames, {'output2';'output1';'output3'},'The names are not switched correctly with given output position.');
            testCase.verifyEqual(testCase.ODE.outputUnits, {'si_2';'si_1';'si_3'},'The units are not switched correctly with given output position.');
            testCase.verifyEqual(testCase.ODE.g, compare_g, 'The equations of g are not changed correctly if positions are used. (ODE: 2,3,2,0)');
            
            % Check with names are arguments
            testCase.ODE.generateEquations(2,2,3,0,0);
            testCase.ODE.switchOutputs('output3','output1');
            compare_g = [...
                u1 + 2*u2 - x1 - 2*x2 + 3; ...
                u1 + 2*u2 - x1 - 2*x2 + 2; ...
                u1 + 2*u2 - x1 - 2*x2 + 1; ];
            testCase.verifyEqual(testCase.ODE.outputNames, {'output3';'output2';'output1'},'The names are not switched correctly with given output name.');
            testCase.verifyEqual(testCase.ODE.outputUnits, {'si_3';'si_2';'si_1'},'The units are not switched correctly with given output name.');
            testCase.verifyEqual(testCase.ODE.g, compare_g, 'The equations of g are not changed correctly if positions are used. (ODE: 2,3,2,0)');
        end
        
        % ---------- checks for setParamAsInput ---------------------------
        
        function check_SetParamAsInput_Errors(testCase)
            testCase.verifyError(@()testCase.ODE.setParamAsInput(5),'ODESCA_ODE:setParamAsInput:ParameterNameMustBeString','The method ''setParamAsInput'' does not throw a correct error if the input argument is not a string.');
            testCase.verifyError(@()testCase.ODE.setParamAsInput('param1'),'ODESCA_ODE:setParamAsInput:NoParametersExist','The method ''setParamAsInput'' does not throw a correct error if the ODE does not have any parameters.');
            
            % Fill the ODE with parameters
            testCase.ODE.generateEquations(1,1,1,3,0);
            testCase.verifyError(@()testCase.ODE.setParamAsInput('toast'),'ODESCA_ODE:setParamAsInput:NotAParameter','The method ''setParamAsInput'' does not throw a correct error if the choosen parameter does not exist in the list of parameters.');
        end
        
        function check_SetParamAsInput(testCase)
            % Create symbolic variables for the test
            x1 = sym('x1');
            u1 = sym('u1'); u2 = sym('u2'); u3 = sym('u3');
            p1 = sym('param1'); p3 = sym('param3');
            
            % Check if the first set works
            testCase.ODE.generateEquations(1,1,1,3,0);
            testCase.ODE.setParamAsInput('param2');
            testCase.verifyEqual(testCase.ODE.u,[sym('u1');sym('u2')],'The array u is not extended correctly.');
            testCase.verifyEqual(testCase.ODE.inputNames,{'input1';'param2'},'The array inputNames is not changed correctly.')
            testCase.verifyEqual(testCase.ODE.inputUnits,{'si_1';'si_2'},'The array inputUnits is not changed correctly.')
            compare_param = struct;
            compare_param.param1 = [];
            compare_param.param3 = [];
            testCase.verifyEqual(testCase.ODE.param,compare_param,'The parameter structure is not changed correctly.');
            compare_f = u1 - x1 + u2^2 + p1 + p3^3;
            compare_g = compare_f + 1;
            testCase.verifyEqual(testCase.ODE.f,compare_f,'The parameter has not been replaced correctly in the equations f.');
            testCase.verifyEqual(testCase.ODE.g,compare_g,'The parameter has not been replaced correctly in the equations g.');         
            
            % Check if the second add of a parameter as input works correct
            testCase.ODE.setParamAsInput('param1');
            testCase.verifyEqual(testCase.ODE.u,[sym('u1');sym('u2');sym('u3')],'The array u is not extended correctly on setting a second parameter as input.');
            testCase.verifyEqual(testCase.ODE.inputNames,{'input1';'param2';'param1'},'The array inputNames is not changed correctly on setting a second parameter as input.');
            testCase.verifyEqual(testCase.ODE.inputUnits,{'si_1';'si_2';'si_1'},'The array inputNames is not changed correctly on setting a second parameter as input.');
            compare_param = struct;
            compare_param.param3 = [];
            testCase.verifyEqual(testCase.ODE.param,compare_param,'The field of the parameters is not set correctly on setting a second parameter as input.');
            compare_f = subs(compare_f,p1,u3);
            compare_g = subs(compare_g,p1,u3);
            testCase.verifyEqual(testCase.ODE.f,compare_f,'The parameter has not been replaced correctly in the equations f on the second set of a parameter as input.');
            testCase.verifyEqual(testCase.ODE.g,compare_g,'The parameter has not been replaced correctly in the equations g on the second set of a parameter as input');
        end
        
        % ---------- checks for setAllParamAsInputs -----------------------
        
        function check_SetAllParamAsInput(testCase)
            % Check if all parameters are set as input
            testCase.ODE.generateEquations(2,2,2,3,0);
            testCase.ODE.setAllParamAsInput();
            testCase.verifyEqual(testCase.ODE.inputNames, {'input1';'input2';'param1';'param2';'param3'}, 'The set of the inputNames list does not work correctly.');
            testCase.verifyEqual(testCase.ODE.inputUnits, {'si_1';'si_2';'si_1';'si_2';'si_3'}, 'The set of the inputUnits list does not work correctly.');
            testCase.verifyEqual(testCase.ODE.param, [],'The set of the parameters with symbolic variables does not work correctly');
        end
        
        % ---------- checks for getSymbolicStructure ----------------------
        
        function check_getSymbolicStructure(testCase)
            % Create symbolic variables for comparison
            x1 = sym('x1'); x2 = sym('x2');
            u1 = sym('u1'); u2 = sym('u2');
            p1 = sym('param1'); p2 = sym('param2');
            
            % Check if the structure is created correctly on an empty
            % ODE
            compare_symStruct.states  = [];
            compare_symStruct.inputs  = [];
            compare_symStruct.outputs = [];
            compare_symStruct.params  = [];
            symStruct = testCase.ODE.getSymbolicStructure();
            testCase.verifyEqual(symStruct,compare_symStruct,'The symbolic structure is not correct for empty systems.');
            
            % Check if the structre is created correctly on a full ODE
            testCase.ODE.generateEquations(2,2,2,2,0);
            compare_symStruct.states.state1  = x1;
            compare_symStruct.states.state2  = x2;
            compare_symStruct.inputs.input1  = u1;
            compare_symStruct.inputs.input2  = u2;
            compare_symStruct.outputs.output1 = p1 + u1 + 2*u2 - x1 - 2*x2 + p2^2 + 1;
            compare_symStruct.outputs.output2 = p1 + u1 + 2*u2 - x1 - 2*x2 + p2^2 + 2;
            compare_symStruct.params.param1  = p1;
            compare_symStruct.params.param2  = p2;
            symStruct = testCase.ODE.getSymbolicStructure();
            testCase.verifyEqual(symStruct,compare_symStruct,'The symbolic structure is not correct for full systems.');
        end
        
        % ---------- checks for renameParam -------------------------------
        
        function check_renameParam_Errors(testCase)
            % Check if an error occures if the ODE does not have
            % parameters
            testCase.verifyError(@()testCase.ODE.wrapped_renameParam('param1','length'),'ODESCA_ODE:renameParam:noParametersInODE','The method does not throw a correct error if the ODE does not have any parameters.');
            
            % Check if an error occures if the oldName is not a string
            testCase.ODE.generateEquations(2,2,2,2,0);
            testCase.verifyError(@()testCase.ODE.wrapped_renameParam(sym('param1'),'length'),'ODESCA_ODE:renameParam:oldNameNotAString','The method does not throw a correct error if the old name is not a string.');
            
            % Check if an error occures if the old parameter does not exist
            % in the system
            testCase.verifyError(@()testCase.ODE.wrapped_renameParam('param3','length'), 'ODESCA_ODE:renameParam:oldNameNotInODE','The method does not throw a correct error if the parameter does not exist.');
            
            % Check if an error is thrown if the new name is not a variable
            % name or longer the 31 characters
            testCase.verifyError(@()testCase.ODE.wrapped_renameParam('param1','#bullshit?'), 'ODESCA_ODE:renameParam:newNameNotValid', 'The method does not throw a correct error if the new name is not a valid MATLAB variable name.');
            
            % Check if an error is thrown if a state, input or parameter
            % exists which already have the new name
            testCase.verifyError(@()testCase.ODE.wrapped_renameParam('param1','state1'), 'ODESCA_System:renameParam:newNameAlreadyInODE', 'The method does not throw a correct error if an state with the new name already exists.');
            testCase.verifyError(@()testCase.ODE.wrapped_renameParam('param1','input1'), 'ODESCA_System:renameParam:newNameAlreadyInODE', 'The method does not throw a correct error if an input with the new name already exists.');
            testCase.verifyError(@()testCase.ODE.wrapped_renameParam('param1','param2'), 'ODESCA_System:renameParam:newNameAlreadyInODE', 'The method does not throw a correct error if a parameter with the new name already exists.');
        end
        
        function check_renameParam(testCase)
            % Create symbolic variables for the test
            x1 = sym('x1'); x2 = sym('x2');
            u1 = sym('u1'); u2 = sym('u2');
            p1 = sym('param1');
            length = sym('length');
            
            % Check if the rename of the parameter works on normal
            % parameters
            testCase.ODE.generateEquations(2,2,2,2,0);
            testCase.ODE.setParam('param2',7);
            testCase.ODE.wrapped_renameParam('param2','length');
            testCase.verifyEqual(testCase.ODE.f,[ length^2 + p1 + u1 + 2*u2 - x1; length^2 + p1 + u1 + 2*u2 - x2],'The parameter name was not changed correctly in the equations of f.');
            testCase.verifyEqual(testCase.ODE.g,[ length^2 + p1 + u1 + 2*u2 - x1 - 2*x2 + 1; length^2 + p1 + u1 + 2*u2 - x1 - 2*x2 + 2;],'The parameter name was not changed correctly in the equations of g.');
            compare_param.param1 = [];
            compare_param.length = 7;
            testCase.verifyEqual(testCase.ODE.param,compare_param,'The param structure is not changed correctly.');
        end
        
        % ---------- checks for removeParam -------------------------------
        
        function check_removeParam_Errors(testCase)
            % Check if an error occures if the ODE does not have
            % parameters
            testCase.ODE.generateEquations(2,2,2,0,0);
            testCase.verifyError(@()testCase.ODE.wrapped_removeParam('param1'),'ODESCA_ODE:removeParam:noParametersInODE','The method does not throw a correct error if the ODE does not have any parameters.');
            
            % Check if an error occures if the parameter is not a string
            testCase.ODE.generateEquations(2,2,2,2,0);
            testCase.verifyError(@()testCase.ODE.wrapped_removeParam(sym('param1')),'ODESCA_ODE:removeParam:parameterNameIsNoString','The method does not throw a correct error if the parameter name is not a string.');
            
            % Check if an error occures if the parameter does not exist
            % in the system
            testCase.verifyError(@()testCase.ODE.wrapped_removeParam('param3'), 'ODESCA_ODE:removeParam:paramNameNotInODE','The method does not throw a correct error if the parameter does not exist.');
            
            % Check if an error is thrown if the parameter still appears 
            % in equations
            testCase.verifyError(@()testCase.ODE.wrapped_removeParam('param1'), 'ODESCA_ODE:removeParam:paramInEquations', 'The method does not throw a correct error if the parameter still appears in the equations.');
        end
        
        function check_removeParam(testCase)
            % Check if the remove of the parameter works on normal
            % parameters
            testCase.ODE.generateEquations(2,2,2,2,1);
            testCase.ODE.wrapped_removeParam('param_u1');
            compare_param.param1 = [];
            compare_param.param2 = [];
            testCase.verifyEqual(testCase.ODE.param,compare_param,'The param structure is not changed correctly.');
            testCase.verifyEqual(testCase.ODE.p,sym('param',[2,1]),'The p vector is not changed correctly.');
            testCase.verifyEqual(testCase.ODE.paramUnits,{'si_1';'si_2'},'The paramUnits cell is not changed correctly.');
        end
        
        % ---------- checks for removeSymbolicInput -----------------------
        
        function check_removeSymbolicInput(testCase)
            % Create symbolic variables for the test
            x1 = sym('x1'); x2 = sym('x2');
            u1 = sym('u1'); u2 = sym('u2');  u3 = sym('u3');  u4 = sym('u4'); u5 = sym('u5');
            r1 = sym('REPLACED_1'); r2 = sym('REPLACED_2');
            
            % Check the method if the last input is removed
            testCase.ODE.generateEquations(2,5,1,0,0);
            testCase.ODE.set_f(subs(testCase.ODE.f,u5,r1));
            testCase.ODE.set_g(subs(testCase.ODE.g,u5,r1));
            testCase.ODE.wrapped_removeSymbolicInput(5);
            testCase.verifyEqual(testCase.ODE.f,[u1 + 2*u2 + 3*u3 + 4*u4 + 5*r1 - x1; u1 + 2*u2 + 3*u3 + 4*u4 + 5*r1 - x2],'The equations f are not correct after removing the last input.');
            testCase.verifyEqual(testCase.ODE.g, u1 + 2*u2 + 3*u3 + 4*u4 + 5*r1 - x1 - 2*x2 + 1,'The equations g are not correct after removing the last input.');
            testCase.verifyEqual(testCase.ODE.u, [u1; u2; u3; u4], 'The input list u is not correct after removing the last input.');
            testCase.verifyEqual(testCase.ODE.inputNames, {'input1'; 'input2'; 'input3'; 'input4'},'The inputName list is not correct after removing the last input.');
            testCase.verifyEqual(testCase.ODE.inputUnits, {'si_1'; 'si_2'; 'si_3'; 'si_4'},'The inputUnit list is not correct after removing the last input.');
            
            % Check the method if a input in the middle of the input list
            % is removed
            testCase.ODE.set_f(subs(testCase.ODE.f,u2,r2));
            testCase.ODE.set_g(subs(testCase.ODE.g,u2,r2));
            testCase.ODE.wrapped_removeSymbolicInput(2);
            testCase.verifyEqual(testCase.ODE.f,[u1 + 2*r2 + 3*u2 + 4*u3 + 5*r1 - x1; u1 + 2*r2 + 3*u2 + 4*u3 + 5*r1 - x2],'The equations f are not correct after removing an input in the middle.');
            testCase.verifyEqual(testCase.ODE.g, u1 + 2*r2 + 3*u2 + 4*u3 + 5*r1 - x1 - 2*x2 + 1,'The equations g are not correct after removing an input in the middle.');
            testCase.verifyEqual(testCase.ODE.u, [u1; u2; u3;], 'The input list u is not correct after an input in the middle.');
            testCase.verifyEqual(testCase.ODE.inputNames, {'input1'; 'input3'; 'input4'},'The inputName list is not correct after removing an input in the middle.');
            testCase.verifyEqual(testCase.ODE.inputUnits, {'si_1'; 'si_3'; 'si_4'},'The inputUnit list is not correct after removing an input in the middle.');
        end
        
        % ---------- checks for show --------------------------------------
        
        function  check_show_Errors(testCase)
            % Create system to call show function with wrong inputs
            testCase.ODE.generateEquations(3,3,3,3,0);
            
            testCase.verifyError(@()testCase.ODE.show('string'),'ODESCA_System:show:wrongInputType','The method does not throw a correct error if the first input is a string.');
            testCase.verifyError(@()testCase.ODE.show([1 2 3]),'ODESCA_System:show:wrongInputType','The method does not throw a correct error if the first input is vectorized.');
            testCase.verifyError(@()testCase.ODE.show({1,2,3}),'ODESCA_System:show:wrongInputType','The method does not throw a correct error if the first input is a cell.');
        end
        
        function check_show(testCase)
            
           % Create ODE with different number of states, inputs, outputs
           % and parameters. If show-function runs without an error test is
           % passed. It is not checked if the output is correcty generated
           % (Evalc() is used to supress display output in matlab
           % promt.)
           testCase.ODE.generateEquations(3,3,3,3,0);
           evalc('testCase.ODE.show();');
           
           testCase.ODE.generateEquations(1,1,1,1,0);
           evalc('testCase.ODE.show();');
           
           testCase.ODE.generateEquations(0,3,3,3,0);
           evalc('testCase.ODE.show();');
                       
           testCase.ODE.generateEquations(3,0,3,3,0);
           evalc('testCase.ODE.show();');
           
           testCase.ODE.generateEquations(3,3,0,3,0);
           evalc('testCase.ODE.show();');
           
           testCase.ODE.generateEquations(3,3,3,0,0);
           evalc('testCase.ODE.show();');
           
           testCase.ODE.generateEquations(0,0,1,0,0);
           evalc('testCase.ODE.show();');
            
        end
        
        % ---------- checks for reactOnEquationChange----------------------
        
        function check_reactOnEquationChange(testCase)
            % check if the abstract class is there and can be called
            testCase.verifyEqual(testCase.ODE.wrapped_reactOnEquationsChange(), true, 'The abstract method ''reactOnEquationChange'' can not be called.'); 
        end                                      
        
    end
    
    % Methods used only inside the test
    methods(Access = private)
        
    end
end

