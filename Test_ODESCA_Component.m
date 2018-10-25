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

classdef Test_ODESCA_Component < matlab.unittest.TestCase
    %ODESCA_Component_Test Class to test ODESCA_Component
    %
    % DESCRIPTION
    %   This class test the class ODESCA_Component for the correct working 
    %   of all methods and properties.
    %
    % ODESCA_Component_Test
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
        component
    end
    
    % Method to create new ODESCA_Component for every test method
    methods(TestMethodSetup)
        function createComponent(testCase)
            testCase.component = Test_Wrapper_ODESCA_Component();
        end
    end
    
    % Method to remove instance of the ODESCA_Component which was tested
    methods(TestMethodTeardown)
        function removeComponent(testCase)
            testCase.component = [];
        end
    end
    
    methods(Test)
        
        % ---------- checks for the component itself ----------------------
        
        % Check if the properties can not be set public
        function check_PropertiesSetProhibited(testCase)            
            % Create list of all parameters an the diagnostic displayed if
            % the set access is not prohibited and does not throw an error
            nameErrorList = {...
                'constructionParam',             'The public set access for the propertie ''constructionParam'' is not prohibited.';...
                'FLAG_EquationsCalculated',      'The public set access for the propertie ''FLAG_EquationsCalculated'' is not prohibited.';...
                };
            
            % Check the fields
            for num = 1:size(nameErrorList,1)
                result = 'No Error';
                try
                    testCase.component.(nameErrorList{num,1}) = 1;
                catch err
                    result = err.identifier;
                end
                testCase.verifyEqual(result,'MATLAB:class:SetProhibited',nameErrorList{num,2});
            end
        end
        
        % Check if the particular methods have a private access premission
        function check_MethodAccessProhibited(testCase)
            testCase.verifyError(@()testCase.component.addConstructionParameter({'Param1','Param2'}), 'MATLAB:class:MethodRestricted', 'The method ''addConstructionParameter'' of the class ''ODESCA_Component'' does not have a restricted access.');
            testCase.verifyError(@()testCase.component.initializeBasics({},{},{'out1'},{},{},{},{'si_1'},{}), 'MATLAB:class:MethodRestricted', 'The method ''initializeBasics'' of the class ''ODESCA_Component'' does not have a restricted access.');
            testCase.verifyError(@()testCase.component.prepareCreationOfEquations(), 'MATLAB:class:MethodRestricted', 'The method ''prepareCreationOfEquations'' of the class ''ODESCA_Component'' does not have a restricted access.');
            testCase.verifyError(@()testCase.component.reactOnEquationsChange(), 'MATLAB:class:MethodRestricted', 'The method ''reactOnEquationsChange'' of the class ''ODESCA_Component'' does not have a restricted access.');
        end
        
        % Check if the name is set to the argument given in the constructor
        function check_NameSetInConstructor(testCase)
            testCase.verifyEqual(testCase.component.name,'UnnamedComponent', 'The property ''name'' of class ''ODESCA_Component'' is not set correctly.');
        end
        
        % Check if the properties are initialized correctly
        function check_PropertiesInitializedCorrectly(testCase)
           testCase.verifyEmpty(testCase.component.constructionParam, 'The property ''constructionParam'' is not initialized empty.');
           testCase.verifyFalse(testCase.component.FLAG_EquationsCalculated, 'The property ''FLAG_EquationsCalculated'' is not initialized to false.');
        end
        
        % ---------- checks for addConstructionParameter ------------------
        
        function check_addConstructionParameter_Error(testCase)
           testCase.verifyError(@()testCase.component.wrapped_addConstructionParameter('Test'),'ODESCA_Object:addParameters:inputNotACellArray','The method does not throw a correct error if the input argument ''parameterNames'' is not a cell array.'); 
           testCase.verifyError(@()testCase.component.wrapped_addConstructionParameter([6,5,4]),'ODESCA_Object:addParameters:inputNotACellArray','The method does not throw a correct error if the input argument ''parameterNames'' is not a cell array.');
           testCase.verifyError(@()testCase.component.wrapped_addConstructionParameter({5,7}),'ODESCA_Object:addParameters:parameterNameNotValid','The method does not throw a correct error if on of the cells of the input argument ''parameterNames'' is not a valid MATLAB variable name.');
           testCase.verifyError(@()testCase.component.wrapped_addConstructionParameter({'_test','correct'}),'ODESCA_Object:addParameters:parameterNameNotValid','The method does not throw a correct error if on of the cells of the input argument ''parameterNames'' is not a valid MATLAB variable name.');
            
           testCase.component.wrapped_addConstructionParameter({'construct1','construct2'});
           testCase.assertNotEmpty(testCase.component.constructionParam,'The adding of construction parameter does nothing therefore the test was aborted.');
           testCase.verifyError(@()testCase.component.wrapped_addConstructionParameter({'construct3','construct4'}),'ODESCA_Object:addParameters:constructionParameterAlreadySet','The method does not throw a correct error if it is called after a first add of construction parameters.');
        end
        
        function check_addConstructionParameter(testCase)
           % Test the method without construction parameter
           testCase.component.wrapped_addConstructionParameter({});
           testCase.verifyEqual(testCase.component.constructionParam,[],'The method does not leave the property ''constructionParam'' empty if an empty array is given as argument.');
           
           % Test the method with parameter
           testCase.resetComponent();
           compareStruct.construct1 = [];
           compareStruct.construct2 = [];
           testCase.component.wrapped_addConstructionParameter({'construct1','construct2'});
           testCase.verifyEqual(testCase.component.constructionParam,compareStruct,'The method does not create the structure for the construction parameters correctly.');
        end
        
       
        % ---------- checks for setConstructionParam ----------------------
        
        function check_setConstructionParam_errors(testCase)
            % Check if the needed methods are working
            compareStruct.construct1 = [];
            testCase.component.wrapped_addConstructionParameter({'construct1'});
            testCase.assertEqual(testCase.component.constructionParam,compareStruct, 'The method ''addConstructionParam'' does not work correctly so the test was aborted.');
            testCase.resetComponent();
            
            % Check the errors
            testCase.verifyError(@()testCase.component.setConstructionParam('construct',6),'ODESCA_Component:setParam:noConstructionParametersExist','The method does not throw a correct error if no construction parameter exist.');
            testCase.component.wrapped_addConstructionParameter({'construct1','construct2'})
            testCase.verifyError(@()testCase.component.setConstructionParam(6,5),'ODESCA_Component:setParam:parameterNameIsNoString','The method does not throw a correct error if the input argument ''paramName'' is not a string.');
            testCase.verifyError(@()testCase.component.setConstructionParam(['ABC';'DEF'],5),'ODESCA_Component:setParam:parameterNameIsNoString','The method does not throw a correct error if the input argument ''paramName'' is not a string.');
            testCase.verifyError(@()testCase.component.setConstructionParam('construct1','test'),'ODESCA_Component:setParam:valueIsNoScalarNumeric','The method does not throw a correct error if the input argument ''value'' is not a scalar numeric value.');
            testCase.verifyError(@()testCase.component.setConstructionParam('construct1',[5,6]),'ODESCA_Component:setParam:valueIsNoScalarNumeric','The method does not throw a correct error if the input argument ''value'' is not a scalar numeric value.');
            testCase.verifyError(@()testCase.component.setConstructionParam('pinkfluffyunicorns',5),'ODESCA_Component:setParam:constructionParameterDoesNotExist','The method does not throw a correct error if no parameter with the name in ''paramName'' exists. ');
        end
        
        function check_setConstructionParam(testCase)
            % Check if the needed methods are working
            compareStruct.construct1 = [];
            compareStruct.construct2 = [];
            testCase.component.wrapped_addConstructionParameter({'construct1','construct2'});
            testCase.assertEqual(testCase.component.constructionParam,compareStruct, 'The method ''addConstructionParam'' does not work correctly so the test was aborted.');
            
            % Check the functionality
            compareStruct.construct1 = 5; 
            testCase.component.setConstructionParam('construct1',5);
            testCase.verifyEqual(testCase.component.constructionParam, compareStruct,'The set of construction parameters does not work correctly if there were no set construction parameters before.');
            compareStruct.construct2 = 0.1;
            testCase.verifyFalse(testCase.component.FLAG_EquationsCalculated,'The flag equationsCalculated is not false before all construction parameters were set.');
            testCase.component.setConstructionParam('construct2',0.1);
            testCase.verifyEqual(testCase.component.constructionParam, compareStruct,'The set of construction parameters does not work correctly if there were set construction parameters before.');
            testCase.component.tryCalculateEquations();
            testCase.assertTrue(testCase.component.FLAG_EquationsCalculated,'The flag equationsCalculated was not set to true after the call to tryCalculateEquations. The test was aborted.');
            compareF = [sym('x1') + sym('u1') + sym('param1');sym('x2') + sym('u2') + sym('param2')];
            testCase.assertEqual(testCase.component.f,compareF,'The equations where not set correctly so the test was aborted.');
            
        end
        
        % ---------- checks for checkConstructionParam --------------------
        
        function check_checkConstructionParam(testCase)
            % Check if the needed methods are working
            compareStruct.construct1 = [];
            testCase.component.wrapped_addConstructionParameter({'construct1'});
            testCase.assertEqual(testCase.component.constructionParam, compareStruct, 'The method ''addConstructionParam'' does not work correctly so the test was aborted.'); 
            compareStruct.construct1 = 5;
            testCase.component.setConstructionParam('construct1',5);
            testCase.assertEqual(testCase.component.constructionParam, compareStruct, 'The method ''setConstructionParam'' does not work correctly so the test was aborted.');
            testCase.resetComponent();
            
            % Check if the method works correctly if no construction
            % parameters are set
            testCase.component.wrapped_addConstructionParameter({});
            testCase.verifyTrue(testCase.component.checkConstructionParam(),'The method does not work correctly if no construction parameters are added.');
            
            % Check if the method work correctly if construction parameters
            % are added
            testCase.resetComponent();
            testCase.component.wrapped_addConstructionParameter({'construct1','construct2'});
            testCase.verifyFalse(testCase.component.checkConstructionParam(),'The method does not work correctly with all construction parameters unset.');
            testCase.component.setConstructionParam('construct1',2);
            testCase.verifyFalse(testCase.component.checkConstructionParam(),'The method does not work correctly with set and unset construction parameters.');
            testCase.component.setConstructionParam('construct2',5);
            testCase.verifyTrue(testCase.component.checkConstructionParam(),'The method does not work correctly with all construction parameters set.');
        end
        
        % ---------- checks for tryCalculateEquations ---------------------
        
        function check_tryCalculateEquations(testCase)
            
            % Check if the method works correctly without construction
            % parameters
            testCase.component.wrapped_addConstructionParameter({});
            testCase.assertEmpty(testCase.component.constructionParam, 'The construction parameters are not empty on setting them empty. The test was aborted.');
            testCase.assertEmpty(testCase.component.f, 'The equations are not empty before the call to tryCalcluateEquations. The test was aborted.');
            testCase.verifyTrue(testCase.component.tryCalculateEquations(),'The method does not return true if there are no construction parameters.');
            testCase.verifyEqual(testCase.component.f,[sym('x1') + sym('u1') + sym('param1');sym('x2') + sym('u2') + sym('param2')],'The equations where not set correctly if no construction parameters exist.');
            
            % Check if the method works correctly
            testCase.resetComponent();
            compareStruct.construct1 = [];
            testCase.component.wrapped_addConstructionParameter({'construct1'});
            testCase.assertEqual(testCase.component.constructionParam,compareStruct, 'The method ''addConstructionParam'' does not work correctly so the test was aborted.');
            testCase.assertEmpty(testCase.component.f, 'The equations are not empty before the call to tryCalcluateEquations. The test was aborted.');
            warning('off','all')
            testCase.verifyFalse(testCase.component.tryCalculateEquations(),'The method does not return false if there are unset construction parameters.');
            warning('on','all')
            testCase.verifyEmpty(testCase.component.f, 'The equations were changed in tryCalculateEquations even though there are unset construction parameters.');
            testCase.verifyWarning(@()testCase.component.tryCalculateEquations(),'ODESCA_Component:tryCalculateEquations:calculationNotPossible','The method does not throw a correct warning if there are unset construction parameters.');
            testCase.component.setConstructionParam('construct1',5);
            compareStruct.construct1 = 5;
            testCase.assertEqual(testCase.component.constructionParam, compareStruct, 'The method ''setConstructionParam'' does not work correctly so the test was aborted.');
            testCase.verifyTrue(testCase.component.tryCalculateEquations(),'The method does not return true if all construction parameters are set.');
            testCase.verifyEqual(testCase.component.f,[sym('x1') + sym('u1') + sym('param1');sym('x2') + sym('u2') + sym('param2')],'The equations where not set correctly if all construction parameters are set.');
        end
        
        % ---------- checks for initializeBasics --------------------------
        
        function check_initializeBasics_errors(testCase)
            % Order of input arguments: initializeBasics( stateNames, inputNames, outputNames, paramNames, stateUnits, inputUnits, outputUnits, paramUnits)
            
            % Tests for stateNames
            testCase.verifyError(@()testCase.component.wrapped_initializeBasics([1,2],{'u1','u2'},{'y1','y2'},{'p1','p2'},{'1','2'},{'3','4'},{'5','6'},{'7','8'}),'ODESCA_Component:initializeBasics:stateNamesNotACellArray','The method does not throw a correct error if ''stateNames'' is not a cell array.');
            testCase.verifyError(@()testCase.component.wrapped_initializeBasics({'s1','s2'},{'u1','u2'},{'y1','y2'},{'p1','p2'},{'1','2','2a'},{'3','4'},{'5','6'},{'7','8'}),'ODESCA_Component:initializeBasics:numberStateNamesUnitsDifferent','The method does not throw a correct error if ''stateNames'' and ''stateUnits'' have different numbers of elements.');
            testCase.verifyError(@()testCase.component.wrapped_initializeBasics({'#s1','s2'},{'u1','u2'},{'y1','y2'},{'p1','p2'},{'1','2'},{'3','4'},{'5','6'},{'7','8'}),'ODESCA_Component:initializeBasics:stateNameInvaldi','The method does not throw a correct error if on of the state names is not a correct MATLAB variable name.');
            testCase.verifyError(@()testCase.component.wrapped_initializeBasics({'abcdefghijabcdefghijabcdefghij123','s2'},{'u1','u2'},{'y1','y2'},{'p1','p2'},{'1','2'},{'3','4'},{'5','6'},{'7','8'}),'ODESCA_Component:initializeBasics:stateNameTooLong','The method does not throw a correct error if one of the state names is longer than 31 characters.');
            testCase.verifyError(@()testCase.component.wrapped_initializeBasics({'s1','s2'},{'u1','u2'},{'y1','y2'},{'p1','p2'},{1,'2'},{'3','4'},{'5','6'},{'7','8'}),'ODESCA_Component:initializeBasics:stateUnitNotAString','The method does not throw a correct error if one of the state units is not a string.');
            
            % Tests for inputNames
            testCase.verifyError(@()testCase.component.wrapped_initializeBasics({'s1','s2'},[1,2],{'y1','y2'},{'p1','p2'},{'1','2'},{'3','4'},{'5','6'},{'7','8'}),'ODESCA_Component:initializeBasics:inputNamesNotACellArray','The method does not throw a correct error if ''inputNames'' is not a cell array.');
            testCase.verifyError(@()testCase.component.wrapped_initializeBasics({'s1','s2'},{'u1','u2','u3'},{'y1','y2'},{'p1','p2'},{'1','2'},{'3','4'},{'5','6'},{'7','8'}),'ODESCA_Component:initializeBasics:numberStateNamesUnitsDifferent','The method does not throw a correct error if ''inputNames'' and ''inputUnits'' have different numbers of elements.');
            testCase.verifyError(@()testCase.component.wrapped_initializeBasics({'s1','s2'},{'#u1','u2'},{'y1','y2'},{'p1','p2'},{'1','2'},{'3','4'},{'5','6'},{'7','8'}),'ODESCA_Component:initializeBasics:inputNameInvalid','The method does not throw a correct error if one of the input names is not a correct MATLAB variable name.');
            testCase.verifyError(@()testCase.component.wrapped_initializeBasics({'s1','s2'},{'abcdefghijabcdefghijabcdefghij123','u2'},{'y1','y2'},{'p1','p2'},{'1','2'},{'3','4'},{'5','6'},{'7','8'}),'ODESCA_Component:initializeBasics:inputNameTooLong','The method does not throw a correct error if one of the input names is longer than 31 characters.');
            testCase.verifyError(@()testCase.component.wrapped_initializeBasics({'s1','s2'},{'u1','u2'},{'y1','y2'},{'p1','p2'},{'1','2'},{3,'4'},{'5','6'},{'7','8'}),'ODESCA_Component:initializeBasics:inputUnitNotAString','The method does not throw a correct error if one of the input units is not a string.');
            
            % Tests for outputNames
            testCase.verifyError(@()testCase.component.wrapped_initializeBasics({'s1','s2'},{'u1','u2'},{},{'p1','p2'},{'1','2'},{'3','4'},{'5','6'},{'7','8'}),'ODESCA_Component:initializeBasics:outputNamesEmpty','The method does not throw a correct error if ''outputNames'' is empty.');
            testCase.verifyError(@()testCase.component.wrapped_initializeBasics({'s1','s2'},{'u1','u2'},[1,2],{'p1','p2'},{'1','2'},{'3','4'},{'5','6'},{'7','8'}),'ODESCA_Component:initializeBasics:outputNamesNotACellArray','The method does not throw a correct error if ''outputNames'' is not a cell array.');
            testCase.verifyError(@()testCase.component.wrapped_initializeBasics({'s1','s2'},{'u1','u2'},{'y1','y2'},{'p1','p2'},{'1','2'},{'3','4'},{'5','6','6a'},{'7','8'}),'ODESCA_Component:initializeBasics:numberStateNamesUnitsDifferent','The method does not throw a correct error if ''outputNames'' and ''outputUnits'' have different numbers of elements.');
            testCase.verifyError(@()testCase.component.wrapped_initializeBasics({'s1','s2'},{'u1','u2'},{'#y1','y2'},{'p1','p2'},{'1','2'},{'3','4'},{'5','6'},{'7','8'}),'ODESCA_Component:initializeBasics:outputNameInvalid','The method does not throw a correct error if one of the output names is not a correct MATLAB variable name.');
            testCase.verifyError(@()testCase.component.wrapped_initializeBasics({'s1','s2'},{'u1','u2'},{'abcdefghijabcdefghijabcdefghij123','y2'},{'p1','p2'},{'1','2'},{'3','4'},{'5','6'},{'7','8'}),'ODESCA_Component:initializeBasics:outputNameTooLong','The method does not throw a correct error if one of the output names is longer than 31 characters.');
            testCase.verifyError(@()testCase.component.wrapped_initializeBasics({'s1','s2'},{'u1','u2'},{'y1','y2'},{'p1','p2'},{'1','2'},{'3','4'},{5,'6'},{'7','8'}),'ODESCA_Component:initializeBasics:outputUnitNotAString','The method does not throw a correct error if one of the output units is not a string.');
            
            % Tests for paramNames
            testCase.verifyError(@()testCase.component.wrapped_initializeBasics({'s1','s2'},{'u1','u2'},{'y1','y2'},[1,2],{'1','2'},{'3','4'},{'5','6'},{'7','8'}),'ODESCA_Component:initializeBasics:paramNamesNotACellArray','The method does not throw a correct error if ''paramNames'' is not a cell array.');
            testCase.verifyError(@()testCase.component.wrapped_initializeBasics({'s1','s2'},{'u1','u2'},{'y1','y2'},{'p1','p2','p3'},{'1','2'},{'3','4'},{'5','6'},{'7','8'}),'ODESCA_Component:initializeBasics:numberStateNamesUnitsDifferent','The method does not throw a correct error if ''paramNames'' and ''paramUnits'' have different numbers of elements.');
            testCase.verifyError(@()testCase.component.wrapped_initializeBasics({'s1','s2'},{'u1','u2'},{'y1','y2'},{'#p1','p2'},{'1','2'},{'3','4'},{'5','6'},{'7','8'}),'ODESCA_Component:initializeBasics:parameterNameNotValid','The method does not throw a correct error if one of the parameter names is not a correct MATLAB variable name.');
            testCase.verifyError(@()testCase.component.wrapped_initializeBasics({'s1','s2'},{'u1','u2'},{'y1','y2'},{'abcdefghijabcdefghijabcdefghij123','p2'},{'1','2'},{'3','4'},{'5','6'},{'7','8'}),'ODESCA_Component:initializeBasics:parameterNameTooLong','The method does not throw a correct error if one of the parameter names is longer than 31 characters.');
            testCase.verifyError(@()testCase.component.wrapped_initializeBasics({'s1','s2'},{'u1','u2'},{'y1','y2'},{'p1','p2'},{'1','2'},{'3','4'},{'5','6'},{7,'8'}),'ODESCA_Component:initializeBasics:paramUnitNotAString','The method does not throw a correct error if one of the parameter units is not a string.');
           
            % Tests for name conflicts
            testCase.verifyError(@()testCase.component.wrapped_initializeBasics({'s1','s2'},{'s1','u2'},{'y1','y2'},{'p1','p2'},{'1','2'},{'3','4'},{'5','6'},{'7','8'}),'ODESCA_Component:initializeBasics:NameConflicts','The method does not throw a correct error if there are name conflicts between the state and input names.');  
            testCase.verifyError(@()testCase.component.wrapped_initializeBasics({'s1','s2'},{'u1','u2'},{'y1','y2'},{'p1','s2'},{'1','2'},{'3','4'},{'5','6'},{'7','8'}),'ODESCA_Component:initializeBasics:NameConflicts','The method does not throw a correct error if there are name conflicts between the state and parameter names.');     
            testCase.verifyError(@()testCase.component.wrapped_initializeBasics({'s1','s2'},{'u1','u2'},{'y1','y2'},{'u1','p2'},{'1','2'},{'3','4'},{'5','6'},{'7','8'}),'ODESCA_Component:initializeBasics:NameConflicts','The method does not throw a correct error if there are name conflicts between the input and parameter names.');     
            testCase.verifyError(@()testCase.component.wrapped_initializeBasics({'s1','s2'},{'u1','s2'},{'y1','y2'},{'p1','s2'},{'1','2'},{'3','4'},{'5','6'},{'7','8'}),'ODESCA_Component:initializeBasics:NameConflicts','The method does not throw a correct error if there are name conflicts between the state, input and parameter names.');      
        end
        
        function check_initializeBasics(testCase)
            % Create variables for the checks
            x = [sym('x1');sym('x2')];
            u = [sym('u1');sym('u2')];
            p = [sym('p1');sym('p2')];
            
            stateNames  = {'s1';'s2'};
            inputNames  = {'u1';'u2'};
            outputNames = {'y1';'y2'};
            param.p1 = []; param.p2 = [];
            
            stateUnits  = {'1';'2'};
            inputUnits  = {'3';'4'};
            outputUnits = {'5';'6'};
            paramUnits  = {'7';'8'};
            
            % Test method for all inputs argument filled
            testCase.component.wrapped_initializeBasics({'s1','s2'},{'u1','u2'},{'y1','y2'},{'p1','p2'},{'1','2'},{'3','4'},{'5','6'},{'7','8'});
            testCase.verifyEqual(testCase.component.x, x, 'The method does not set the array for the symbolic state variables correctly.');
            testCase.verifyEqual(testCase.component.u, u, 'The method does not set the array for the symbolic input variables correctly.');
            testCase.verifyEqual(testCase.component.p, p, 'The method does not set the array for the symbolic parameter variables correctly.');
            testCase.verifyEqual(testCase.component.stateNames, stateNames, 'The method does not set the array for the state names correctly.');
            testCase.verifyEqual(testCase.component.inputNames, inputNames, 'The method does not set the array for the input names correctly.');
            testCase.verifyEqual(testCase.component.outputNames, outputNames, 'The method does not set the array for the output names correctly.');
            testCase.verifyEqual(testCase.component.param, param, 'The method does not set the array for the parameter names correctly.');
            testCase.verifyEqual(testCase.component.stateUnits, stateUnits, 'The method does not set the array for the state units correctly.');
            testCase.verifyEqual(testCase.component.inputUnits, inputUnits, 'The method does not set the array for the input units correctly.');
            testCase.verifyEqual(testCase.component.outputUnits, outputUnits, 'The method does not set the array for the output units correctly.');
            testCase.verifyEqual(testCase.component.paramUnits, paramUnits, 'The method does not set the array for the parameter units correctly.');
            
            % Test the method for all input arguments not needed empty
            testCase.resetComponent();
            testCase.component.wrapped_initializeBasics({},{},{'y1','y2'},{},{},{},{'5','6'},{});
            testCase.verifyEmpty(testCase.component.x, 'The method does not left the array for the symbolic state variables empty.');
            testCase.verifyEmpty(testCase.component.u, 'The method does not left the array for the symbolic input variables empty.');
            testCase.verifyEmpty(testCase.component.p, 'The method does not left the array for the symbolic parameter variables empty.');
            testCase.verifyEmpty(testCase.component.stateNames, 'The method does not left the array for the state names empty.');
            testCase.verifyEmpty(testCase.component.inputNames, 'The method does not left the array for the input names empty.');
            testCase.verifyEmpty(testCase.component.param, 'The method does not left the array for the parameter names empty.');
            testCase.verifyEmpty(testCase.component.stateUnits, 'The method does not left the array for the state units empty.');
            testCase.verifyEmpty(testCase.component.inputUnits, 'The method does not left the array for the input units empty.');
            testCase.verifyEmpty(testCase.component.paramUnits, 'The method does not left the array for the parameter units empty.');
        end
        
        % ---------- checks for prepareCreationOfEquations ----------------
        function check_prepareCreationOfEquations(testCase)
            % Check if the needed methods are working
            testCase.component.wrapped_initializeBasics({'state1','state2'},{'input1','input2'},{'output1','output2'},{'param1','param2'},{'1','2'},{'3','4'},{'5','6'},{'7','8'});
            testCase.assertEqual(testCase.component.x, [sym('x1');sym('x2')], 'The method ''initializeBasics'' does not work correctly so the test was aborted.');
            testCase.assertEqual(testCase.component.stateNames, {'state1';'state2'}, 'The method ''initializeBasics'' does not work correctly so the test was aborted.');
            
            % Create names and symbolic variable arrays for the variables
            % which should be known after the call of
            % prepareCreationOfEquations
            varNames = {'state1','state2','input1','input2','param1','param2'};
            varSym   = [sym('x1'),sym('x2'),sym('u1'),sym('u2'),sym('param1'),sym('param2')];
            
            % Check the existance with the help of the wrapper mathod
            % test_prepareCreationOfEquations
            [exists, correctSym] = testCase.component.test_prepareCreationOfEquations(varNames,varSym);
            testCase.verifyEqual(exists(1:2),[1,1],'The variables for the states are not known in the workspace after the method was called.');
            testCase.verifyEqual(exists(3:4),[1,1],'The variables for the inputs are not known in the workspace after the method was called.');
            testCase.verifyEqual(exists(5:6),[1,1],'The variables for the parameters are not known in the workspace after the method was called.');
            testCase.verifyEqual(correctSym(1:2),[1,1],'At least one of the variables for the states created by the method does not contain the right symbolic variable.');
            testCase.verifyEqual(correctSym(3:4),[1,1],'At least one of the variables for the inputs created by the method does not contain the right symbolic variable.');
            testCase.verifyEqual(correctSym(5:6),[1,1],'At least one of the variables for the outputs created by the method does not contain the right symbolic variable.');
        end
        
        % ---------- checks for checkEquationsCorrect ---------------------
        
        function check_checkEquationsCorrect(testCase)
            % Check if the needed methods are working
            testCase.component.wrapped_initializeBasics({'state1','state2'},{'input1','input2'},{'output1','output2'},{'param1','param2'},{'1','2'},{'3','4'},{'5','6'},{'7','8'});
            testCase.assertEqual(testCase.component.x, [sym('x1');sym('x2')], 'The method ''initializeBasics'' does not work correctly so the test was aborted.');
            testCase.assertEqual(testCase.component.stateNames, {'state1';'state2'}, 'The method ''initializeBasics'' does not work correctly so the test was aborted.');
            
            % Create symbolic variables
            syms x1 x2 u1 u2 param1 param2;
            syms bullshit;
            
            
            % Test if the method returns true if the equations are correct
            testCase.component.set_f([x1 + param1 + u1 + 1;x2 + param2 + u2 + 2]);
            testCase.component.set_g([x1 * param1 * u1; x2 * param2 * u2]);
            testCase.verifyTrue(testCase.component.checkEquationsCorrect(),'The method does not return true if the filled equations are correct.');
            
            testCase.resetComponent();
            testCase.component.wrapped_initializeBasics({},{'input1','input2'},{'output1','output2'},{'param1','param2'},{},{'3','4'},{'5','6'},{'7','8'});
            testCase.component.set_f([]);
            testCase.component.set_g([u1 * param1; u2 * param2]);
            testCase.verifyTrue(testCase.component.checkEquationsCorrect(),'The method does not return true if state equations are empty and the input equations are correct.');
            
            % Test if the method returns false if the equations are not
            % correct
            warning('off','all');
            
            testCase.resetComponent();
            testCase.component.wrapped_initializeBasics({'state1','state2'},{'input1','input2'},{'output1','output2'},{'param1','param2'},{'1','2'},{'3','4'},{'5','6'},{'7','8'});
            testCase.component.set_f([x1 + param1 + u1 + 1;x2 + param2 + u2 + 2 + bullshit]);
            testCase.component.set_g([x1 * param1 * u1; x2 * param2 * u2]);
            testCase.verifyFalse(testCase.component.checkEquationsCorrect(),'The method does not return false if there are wrong symbolic variables in the equations of the states.');
            
            testCase.component.set_f([x1 + param1 + u1 + 1;x2 + param2 + u2 + 2 ]);
            testCase.component.set_g([x1 * param1 * u1; x2 * param2 * u2 + bullshit]);
            testCase.verifyFalse(testCase.component.checkEquationsCorrect(),'The method does not return false if there are wrong symbolic variables in the equations of the outputs.');
            
            testCase.component.set_f([x1 + param1 + u1 + 1;x2 + param2 + u2 + 2; x1 + x2]);
            testCase.component.set_g([x1 * param1 * u1; x2 * param2 * u2]);
            testCase.verifyFalse(testCase.component.checkEquationsCorrect(),'The method does not return false if there are too much state equations.');
            
            testCase.component.set_f([x1 + param1 + u1 + 1;x2 + param2 + u2 + 2]);
            testCase.component.set_g([x1 * param1 * u1; x2 * param2 * u2; x1 + x2]);
            testCase.verifyFalse(testCase.component.checkEquationsCorrect(),'The method does not return false if there are too much output equations.');
            
            testCase.component.set_f({'Test';'Test2'});
            testCase.component.set_g([x1 * param1 * u1; x2 * param2 * u2;]);
            testCase.verifyFalse(testCase.component.checkEquationsCorrect(),'The method does not return false if the equations for the states are not symbolic.');
            
            testCase.component.set_f([x1 + param1 + u1 + 1;x2 + param2 + u2 + 2]);
            testCase.component.set_g({'Test';'Test2'});
            testCase.verifyFalse(testCase.component.checkEquationsCorrect(),'The method does not return false if the equations for the outputs are not symbolic.');
        
            warning('on','all');
        end
        
    end
    
    methods(Access = private)
        % Method to create an empty instance of the
        % ODESCA_Component_Wrapper class
        function resetComponent(testCase)
            testCase.component = [];
            testCase.component = Test_Wrapper_ODESCA_Component();
        end
        
    end
    
end