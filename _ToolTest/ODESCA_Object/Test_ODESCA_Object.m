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
        
        % ---------- checks for setParam ----------------------------------
        
        function check_SetParam_Errors(testCase)
            % Check if errors are thrown on an invalid name or value
            testCase.verifyError(@()testCase.object.setParam(7,5),'ODESCA_Object:setParam:parameterNameIsNoString','The method ''setParam'' does not throw a correct error if paramName is not a string.');
            testCase.verifyError(@()testCase.object.setParam('param1','5'),'ODESCA_Object:setParam:valueIsNoScalarNumeric','The method ''setParam'' does not trow a correct error if value is not numeric.');
            
            % Check if an error is thrown if the object does not have
            % parameters
            testCase.object.generateObject(2,2,2,0,0);
            testCase.verifyError(@()testCase.object.setParam('param1',5),'ODESCA_Object:setParam:noParametersFound','The method ''setParam'' does not throw a correct error if it does not have any parameters.');
            
            % Check if an error is thrown if the parameter does not exist
            testCase.object.generateObject(2,2,2,2,0);
            testCase.verifyError(@()testCase.object.setParam('toast',5),'ODESCA_Object:setParam:parameterDoesNotExist','The method ''setParam'' does not throw a correct error if paramName is not an existing parameter.');
        end
        
        function check_SetParam(testCase)
            % Prepare the object
            testCase.object.generateObject(2,2,2,4,0);
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
        
        % ---------- checks for isValidSymbolic ---------------------------
        
        function check_IsValidSymbolic(testCase)
            % Create symbolic variables for the test
            x1 = sym('x1'); x2 = sym('x2');
            u1 = sym('u1'); u2 = sym('u2');
            p1 = sym('param1'); p2 = sym('param2');
            
            % Check if the method works for full systems
            testCase.object.generateObject(2,2,2,2,0);
            testCase.verifyTrue(testCase.object.isValidSymbolic(x1 * p1 + 5 * x2 * u2 + pi /(u1 - p2)), 'The method returns false although the symbolic variables are all part of the object.');
            testCase.verifyTrue(testCase.object.isValidSymbolic(sym('5')+ 1/7),'The method returnes false altough there are no symbolic parameters in the equations');
            testCase.verifyFalse(testCase.object.isValidSymbolic(x1 * p1 + 5 * x2 * sym('eingang') + pi /(u1 - p2)),'The system returns true although there is a symbolic variable wich is not part of the object.');
            testCase.verifyFalse(testCase.object.isValidSymbolic(sym('x3') * p1 + 5 * x2 * sym('eingang') + pi /(u1 - p2)),'The system returns true although there are symbolic variables wich are not part of the object.');
            
            % Check if the method works for systems with one of the three
            % symbolic variable types empty
            testCase.object.generateObject(0,2,2,2,0);
            testCase.verifyTrue(testCase.object.isValidSymbolic( p1 + 5 * u2 + pi /(u1 - p2)), 'The method returns false although the symbolic variables are all part of the object.');
            testCase.verifyFalse(testCase.object.isValidSymbolic(x1 * p1 + 5 * x2 * u2 + pi /(u1 - p2)), 'The system returns true although there are symbolic variables wich are not part of the object.');
            testCase.object.generateObject(2,0,2,2,0);
            testCase.verifyTrue(testCase.object.isValidSymbolic( x1 * p1 + 5 * x2  + pi /(p2)), 'The method returns false although the symbolic variables are all part of the object.');
            testCase.verifyFalse(testCase.object.isValidSymbolic(x1 * p1 + 5 * x2 * u2 + pi /(u1 - p2)), 'The system returns true although there are symbolic variables wich are not part of the object.');
            testCase.object.generateObject(2,2,2,0,0);
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
            testCase.object.generateObject(2,2,2,2,0);
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
           testCase.object.generateObject(2,2,2,0,0);
           [values, names] = testCase.object.getParam();
           testCase.verifyEmpty(values,'The method does not return an empty values array if there are no parameters.');
           testCase.verifyEmpty(names,'The method does not return an empty names array if there are no parameters.');
           
           % Check the method for parameters without values
           testCase.object.generateObject(2,2,2,2,0);
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
                 
        
    end
    
    % Methods used only inside the test
    methods(Access = private)
        
    end
end

