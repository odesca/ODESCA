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

classdef Test_ODESCA_Object < matlab.unittest.TestCase
    %ODESCA_Object_Test Class to test ODESCA_Object
    %
    % DESCRIPTION
    %   This class test the class ODESCA_Object for the correct working of
    %   all methods and properties.
    %
    % ODESCA_Object_Test
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
        object
    end
    
    % Method to create new ODESCA_Object for every test method
    methods(TestMethodSetup)
        function createObject(testCase)
            testCase.object = Test_Wrapper_ODESCA_Object();
        end
    end
    
    % Method to remove instance of the ODESCA_Object which was tested
    methods(TestMethodTeardown)
        function removeObject(testCase)
            testCase.object = [];
        end
    end
    
    methods(Test)
        % ---------- checks for the object itself -------------------------
        
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
                    testCase.object.(name) = 1;
                catch err
                    result = err.identifier;
                end
                testCase.verifyEqual(result,'MATLAB:class:SetProhibited',['The public set access for the propertie ''',name,''' is not prohibited.']);
            end
        end
        
        % Check if the particular methods have a private access premission
        function check_MethodAccessProhibited(testCase)
            testCase.verifyError(@()testCase.object.addParameters({'Param1','Param2'}), 'MATLAB:class:MethodRestricted', 'The method ''addParameters'' of the class ''ODESCA_Object'' don''t have a restricted access.');
            testCase.verifyError(@()testCase.object.initializeObject(), 'MATLAB:class:MethodRestricted', 'The method ''initializeObject'' of the class ''ODESCA_Object'' don''t have a restricted access.');
            testCase.verifyError(@()testCase.object.removeSymbolicInput(1), 'MATLAB:class:MethodRestricted', 'The method ''removeSymbolicInput'' of the class ''ODESCA_Object'' don''t have a restricted access.');
            testCase.verifyError(@()testCase.object.renameParam('Param1''Param2'), 'MATLAB:class:MethodRestricted', 'The method ''renameParam'' of the class ''ODESCA_Object'' don''t have a restricted access.');
        end
              
        % Check if the name is set to the argument given in the constructor
        function check_NameSetInConstructor(testCase)
            testCase.verifyEqual(testCase.object.name,'Default', 'The property ''name'' of class ''ODESCA_Object'' is not set correctly.');
        end
        
        % ---------- checks for initializeObject() ------------------------
        % Check if the properties are initialized empty in constructor
        
        function check_PropertiesInitializedEmpty(testCase)
            
            testCase.verifyEmpty(testCase.object.param,         'The property ''param'' of class ''ODESCA_Object'' is not initialized emtpy.');
            testCase.verifyEmpty(testCase.object.p,             'The property ''p'' of class ''ODESCA_Object'' is not initialized emtpy.');
            testCase.verifyEmpty(testCase.object.f,             'The property ''f'' of class ''ODESCA_Object'' is not initialized emtpy.');
            testCase.verifyEmpty(testCase.object.g,             'The property ''g'' of class ''ODESCA_Object'' is not initialized emtpy.');
            testCase.verifyEmpty(testCase.object.x,             'The property ''x'' of class ''ODESCA_Object'' is not initialized emtpy.');
            testCase.verifyEmpty(testCase.object.u,             'The property ''u'' of class ''ODESCA_Object'' is not initialized emtpy.');
            testCase.verifyEmpty(testCase.object.stateNames,    'The property ''stateNames'' of class ''ODESCA_Object'' is not initialized emtpy.');
            testCase.verifyEmpty(testCase.object.inputNames,    'The property ''inputNames'' of class ''ODESCA_Object'' is not initialized emtpy.');
            testCase.verifyEmpty(testCase.object.outputNames,   'The property ''outputNames'' of class ''ODESCA_Object'' is not initialized emtpy.');
            testCase.verifyEmpty(testCase.object.stateUnits,    'The property ''stateUnits'' of class ''ODESCA_Object'' is not initialized emtpy.');
            testCase.verifyEmpty(testCase.object.inputUnits,    'The property ''inputUnits'' of class ''ODESCA_Object'' is not initialized emtpy.');
            testCase.verifyEmpty(testCase.object.outputUnits,   'The property ''outputUnits'' of class ''ODESCA_Object'' is not initialized emtpy.');
            testCase.verifyEmpty(testCase.object.paramUnits,    'The property ''paramUnits'' of class ''ODESCA_Object'' is not initialized emtpy.');
        end
              
        % ---------- checks for setName() ---------------------------------
        
        function check_SetName_Errors(testCase)
            testCase.verifyError(@()testCase.object.setName('####'), 'ODESCA_Object:setName:InvalidName','Setting the name to an invalid variable name is not prohibited.');
            testCase.verifyError(@()testCase.object.setName('Name_With_Underscores'), 'ODESCA_Object:setName:UnderscoreInName', 'Setting the name with underscores is not prohibited.');
            testCase.verifyError(@()testCase.object.setName('abcdeabcdeabcdeabcdeabcdeabcdeabcde'), 'ODESCA_Object:setName:InvalidNameLength', 'Setting the name to a string longer then 31 characters is not prohibited.');
        end
        
        function check_SetName(testCase)
            testCase.object.setName('testName');
            testCase.verifyEqual(testCase.object.name,'testName','The name was not set correctly during the call of setName()');
        end
        
        % ---------- checks for addParameters() ---------------------------
        
        function check_AddParameters_Errors(testCase)
            testCase.verifyError(@()testCase.object.wrapped_addParameters([5,7],{'si_1','si_2'}), 'ODESCA_Object:addParameters:inputNotACellArray', 'Giving a non cell array to the method does not throw a correct error.');
            testCase.verifyError(@()testCase.object.wrapped_addParameters({'param1','#test'},{'si_1','si_2'}), 'ODESCA_Object:addParameters:parameterNameNotValid', 'A parameter name which is not a valid MATLAB variable name does not throw a correct error.');
            testCase.verifyError(@()testCase.object.wrapped_addParameters({'param1','abcdefghijabcdefghijabcdefghij123'},{'si_1','si_2'}), 'ODESCA_Object:addParameters:parameterNameTooLong', 'A parameter name which is longer than 31 characters does not throw a correct error.');
        end
        
        function check_AddParameters(testCase)
            % Check the method with an empty object
            % Check preconditions
            testCase.verifyEqual(testCase.object.param, [], 'The property ''param'' is not empty on a new created object.');
            testCase.verifyEqual(testCase.object.p, [], 'The property ''p'' is not empty on a new created object');
            
            % Prepare the compare variables
            compareParam = struct;
            compareParam.param1 = [];
            compareParam.param2 = [];
            compareSymParam = [sym('param1'); sym('param2')];
            
            % Perform the test
            returnedSymbolic = testCase.object.wrapped_addParameters({'param1', 'param2'},{'si_1','si_2'});
            testCase.verifyEqual(testCase.object.param, compareParam, 'The parameter structure has not been created correctly.');
            testCase.verifyEqual(testCase.object.p, compareSymParam, 'The sysmbolic parameter array has not been set correctly.');
            testCase.verifyEqual(returnedSymbolic, compareSymParam, 'The returned symbolic array is not correct.');
            testCase.verifyEqual(testCase.object.paramUnits, {'si_1';'si_2'}, 'The parameter untis have not been set correctly.');
            
            
            % Check the method with parameters
            % Prepare the object
            testCase.object = Test_Wrapper_ODESCA_Object();
            testCase.object.wrapped_addParameters({'param1','param2'},{'si_1','si_2'});
            testCase.assertEqual(fieldnames(testCase.object.param),{'param1';'param2'},'The adding of the initial parameters does not work correctly so the test is aborted.');
            
            % Prepare compare variables
            compareParam = struct;
            compareParam.param1 = [];
            compareParam.param2 = [];
            compareParam.paramA = [];
            compareParam.paramB = [];
            compareReturnedSymParam = [sym('paramA'); sym('paramB')];
            compareSymParam = [sym('param1'); sym('param2'); compareReturnedSymParam];
            
            % Perform the test
            returnedSymbolic = testCase.object.wrapped_addParameters({'param2', 'paramA', 'paramB'},{'si_2','si_A','si_B'});
            testCase.verifyEqual(testCase.object.param, compareParam, 'The parameter structure has not been created correctly.');
            testCase.verifyEqual(testCase.object.p, compareSymParam, 'The sysmbolic parameter array has not been set correctly.');
            testCase.verifyEqual(returnedSymbolic, compareReturnedSymParam, 'The returned symbolic array is not correct.');
            testCase.verifyEqual(testCase.object.paramUnits, {'si_1';'si_2';'si_A';'si_B'}, 'The parameter units have not been set correctly.');
        end
        
        % ---------- checks for checkParam --------------------------------
        
        function check_CheckParam(testCase)
            % Check the method without parameters
            testCase.verifyTrue(testCase.object.checkParam(),'The method ''checkParam'' does not return true on a component without parameters');
            
            % Check the method with parameters
            % Prepare the object
            testCase.object.wrapped_addParameters({'param1','param2','param3'},{'si_1','si_2','si_3'});
            testCase.assertEqual(fieldnames(testCase.object.param),{'param1';'param2';'param3'},'The adding of the initial parameters does not work correctly so the test is aborted.');
            testCase.assertEqual(testCase.object.paramUnits, {'si_1';'si_2';'si_3'}, 'The adding of the initial parameter units does not work correctly so the test is aborted.');
            
            % Check the output of checkParam
            testCase.verifyFalse(testCase.object.checkParam(), 'The method ''checkParam'' does not return false with all parameters unset.');
            testCase.object.setParam('param1',5);
            testCase.object.setParam('param3',7);
            testCase.verifyFalse(testCase.object.checkParam(), 'The method ''checkParam'' does not return false with some parameters unset.');
            testCase.object.setParam('param2',1);
            testCase.verifyTrue(testCase.object.checkParam(), 'The method ''checkParam'' does not return true with all parameters set.');
        end
        
        % ---------- checks for calculateNumericEquations -----------------
        
        function check_CalculateNumericEquations_Errors(testCase)
            % Prepare the object
            testCase.object.wrapped_addParameters({'param1','param2'},{'si_1','si_2'});
            testCase.assertEqual(fieldnames(testCase.object.param),{'param1';'param2'},'The adding of the initial parameters does not work correctly so the test is aborted.');
            
            % Check for the error because of unset parameters
            testCase.verifyError(@()testCase.object.calculateNumericEquations(),'ODESCA_Object:calculateNumericEquations:notAllParametersSet','Calling the method ''calculateNumericEquations'' does not throw a correct error with unset parameters.');
        end
        
        function check_CalculateNumericEquations(testCase)
            % Check a object with no parameters
            % Prepare the object
            f = [5 * sym('x1'); sym('x2') / 2 - sym('x1')];
            g = sym('x1') + sym('x2');
            testCase.object.set_f(f);
            testCase.object.set_g(g);
            
            % Perform the calculation
            [actualF, actualG] = testCase.object.calculateNumericEquations();
            testCase.verifyEqual(actualF,f,'The equations ''f'' have changed also they should not.')
            testCase.verifyEqual(actualG,g,'The equations ''g'' have changed also they should not.')
            
            
            % Check a object with parameters
            % Create an empty object for the next part of the test
            testCase.object = Test_Wrapper_ODESCA_Object();
            
            % Prepare the object
            testCase.object.wrapped_addParameters({'A','B'},{'si_A','si_B'});
            testCase.assertEqual(fieldnames(testCase.object.param),{'A';'B'},'The adding of the initial parameters does not work correctly so the test is aborted.');
            
            f = [sym('A') * sym('x1'); sym('x2') * sym('B') / 2 - sym('x1')];
            g = sym('x1') + sym('x2') + sym('B');
            testCase.object.set_f(f);
            testCase.object.set_g(g);
            
            f = [3 * sym('x1'); sym('x2') * 4 - sym('x1')];
            g = sym('x1') + sym('x2') + 8;
            testCase.object.setParam('A',3);
            testCase.object.setParam('B',8);
            
            % Perform the calculation
            [actualF, actualG] = testCase.object.calculateNumericEquations();
            testCase.verifyEqual(actualF,f,'The equations ''f'' are not calculated correctly.')
            testCase.verifyEqual(actualG,g,'The equations ''g'' are not calculated correctly.')
            
        end
        
        % ---------- checks for switchInputs ------------------------------
        
        function check_SwitchInputs_Errors(testCase)
            % Test if correct errors are thrown on invalid inputs
            testCase.object.generateEquations(3,3,3,3);
            testCase.verifyError(@()testCase.object.switchInputs([1,3],2),'ODESCA_Object:switchInputs:InvalidInputArguments','The method ''switchInputs'' does not throw a correct error if on input is a numeric array.');
            testCase.verifyError(@()testCase.object.switchInputs(1,sym('u2')),'ODESCA_Object:switchInputs:InvalidInputArguments','The method ''switchInputs'' does not throw a correct error if on input is a symbolic variable.');
            
            % Test if correct errors are thrown on inputs that does not
            % exist or are out of index
            testCase.verifyError(@()testCase.object.switchInputs(2,4),'ODESCA_Object:switchInputs:InvalidArryIndex','The method ''switchInputs'' does not throw a correct error if on input is out of bounds.');
            testCase.verifyError(@()testCase.object.switchInputs('inputNo',2),'ODESCA_Object:switchInputs:InvalidInputArguments','The method ''switchInputs'' does not throw a correct error if on input is a numeric array.');
            
            % Test if correct errors are thrown if no inputs exist
            testCase.object.generateEquations(3,0,3,3);
            testCase.verifyError(@()testCase.object.switchInputs(1,2),'ODESCA_Object:switchInputs:InvalidArryIndex','The method ''switchInputs'' does not throw a correct error if there are no inputs and the arguments are integers.');
            testCase.verifyError(@()testCase.object.switchInputs('input1','input2'),'ODESCA_Object:switchInputs:InputNotFound','The method ''switchInputs'' does not throw a correct error if there are no inputs and the arguments are strings.');
        end
        
        function check_SwitchInputs(testCase)
            % Prepare symbolic variables for the comparison
            u1 = sym('u1'); u2 = sym('u2'); u3 = sym('u3');
            x1 = sym('x1'); x2 = sym('x2');
            
            % Check with positions are arguments
            testCase.object.generateEquations(2,3,1,0);
            testCase.object.switchInputs(1,2);
            testCase.verifyEqual(testCase.object.inputNames,{'input2';'input1';'input3'},'The names of the inputs are not changed correctly if positions are used. (Object: 2,3,1,0)');
            testCase.verifyEqual(testCase.object.inputUnits,{'si_2';'si_1';'si_3'},'The units of the inputs are not changed correctly if positions are used. (Object: 2,3,1,0)');
            compare_f = [ ...
                u2 + 2*u1 + 3*u3 - x1;...
                u2 + 2*u1 + 3*u3 - x2];
            testCase.verifyEqual(testCase.object.f,compare_f,'The inputs in the equations f are not changed correctly if positions are used.. (Object: 2,3,1,0)');
            testCase.verifyEqual(testCase.object.g,u2 + 2*u1 + 3*u3 - x1 - 2*x2 + 1,'The inputs in the equations g are not changed correctly if positions are used. (Object: 2,3,1,0)');
            
            % Check with names as argument
            testCase.object.generateEquations(2,3,1,0);
            testCase.object.switchInputs('input3','input1');
            testCase.verifyEqual(testCase.object.inputNames,{'input3';'input2';'input1'},'The names of the inputs are not changed correctly if names are used. (Object: 2,3,1,0)');
            testCase.verifyEqual(testCase.object.inputUnits,{'si_3';'si_2';'si_1'},'The units of the inputs are not changed correctly if names are used. (Object: 2,3,1,0)');
            compare_f = [ ...
                u3 + 2*u2 + 3*u1 - x1;...
                u3 + 2*u2 + 3*u1 - x2];
            testCase.verifyEqual(testCase.object.f,compare_f,'The inputs in the equations f are not changed correctly if names are used. (Object: 2,3,1,0)');
            testCase.verifyEqual(testCase.object.g,u3 + 2*u2 + 3*u1 - x1 - 2*x2 + 1,'The inputs in the equations g are not changed correctly if names are used. (Object: 2,3,1,0)');
            
            % Check the equations for f are not changed if they are empty
            testCase.object.generateEquations(0,2,1,0);
            testCase.object.switchInputs(1,2);
            testCase.verifyEqual(testCase.object.f,[],'The equations f are not empty ([]) after the switch of the inputs. (Object: 0,2,1,0)');
            
            % Check the equations for g are not changed if they are empty
            testCase.object.generateEquations(1,2,0,0);
            testCase.object.switchInputs(1,2);
            testCase.verifyEqual(testCase.object.g,[],'The equations g are not empty ([]) after the switch of the inputs. (Object: 1,2,0,0)');
        end
        % ---------- checks for switchStates ------------------------------
        
        function check_SwitchStates_Errors(testCase)
            % Test if correct errors are thrown on invalid inputs
            testCase.object.generateEquations(3,3,3,3);
            testCase.verifyError(@()testCase.object.switchStates([1,3],2),'ODESCA_Object:switchStates:InvalidInputArguments','The method does not throw a correct error if on input is a numeric array.');
            testCase.verifyError(@()testCase.object.switchStates(1,sym('x2')),'ODESCA_Object:switchStates:InvalidInputArguments','The method does not throw a correct error if on input is a symbolic variable.');
            
            % Test if correct errors are thrown on states that does not
            % exist or are out of index
            testCase.verifyError(@()testCase.object.switchStates(2,4),'ODESCA_Object:switchStates:InvalidArryIndex','The method  does not throw a correct error if on input is out of bounds.');
            testCase.verifyError(@()testCase.object.switchStates('stateNo',2),'ODESCA_Object:switchStates:InvalidInputArguments','The method does not throw a correct error if on input is a numeric array.');
            
            % Test if correct errors are thrown if no states exist
            testCase.object.generateEquations(0,3,3,3);
            testCase.verifyError(@()testCase.object.switchStates(1,2),'ODESCA_Object:switchStates:InvalidArryIndex','The method does not throw a correct error if there are no states and the arguments are integers.');
            testCase.verifyError(@()testCase.object.switchStates('state1','state2'),'ODESCA_Object:switchStates:InputNotFound','The method does not throw a correct error if there are no states and the arguments are strings.');
        end
        
        function check_SwitchStates(testCase)
            % Prepare symbolic variables for the comparison
            syms u1 u2;
            syms x1 x2 x3;
            
            % Check with positions are arguments
            testCase.object.generateEquations(3,2,1,0);
            testCase.object.set_f([ ...
                u1 + 2*u2 - x1;...
                u1 + 2*u2 - x2^2;...
                u1 + 2*u2 - x3^3 + x1]);
            testCase.object.switchStates(1,2);
            testCase.verifyEqual(testCase.object.stateNames,{'state2';'state1';'state3'},'The names of the states are not changed correctly if positions are used. (Object: 3,2,1,0)');
            testCase.verifyEqual(testCase.object.stateUnits,{'si_2';'si_1';'si_3'},'The units of the states are not changed correctly if positions are used. (Object: 3,2,1,0)');
            compare_f = [ ...
                u1 + 2*u2 - x1^2;...
                u1 + 2*u2 - x2;...
                u1 + 2*u2 - x3^3 + x2];
            testCase.verifyEqual(testCase.object.f,compare_f,'The states in the equations f and the equations f are not changed correctly if positions are used.. (Object: 3,2,1,0)');
            testCase.verifyEqual(testCase.object.g,u1 + 2*u2  - x2 - 2*x1 - 3*x3 + 1,'The states in the equations g are not changed correctly if positions are used. (Object: 3,2,1,0)');
            
            % Check with names as argument
            testCase.object.generateEquations(3,2,1,0);
            testCase.object.set_f([ ...
                u1 + 2*u2 - x1;...
                u1 + 2*u2 - x2^2;...
                u1 + 2*u2 - x3^3 + x1]);
            testCase.object.switchStates('state3','state1');
            testCase.verifyEqual(testCase.object.stateNames,{'state3';'state2';'state1'},'The names of the states are not changed correctly if names are used. (Object: 3,2,1,0)');
            testCase.verifyEqual(testCase.object.stateUnits,{'si_3';'si_2';'si_1'},'The units of the states are not changed correctly if names are used. (Object: 3,2,1,0)');
            compare_f = ([ ...
                u1 + 2*u2 - x1^3 + x3;...
                u1 + 2*u2 - x2^2;...
                u1 + 2*u2 - x3]);
            testCase.verifyEqual(testCase.object.f,compare_f,'The states in the equations f and the equations f are not changed correctly if names are used. (Object: 3,2,1,0)');
            testCase.verifyEqual(testCase.object.g,u1 + 2*u2  - x3 - 2*x2 - 3*x1 + 1,'The states in the equations g are not changed correctly if names are used. (Object: 3,2,1,0)');
            
            % Check the equations for g are not changed if they are empty
            testCase.object.generateEquations(2,1,0,0);
            testCase.object.switchStates(1,2);
            testCase.verifyEqual(testCase.object.g,[],'The equations g are not empty ([]) after the switch of the states. (Object: 2,1,0,0)');
        end
        
        % ---------- checks for switchOutputs -----------------------------
        
        function check_SwitchOutputs_Errors(testCase)
            % Test if correct errors are thrown on invalid outputs
            testCase.object.generateEquations(3,3,3,3);
            testCase.verifyError(@()testCase.object.switchOutputs([1,3],2),'ODESCA_Object:switchOutputs:InvalidInputArguments','The method ''switchOutputs'' does not throw a correct error if on output is a numeric array.');
            testCase.verifyError(@()testCase.object.switchOutputs(1,sym('u2')),'ODESCA_Object:switchOutputs:InvalidInputArguments','The method ''switchOutputs'' does not throw a correct error if on output is a symbolic variable.');
            
            % Test if correct errors are thrown on outputs that does not
            % exist or are out of index
            testCase.verifyError(@()testCase.object.switchOutputs(2,4),'ODESCA_Object:switchOutputs:InvalidArryIndex','The method ''switchOutputs'' does not throw a correct error if on output is out of bounds.');
            testCase.verifyError(@()testCase.object.switchOutputs('outputNo',2),'ODESCA_Object:switchOutputs:InvalidInputArguments', 'The method ''switchOutputs'' does not throw a correct error if on output is a numeric array.');
            
            % Test if correct errors are thrown if no outputs exist
            testCase.object.generateEquations(3,3,0,3);
            testCase.verifyError(@()testCase.object.switchOutputs(1,2),'ODESCA_Object:switchOutputs:InvalidArryIndex','The method ''switchOutputs'' does not throw a correct error if there are no outputs and the arguments are integers.');
            testCase.verifyError(@()testCase.object.switchOutputs('output1','output2'),'ODESCA_Object:switchOutputs:OutputNotFound','The method ''switchOutputs'' does not throw a correct error if there are no outputs and the arguments are strings.');
        end
        
        function check_SwitchOutputs(testCase)
            % Prepare symbolic variables for the comparison
            u1 = sym('u1'); u2 = sym('u2');
            x1 = sym('x1'); x2 = sym('x2');
            
            % Check with positions are arguments
            testCase.object.generateEquations(2,2,3,0);
            testCase.object.switchOutputs(1,2);
            compare_g = [...
                u1 + 2*u2 - x1 - 2*x2 + 2; ...
                u1 + 2*u2 - x1 - 2*x2 + 1; ...
                u1 + 2*u2 - x1 - 2*x2 + 3; ];
            testCase.verifyEqual(testCase.object.outputNames, {'output2';'output1';'output3'},'The names are not switched correctly with given output position.');
            testCase.verifyEqual(testCase.object.outputUnits, {'si_2';'si_1';'si_3'},'The units are not switched correctly with given output position.');
            testCase.verifyEqual(testCase.object.g, compare_g, 'The equations of g are not changed correctly if positions are used. (Object: 2,3,2,0)');
            
            % Check with names are arguments
            testCase.object.generateEquations(2,2,3,0);
            testCase.object.switchOutputs('output3','output1');
            compare_g = [...
                u1 + 2*u2 - x1 - 2*x2 + 3; ...
                u1 + 2*u2 - x1 - 2*x2 + 2; ...
                u1 + 2*u2 - x1 - 2*x2 + 1; ];
            testCase.verifyEqual(testCase.object.outputNames, {'output3';'output2';'output1'},'The names are not switched correctly with given output name.');
            testCase.verifyEqual(testCase.object.outputUnits, {'si_3';'si_2';'si_1'},'The units are not switched correctly with given output name.');
            testCase.verifyEqual(testCase.object.g, compare_g, 'The equations of g are not changed correctly if positions are used. (Object: 2,3,2,0)');
        end
        
        % ---------- checks for setParamAsInput ---------------------------
        
        function check_SetParamAsInput_Errors(testCase)
            testCase.verifyError(@()testCase.object.setParamAsInput(5),'ODESCA_Object:setParamAsInput:ParameterNameMustBeString','The method ''setParamAsInput'' does not throw a correct error if the input argument is not a string.');
            testCase.verifyError(@()testCase.object.setParamAsInput('param1'),'ODESCA_Object:setParamAsInput:NoParametersExist','The method ''setParamAsInput'' does not throw a correct error if the object does not have any parameters.');
            
            % Fill the object with parameters
            testCase.object.generateEquations(1,1,1,3);
            testCase.verifyError(@()testCase.object.setParamAsInput('toast'),'ODESCA_Object:setParamAsInput:NotAParameter','The method ''setParamAsInput'' does not throw a correct error if the choosen parameter does not exist in the list of parameters.');
        end
        
        function check_SetParamAsInput(testCase)
            % Create symbolic variables for the test
            x1 = sym('x1');
            u1 = sym('u1'); u2 = sym('u2'); u3 = sym('u3');
            p1 = sym('param1'); p3 = sym('param3');
            
            % Check if the first set works
            testCase.object.generateEquations(1,1,1,3);
            testCase.object.setParamAsInput('param2');
            testCase.verifyEqual(testCase.object.u,[sym('u1');sym('u2')],'The array u is not extended correctly.');
            testCase.verifyEqual(testCase.object.inputNames,{'input1';'param2'},'The array inputNames is not changed correctly.')
            testCase.verifyEqual(testCase.object.inputUnits,{'si_1';'si_2'},'The array inputUnits is not changed correctly.')
            compare_param = struct;
            compare_param.param1 = [];
            compare_param.param3 = [];
            testCase.verifyEqual(testCase.object.param,compare_param,'The parameter structure is not changed correctly.');
            compare_f = u1 - x1 + u2^2 + p1 + p3^3;
            compare_g = compare_f + 1;
            testCase.verifyEqual(testCase.object.f,compare_f,'The parameter has not been replaced correctly in the equations f.');
            testCase.verifyEqual(testCase.object.g,compare_g,'The parameter has not been replaced correctly in the equations g.');         
            
            % Check if the second add of a parameter as input works correct
            testCase.object.setParamAsInput('param1');
            testCase.verifyEqual(testCase.object.u,[sym('u1');sym('u2');sym('u3')],'The array u is not extended correctly on setting a second parameter as input.');
            testCase.verifyEqual(testCase.object.inputNames,{'input1';'param2';'param1'},'The array inputNames is not changed correctly on setting a second parameter as input.');
            testCase.verifyEqual(testCase.object.inputUnits,{'si_1';'si_2';'si_1'},'The array inputNames is not changed correctly on setting a second parameter as input.');
            compare_param = struct;
            compare_param.param3 = [];
            testCase.verifyEqual(testCase.object.param,compare_param,'The field of the parameters is not set correctly on setting a second parameter as input.');
            compare_f = subs(compare_f,p1,u3);
            compare_g = subs(compare_g,p1,u3);
            testCase.verifyEqual(testCase.object.f,compare_f,'The parameter has not been replaced correctly in the equations f on the second set of a parameter as input.');
            testCase.verifyEqual(testCase.object.g,compare_g,'The parameter has not been replaced correctly in the equations g on the second set of a parameter as input');
        end
        
        % ---------- checks for setParam ----------------------------------
        
        function check_SetParam_Errors(testCase)
            % Check if errors are thrown on an invalid name or value
            testCase.verifyError(@()testCase.object.setParam(7,5),'ODESCA_Object:setParam:parameterNameIsNoString','The method ''setParam'' does not throw a correct error if paramName is not a string.');
            testCase.verifyError(@()testCase.object.setParam('param1','5'),'ODESCA_Object:setParam:valueIsNoScalarNumeric','The method ''setParam'' does not trow a correct error if value is not numeric.');
            
            % Check if an error is thrown if the object does not have
            % parameters
            testCase.object.generateEquations(2,2,2,0);
            testCase.verifyError(@()testCase.object.setParam('param1',5),'ODESCA_Object:setParam:noParametersFound','The method ''setParam'' does not throw a correct error if it does not have any parameters.');
            
            % Check if an error is thrown if the parameter does not exist
            testCase.object.generateEquations(2,2,2,2);
            testCase.verifyError(@()testCase.object.setParam('toast',5),'ODESCA_Object:setParam:parameterDoseNotExist','The method ''setParam'' does not throw a correct error if paramName is not an existing parameter.');
        end
        
        function check_SetParam(testCase)
            % Prepare the object
            testCase.object.generateEquations(2,2,2,4);
            compare_param.param1 = [];
            compare_param.param2 = [];
            compare_param.param3 = [];
            compare_param.param4 = [];
            testCase.assertEqual(testCase.object.param,compare_param,'The param structure is not correct at the start of the test so the test was aborted.');
            
            % Test if the set of parameter works
            testCase.object.setParam('param1', 5);
            testCase.object.setParam('param2', 3.8);
            testCase.object.setParam('param3', -1);
            testCase.object.setParam('param4', 0.0001);
            compare_param.param1 = 5;
            compare_param.param2 = 3.8;
            compare_param.param3 = -1;
            compare_param.param4 = 0.0001;
            testCase.verifyEqual(testCase.object.param, compare_param,'The set of the parameter does not work correctly.');
            
            % Test if the reset of parameters works
            testCase.object.setParam('param1', []);
            testCase.object.setParam('param3', {});
            compare_param.param1 = [];
            compare_param.param3 = [];
            testCase.verifyEqual(testCase.object.param, compare_param,'The reset of the parameter does not work corretly.');

        end
        
        % ---------- checks for setAllParamAsInputs -----------------------
        
        function check_SetAllParamAsInput(testCase)
            % Check if all parameters are set as input
            testCase.object.generateEquations(2,2,2,3);
            testCase.object.setAllParamAsInput();
            testCase.verifyEqual(testCase.object.inputNames, {'input1';'input2';'param1';'param2';'param3'}, 'The set of the inputNames list does not work correctly.');
            testCase.verifyEqual(testCase.object.inputUnits, {'si_1';'si_2';'si_1';'si_2';'si_3'}, 'The set of the inputUnits list does not work correctly.');
            testCase.verifyEqual(testCase.object.param, [],'The set of the parameters with symbolic variables does not work correctly');
        end
        
        % ---------- checks for isValidSymbolic ---------------------------
        
        function check_IsValidSymbolic(testCase)
            % Create symbolic variables for the test
            x1 = sym('x1'); x2 = sym('x2');
            u1 = sym('u1'); u2 = sym('u2');
            p1 = sym('param1'); p2 = sym('param2');
            
            % Check if the method works for full systems
            testCase.object.generateEquations(2,2,2,2);
            testCase.verifyTrue(testCase.object.isValidSymbolic(x1 * p1 + 5 * x2 * u2 + pi /(u1 - p2)), 'The method returns false although the symbolic variables are all part of the object.');
            testCase.verifyTrue(testCase.object.isValidSymbolic(sym('5')+ 1/7),'The method returnes false altough there are no symbolic parameters in the equations');
            testCase.verifyFalse(testCase.object.isValidSymbolic(x1 * p1 + 5 * x2 * sym('eingang') + pi /(u1 - p2)),'The system returns true although there is a symbolic variable wich is not part of the object.');
            testCase.verifyFalse(testCase.object.isValidSymbolic(sym('x3') * p1 + 5 * x2 * sym('eingang') + pi /(u1 - p2)),'The system returns true although there are symbolic variables wich are not part of the object.');
            
            % Check if the method works for systems with one of the three
            % symbolic variable types empty
            testCase.object.generateEquations(0,2,2,2);
            testCase.verifyTrue(testCase.object.isValidSymbolic( p1 + 5 * u2 + pi /(u1 - p2)), 'The method returns false although the symbolic variables are all part of the object.');
            testCase.verifyFalse(testCase.object.isValidSymbolic(x1 * p1 + 5 * x2 * u2 + pi /(u1 - p2)), 'The system returns true although there are symbolic variables wich are not part of the object.');
            testCase.object.generateEquations(2,0,2,2);
            testCase.verifyTrue(testCase.object.isValidSymbolic( x1 * p1 + 5 * x2  + pi /(p2)), 'The method returns false although the symbolic variables are all part of the object.');
            testCase.verifyFalse(testCase.object.isValidSymbolic(x1 * p1 + 5 * x2 * u2 + pi /(u1 - p2)), 'The system returns true although there are symbolic variables wich are not part of the object.');
            testCase.object.generateEquations(2,2,2,0);
            testCase.verifyTrue(testCase.object.isValidSymbolic( x1 + 5 * x2 * u2 + pi /(u1)), 'The method returns false although the symbolic variables are all part of the object.');
            testCase.verifyFalse(testCase.object.isValidSymbolic(x1 * p1 + 5 * x2 * u2 + pi /(u1 - p2)), 'The system returns true although there are symbolic variables wich are not part of the object.');
        end
        
        % ---------- checks for getInfo -----------------------------------
        
        function check_getInfo(testCase)
            % Check if the info structure is created correctly on an empty
            % object
            compare_info.states = {};
            compare_info.inputs = {};
            compare_info.outputs = {};
            compare_info.param = {};
            info = testCase.object.getInfo();
            testCase.verifyEqual(info,compare_info,'The info structure is not correct on an empty object.');
            
            % Check if the info structure is created correctly on a full
            % object
            testCase.object.generateEquations(2,2,2,2);
            compare_info.states  = {'x1', 'state1' , 'si_1'; 'x2', 'state2' , 'si_2'};
            compare_info.inputs  = {'u1', 'input1' , 'si_1'; 'u2', 'input2' , 'si_2'};
            compare_info.outputs = {'y1', 'output1', 'si_1'; 'y2', 'output2', 'si_2'};
            compare_info.param =   {'p1', 'param1' , 'si_1'; 'p2', 'param2' , 'si_2'};
            info = testCase.object.getInfo();
            testCase.verifyEqual(info,compare_info,'The info structure is not correct on a full object.');
        end
        
        % ---------- checks for getParam ----------------------------------
        
        function check_getParam(testCase)
           % Check the method for no parameters
           testCase.object.generateEquations(2,2,2,0);
           [values, names] = testCase.object.getParam();
           testCase.verifyEmpty(values,'The method does not return an empty values array if there are no parameters.');
           testCase.verifyEmpty(names,'The method does not return an empty names array if there are no parameters.');
           
           % Check the method for parameters without values
           testCase.object.generateEquations(2,2,2,2);
           [values, names] = testCase.object.getParam();
           testCase.verifyEqual(values, {[];[]},'The method does not return a correct values array if there are parameters without values.');
           testCase.verifyEqual(names, {'param1';'param2'}, 'The method does not return a correct names array if there are  parameters without values.');
           
           % Check the method for parameter with values
           testCase.object.setParam('param1',5);
           testCase.object.setParam('param2',0.1);
           compareStruct.param1 = 5;
           compareStruct.param2 = 0.1;
           testCase.assertEqual(testCase.object.param,compareStruct,'The method ''setParam()'' does not work correctly so the test was aborted.');
           [values, names] = testCase.object.getParam();
           testCase.verifyEqual(values, {5; 0.1},'The method does not return a correct values array if there are parameters with values.');
           testCase.verifyEqual(names, {'param1';'param2'}, 'The method does not return a correct names array if there are  parameters with values.');       
        end
        
        % ---------- checks for getSymbolicStructure ----------------------
        
        function check_getSymbolicStructure(testCase)
            % Create symbolic variables for comparison
            x1 = sym('x1'); x2 = sym('x2');
            u1 = sym('u1'); u2 = sym('u2');
            p1 = sym('param1'); p2 = sym('param2');
            
            % Check if the structure is created correctly on an empty
            % object
            compare_symStruct.states  = [];
            compare_symStruct.inputs  = [];
            compare_symStruct.outputs = [];
            compare_symStruct.params  = [];
            symStruct = testCase.object.getSymbolicStructure();
            testCase.verifyEqual(symStruct,compare_symStruct,'The symbolic structure is not correct for empty systems.');
            
            % Check if the structre is created correctly on a full object
            testCase.object.generateEquations(2,2,2,2);
            compare_symStruct.states.state1  = x1;
            compare_symStruct.states.state2  = x2;
            compare_symStruct.inputs.input1  = u1;
            compare_symStruct.inputs.input2  = u2;
            compare_symStruct.outputs.output1 = p1 + u1 + 2*u2 - x1 - 2*x2 + p2^2 + 1;
            compare_symStruct.outputs.output2 = p1 + u1 + 2*u2 - x1 - 2*x2 + p2^2 + 2;
            compare_symStruct.params.param1  = p1;
            compare_symStruct.params.param2  = p2;
            symStruct = testCase.object.getSymbolicStructure();
            testCase.verifyEqual(symStruct,compare_symStruct,'The symbolic structure is not correct for full systems.');
        end
        
        % ---------- checks for renameParam -------------------------------
        
        function check_renameParam_Errors(testCase)
            % Check if an error occures if the object does not have
            % parameters
            testCase.verifyError(@()testCase.object.wrapped_renameParam('param1','length'),'ODESCA_Object:renameParam:noParametersInObject','The method does not throw a correct error if the object does not have any parameters.');
            
            % Check if an error occures if the oldName is not a string
            testCase.object.generateEquations(2,2,2,2);
            testCase.verifyError(@()testCase.object.wrapped_renameParam(sym('param1'),'length'),'ODESCA_Object:renameParam:oldNameNotAString','The method does not throw a correct error if the old name is not a string.');
            
            % Check if an error occures if the old parameter does not exist
            % in the system
            testCase.verifyError(@()testCase.object.wrapped_renameParam('param3','length'), 'ODESCA_Object:renameParam:oldNameNotInObject','The method does not throw a correct error if the parameter does not exist.');
            
            % Check if an error is thrown if the new name is not a variable
            % name or longer the 31 characters
            testCase.verifyError(@()testCase.object.wrapped_renameParam('param1','#bullshit?'), 'ODESCA_Object:renameParam:newNameNotValid', 'The method does not throw a correct error if the new name is not a valid MATLAB variable name.');
            
            % Check if an error is thrown if a state, input or parameter
            % exists which already have the new name
            testCase.verifyError(@()testCase.object.wrapped_renameParam('param1','state1'), 'ODESCA_System:renameParam:newNameAlreadyInObject', 'The method does not throw a correct error if an state with the new name already exists.');
            testCase.verifyError(@()testCase.object.wrapped_renameParam('param1','input1'), 'ODESCA_System:renameParam:newNameAlreadyInObject', 'The method does not throw a correct error if an input with the new name already exists.');
            testCase.verifyError(@()testCase.object.wrapped_renameParam('param1','param2'), 'ODESCA_System:renameParam:newNameAlreadyInObject', 'The method does not throw a correct error if a parameter with the new name already exists.');
        end
        
        function check_renameParam(testCase)
            % Create symbolic variables for the test
            x1 = sym('x1'); x2 = sym('x2');
            u1 = sym('u1'); u2 = sym('u2');
            p1 = sym('param1');
            length = sym('length');
            
            % Check if the rename of the parameter works on normal
            % parameters
            testCase.object.generateEquations(2,2,2,2);
            testCase.object.setParam('param2',7);
            testCase.object.wrapped_renameParam('param2','length');
            testCase.verifyEqual(testCase.object.f,[ length^2 + p1 + u1 + 2*u2 - x1; length^2 + p1 + u1 + 2*u2 - x2],'The parameter name was not changed correctly in the equations of f.');
            testCase.verifyEqual(testCase.object.g,[ length^2 + p1 + u1 + 2*u2 - x1 - 2*x2 + 1; length^2 + p1 + u1 + 2*u2 - x1 - 2*x2 + 2;],'The parameter name was not changed correctly in the equations of g.');
            compare_param.param1 = [];
            compare_param.length = 7;
            testCase.verifyEqual(testCase.object.param,compare_param,'The param structure is not changed correctly.');
        end
        
        % ---------- checks for removeSymbolicInput -----------------------
        
        function check_removeSymbolicInput(testCase)
            % Create symbolic variables for the test
            x1 = sym('x1'); x2 = sym('x2');
            u1 = sym('u1'); u2 = sym('u2');  u3 = sym('u3');  u4 = sym('u4'); u5 = sym('u5');
            r1 = sym('REPLACED_1'); r2 = sym('REPLACED_2');
            
            % Check the method if the last input is removed
            testCase.object.generateEquations(2,5,1,0);
            testCase.object.set_f(subs(testCase.object.f,u5,r1));
            testCase.object.set_g(subs(testCase.object.g,u5,r1));
            testCase.object.wrapped_removeSymbolicInput(5);
            testCase.verifyEqual(testCase.object.f,[u1 + 2*u2 + 3*u3 + 4*u4 + 5*r1 - x1; u1 + 2*u2 + 3*u3 + 4*u4 + 5*r1 - x2],'The equations f are not correct after removing the last input.');
            testCase.verifyEqual(testCase.object.g, u1 + 2*u2 + 3*u3 + 4*u4 + 5*r1 - x1 - 2*x2 + 1,'The equations g are not correct after removing the last input.');
            testCase.verifyEqual(testCase.object.u, [u1; u2; u3; u4], 'The input list u is not correct after removing the last input.');
            testCase.verifyEqual(testCase.object.inputNames, {'input1'; 'input2'; 'input3'; 'input4'},'The inputName list is not correct after removing the last input.');
            testCase.verifyEqual(testCase.object.inputUnits, {'si_1'; 'si_2'; 'si_3'; 'si_4'},'The inputUnit list is not correct after removing the last input.');
            
            % Check the method if a input in the middle of the input list
            % is removed
            testCase.object.set_f(subs(testCase.object.f,u2,r2));
            testCase.object.set_g(subs(testCase.object.g,u2,r2));
            testCase.object.wrapped_removeSymbolicInput(2);
            testCase.verifyEqual(testCase.object.f,[u1 + 2*r2 + 3*u2 + 4*u3 + 5*r1 - x1; u1 + 2*r2 + 3*u2 + 4*u3 + 5*r1 - x2],'The equations f are not correct after removing an input in the middle.');
            testCase.verifyEqual(testCase.object.g, u1 + 2*r2 + 3*u2 + 4*u3 + 5*r1 - x1 - 2*x2 + 1,'The equations g are not correct after removing an input in the middle.');
            testCase.verifyEqual(testCase.object.u, [u1; u2; u3;], 'The input list u is not correct after an input in the middle.');
            testCase.verifyEqual(testCase.object.inputNames, {'input1'; 'input3'; 'input4'},'The inputName list is not correct after removing an input in the middle.');
            testCase.verifyEqual(testCase.object.inputUnits, {'si_1'; 'si_3'; 'si_4'},'The inputUnit list is not correct after removing an input in the middle.');
        end
        
        % ---------- checks for show --------------------------------------
        
        function  check_show_Errors(testCase)
            % Create system to call show function with wrong inputs
            testCase.object.generateEquations(3,3,3,3);
            
            testCase.verifyError(@()testCase.object.show('string'),'ODESCA_System:show:wrongInputType','The method does not throw a correct error if the first input is a string.');
            testCase.verifyError(@()testCase.object.show([1 2 3]),'ODESCA_System:show:wrongInputType','The method does not throw a correct error if the first input is vectorized.');
            testCase.verifyError(@()testCase.object.show({1,2,3}),'ODESCA_System:show:wrongInputType','The method does not throw a correct error if the first input is a cell.');
        end
        
        function check_show(testCase)
            
           % Create Object with different number of states, inputs, outputs
           % and parameters. If show-function runs without an error test is
           % passed. It is not checked if the output is correcty generated
           % (Evalc() is used to supress display output in matlab
           % promt.)
           testCase.object.generateEquations(3,3,3,3);
           evalc('testCase.object.show();');
           
           testCase.object.generateEquations(1,1,1,1);
           evalc('testCase.object.show();');
           
           testCase.object.generateEquations(0,3,3,3);
           evalc('testCase.object.show();');
                       
           testCase.object.generateEquations(3,0,3,3);
           evalc('testCase.object.show();');
           
           testCase.object.generateEquations(3,3,0,3);
           evalc('testCase.object.show();');
           
           testCase.object.generateEquations(3,3,3,0);
           evalc('testCase.object.show();');
           
           testCase.object.generateEquations(0,0,1,0);
           evalc('testCase.object.show();');
            
        end
        
        % ---------- checks for reactOnEquationChange----------------------
        
        function check_reactOnEquationChange(testCase)
            % check if the abstract class is there and can be called
            testCase.verifyEqual(testCase.object.wrapped_reactOnEquationsChange(), true, 'The abstract method ''reactOnEquationChange'' can not be called.'); 
        end                                      
        
    end
    
    % Methods used only inside the test
    methods(Access = private)
        
    end
end

