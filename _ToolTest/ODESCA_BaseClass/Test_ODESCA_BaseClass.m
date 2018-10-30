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

classdef Test_ODESCA_BaseClass < matlab.unittest.TestCase
    %ODESCA_Component_Test Class to test ODESCA_BaseClass
    %
    % DESCRIPTION
    %   This class test the class ODESCA_BasceClass for the correct working 
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
        baseClass
    end
    
    % Method to create new ODESCA_Component for every test method
    methods(TestMethodSetup)
        function createBaseClass(testCase)
            testCase.baseClass = Test_Wrapper_ODESCA_BaseClass();
        end
    end
    
    % Method to remove instance of the ODESCA_Component which was tested
    methods(TestMethodTeardown)
        function removeBaseClass(testCase)
            testCase.baseClass = [];
        end
    end
    
    methods(Test)
        % ---------- checks for class definition version ------------------
        function check_classDefinitionVersionSetToActualValue(testCase)
           classDefinitionVersionExpected = 'v1.1';
           testCase.verifyEqual(testCase.baseClass.classDefinitionVersion,classDefinitionVersionExpected,'The version defined in the BaseClass:''testCase.baseClass.classDefinitionVersion'' and defined in the tests:''classDefinitionVersionExpected'' are not the same. Be sure you changed both before creating a new version.');
        end
        
        % ---------- checks classDefinitionVersion cannot be changed ------
        function check_classDefinitionVersionProperties(testCase)
           props = testCase.baseClass.findprop('classDefinitionVersion');
           
           testCase.verifyEqual(props.GetAccess,'public','GetAccess of property:''classDefinitionVersion'' is not set to ''public''.');
           testCase.verifyEqual(props.SetAccess,'none','SetAccess of property:''classDefinitionVersion'' is not set to ''none''.');
           testCase.verifyTrue(props.Constant,'Property: ''classDefinitionVersion'' is not set to ''Constant''.');
           testCase.verifyTrue(props.Hidden,'Property: ''classDefinitionVersion'' is not set to ''Hidden''.');
        end
        
        % ---------- checks version gets its value ------------------------
        function check_versionIsSet(testCase)
          testCase.verifyEqual(testCase.baseClass.classDefinitionVersion,testCase.baseClass.version, 'Property: ''version'' of ODESCA_BaseClass is not correctly set by its constructor. Value should be equal to ''classDefinitionVersion''.');
        end
        
        % ---------- checks properties of version -------------------------
        function check_versionProperties(testCase)
          props = testCase.baseClass.findprop('version');
            
          testCase.verifyEqual(props.GetAccess,'public', '''GetAccess'' of property: ''version'' of ODESCA_BaseClass is not set to ''public''.');
          testCase.verifyEqual(props.SetAccess,'private', '''SetAccess'' of property: ''version'' of ODESCA_BaseClass is not set to ''private''.');
          testCase.verifyTrue(props.Hidden, 'Property: ''version'' of ODESCA_BaseClass is not set to ''hidden''.');
        end
    end
    
    methods(Access = private)
        % Method to create an empty instance of the
        % ODESCA_Component_Wrapper class
        function resetBaseClass(testCase)
            testCase.baseClass = [];
            testCase.baseClass = Test_Wrapper_ODESCA_BaseClass();
        end
    end
    
end