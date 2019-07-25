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

classdef Test_ODESCA_System < matlab.unittest.TestCase
    %ODESCA_System_Test Class to test ODESCA_System
    %
    % DESCRIPTION
    %   This class test the class ODESCA_System for the correct working of
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
        system
    end
    
    % Method to create new ODESCA_System for every test method
    methods(TestMethodSetup)
        function createSystem(testCase)
            testCase.system = ODESCA_System();
        end
    end
    
    % Method to remove instance of the ODESCA_System which was tested
    methods(TestMethodTeardown)
        function removeObject(testCase)
            testCase.system = [];
        end
    end
    
    %######################################################################
    
    methods(Test)
        % ---------- checks for the system itself -------------------------
        
        % Check if the properties can not be set public
        function check_PropertiesSetProhibited(testCase)
            % Create list of all parameters an the diagnostic displayed if
            % the set access is not prohibited and does not throw an error
            nameList = {...
                'defaultSampleTime';
                'components';
                'steadyStates';
                };
            
            % Check the fields
            for num = 1:size(nameList,1)
                result = 'No Error';
                name = nameList{num};
                try
                    testCase.system.(name) = 1;
                catch err
                    result = err.identifier;
                end
                testCase.verifyEqual(result,'MATLAB:class:SetProhibited',['The public set access for the propertie ''',name,''' is not prohibited.']);
            end
        end
        
        % check if the methods have the correct access
        function check_MethodAccessProhibited(testCase)
            testCase.verifyError(@()testCase.system.reactOnEquationsChange(), 'MATLAB:class:MethodRestricted', 'The method ''reactOnEquationsChange'' of the class ''ODESCA_System'' does not have a restricted access.');
        end
        
        % Check if the properties are initialized correctly
        function check_PropertiesInitializedCorrectly(testCase)
            testCase.verifyNotEmpty(testCase.system.name,'The property ''name'' of the system is empty with the default constructor.');
            testCase.verifyEqual(testCase.system.defaultSampleTime, 1, 'The property ''defaultSampleTime'' is not initialized to 1.');
            testCase.verifyEmpty(testCase.system.components, 'The property ''components'' is not initialized empty.');
            testCase.verifyEmpty(testCase.system.steadyStates, 'The property ''steadyStates'' is not initialized empty.');
        end
        
        % ---------- checks for setDefaultSampleTime ----------------------
        
        function check_setDefaultSampleTime(testCase)
            % Check the errors
            testCase.verifyError(@()testCase.system.setDefaultSampleTime('Hallo Welt'),'ODESCA_System:setDefaultSampleTime:invalidSampleTime', 'The method does not throw a correct error if the input argument is not numeric.');
            testCase.verifyError(@()testCase.system.setDefaultSampleTime([5,7]),'ODESCA_System:setDefaultSampleTime:invalidSampleTime', 'The method does not throw a correct error if the input argument is not scalar.');
            testCase.verifyError(@()testCase.system.setDefaultSampleTime(0),'ODESCA_System:setDefaultSampleTime:invalidSampleTime', 'The method does not throw a correct error if the input argument is equal to zero.');
            testCase.verifyError(@()testCase.system.setDefaultSampleTime(-1),'ODESCA_System:setDefaultSampleTime:invalidSampleTime', 'The method does not throw a correct error if the input argument is negativ.');
            
            % Check working
            testCase.system.setDefaultSampleTime(0.15);
            testCase.verifyEqual(testCase.system.defaultSampleTime,0.15,'The method does not set the default sample time correctly.');
        end
        
        % ---------- checks for addComponent ------------------------------
        
        function check_addComponent_error(testCase)
            testCase.verifyError(@()testCase.system.addComponent(5),'ODESCA_System:addComponent:tryingToAddNoneComponent','The method does not throw a correct error if the argument is not a ODESCA_Component.');
            sys = ODESCA_System();
            testCase.verifyError(@()testCase.system.addComponent(sys),'ODESCA_System:addComponent:tryingToAddNoneComponent','The method does not throw a correct error if the argument is not a ODESCA_Component.');
            
            c1 = Test_ODESCA_System_CompS1I1O1P1CP0('Comp1');
            testCase.system.addComponent(c1);
            testCase.assertEqual(testCase.system.components,{'Comp1'},'The adding of a component does not work correctly so the error test was aborted.');
            testCase.verifyError(@()testCase.system.addComponent(c1),'ODESCA_System:addComponent:componentNameConflict','The method does not throw a correct error if there is a component with the same name as the to add component already.');
            
            testCase.resetSystem();
            c2 = Test_ODESCA_System_CompS1I1O1P1CP1('Comp2');
            testCase.verifyError(@()testCase.system.addComponent(c2),'ODESCA_System:addComponent:canNotCalculateEquations','The method does not throw a correct error if the component to be added has unset construction parameters.');
            
            testCase.resetSystem();
            c3 = Test_ODESCA_System_ComponentBroken('CompBroke');
            warning('off','all'); % a warning might be confusing inside a test, yet it is wanted here
            c3.setConstructionParam('c',2);
            warning('on','all');
            testCase.verifyError(@()testCase.system.addComponent(c3),'ODESCA_System:addComponent:canNotCalculateEquations','The method does not throw a correct error if the component to be added is broken.');
        end
        
        
        function check_addComponent_S0I0O1P0CP0(testCase)
            % check if component without states inputs and parameters can
            % be added to an empty system.
            
            % expected values
            x = [];
            u = [];
            f = [];
            g = sym('1');
            param = [];
            
            c1 = Test_ODESCA_System_CompS0I0O1P0CP0('Comp1');
            
            testCase.system.addComponent(c1);
            testCase.verifyEqual(testCase.system.components,{'Comp1'},'The component name was not added to the system correctly.');
            testCase.verifyEqual(testCase.system.stateNames,{},'The components stateNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.inputNames,{},'The components inputNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.outputNames,{'Comp1_Output'},'The components outputNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.stateUnits,{},'The components stateUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.inputUnits,{},'The components inputUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.outputUnits,{'o'},'The components outputUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.paramUnits,{},'The components paramUnits were not added to the system correctly.');
            
            testCase.verifyEqual(testCase.system.x,x,'The components states were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.u,u,'The components inputs were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.f,f,'The components state equations were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.g,g,'The components output equations were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.param,param,'The parameter structure of the system was not extanded correcty.');
            
            % add a second component without states inputs and parameters
            % to ensure that adding a second component will work correctly
            
            % expected values
            x = [];
            u = [];
            f = [];
            g = [sym('1'); sym('1')];
            param = [];
            
            
            c2 = Test_ODESCA_System_CompS0I0O1P0CP0('Comp2');
            testCase.system.addComponent(c2);
            
            testCase.verifyEqual(testCase.system.components,{'Comp1';'Comp2'},'The component name was not added to the system correctly.');
            testCase.verifyEqual(testCase.system.stateNames,{},'The components stateNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.inputNames,{},'The components inputNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.outputNames,{'Comp1_Output';'Comp2_Output'},'The components outputNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.stateUnits,{},'The components stateUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.inputUnits,{},'The components inputUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.outputUnits,{'o';'o'},'The components outputUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.paramUnits,{},'The components paramUnits were not added to the system correctly.');
            
            testCase.verifyEqual(testCase.system.x,x,'The components states were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.u,u,'The components inputs were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.f,f,'The components state equations were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.g,g,'The components output equations were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.param,param,'The parameter structure of the system was not extended correcty.');
                
            % add a third component. Now with 1 state, 1 inputs and a
            % parameter
            
            % expected values
            syms x1;
            syms u1;
            syms Comp3_Parameter;
            f3 = - x1 + u1 * Comp3_Parameter;
            g3 = x1 + u1 + Comp3_Parameter;

            x = [x1];
            u = [u1];
            f = [f3];
            g = [sym('1'); sym('1');g3];
            param = struct;
            param.Comp3_Parameter = [];
            
            c3 = Test_ODESCA_System_CompS1I1O1P1CP0('Comp3');
            testCase.system.addComponent(c3);
            
            testCase.verifyEqual(testCase.system.components,{'Comp1';'Comp2';'Comp3'},'The component name was not added to the system correctly.');
            testCase.verifyEqual(testCase.system.stateNames,{'Comp3_State'},'The components stateNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.inputNames,{'Comp3_Input'},'The components inputNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.outputNames,{'Comp1_Output';'Comp2_Output';'Comp3_Output'},'The components outputNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.stateUnits,{'s'},'The components stateUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.inputUnits,{'i'},'The components inputUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.outputUnits,{'o';'o';'o'},'The components outputUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.paramUnits,{'p'},'The components paramUnits were not added to the system correctly.');
            
            testCase.verifyEqual(testCase.system.x,x,'The components states were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.u,u,'The components inputs were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.f,f,'The components state equations were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.g,g,'The components output equations were not added to the system correctly.');

            testCase.verifyEqual(testCase.system.param,param,'The parameter structure of the system was not extanded correcty.');
            testCase.verifyEqual(testCase.system.p,Comp3_Parameter,'The p array of the system was not extanded correcty.');
            
            % add a fourth component without states inputs and parameters
            % again
            
            % expected values
                        syms x1;
            syms u1;
            syms Comp3_Parameter;
            f3 = - x1 + u1 * Comp3_Parameter;
            g3 = x1 + u1 + Comp3_Parameter;

            x = [x1];
            u = [u1];
            f = [f3];
            g = [sym('1'); sym('1');g3;sym('1')];
            param = struct;
            param.Comp3_Parameter = [];
            
            c4 = Test_ODESCA_System_CompS0I0O1P0CP0('Comp4');
            testCase.system.addComponent(c4);
            testCase.verifyEqual(testCase.system.components,{'Comp1';'Comp2';'Comp3';'Comp4'},'The component name was not added to the system correctly.');
            testCase.verifyEqual(testCase.system.stateNames,{'Comp3_State'},'The components stateNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.inputNames,{'Comp3_Input'},'The components inputNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.outputNames,{'Comp1_Output';'Comp2_Output';'Comp3_Output';'Comp4_Output'},'The components outputNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.stateUnits,{'s'},'The components stateUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.inputUnits,{'i'},'The components inputUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.outputUnits,{'o';'o';'o';'o'},'The components outputUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.paramUnits,{'p'},'The components paramUnits were not added to the system correctly.');
            
            testCase.verifyEqual(testCase.system.x,x,'The components states were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.u,u,'The components inputs were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.f,f,'The components state equations were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.g,g,'The components output equations were not added to the system correctly.');

            testCase.verifyEqual(testCase.system.param,param,'The parameter structure of the system was not extanded correcty.');
            testCase.verifyEqual(testCase.system.p,Comp3_Parameter,'The p array of the system was not extanded correcty.');
            
        end
        
        
        function check_addComponent_S1I1O1P1CP0(testCase)
            % Create symbolic variables
            syms x1 x2;
            syms u1 u2;
            syms Comp1_Parameter Comp2_Parameter;
            f1 = - x1 + u1 * Comp1_Parameter;
            f2 = - x2 + u2 * Comp2_Parameter;
            g1 = x1 + u1 + Comp1_Parameter;
            g2 = x2 + u2 + Comp2_Parameter;
            
            % Check the add method for the first component to be added
            c1 = Test_ODESCA_System_CompS1I1O1P1CP0('Comp1');
            testCase.system.addComponent(c1);
            testCase.verifyEqual(testCase.system.components,{'Comp1'},'The component name was not added to the system correctly.');
            testCase.verifyEqual(testCase.system.stateNames,{'Comp1_State'},'The components stateNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.inputNames,{'Comp1_Input'},'The components inputNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.outputNames,{'Comp1_Output'},'The components outputNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.stateUnits,{'s'},'The components stateUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.inputUnits,{'i'},'The components inputUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.outputUnits,{'o'},'The components outputUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.paramUnits,{'p'},'The components paramUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.x,sym('x1'),'The components states were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.u,sym('u1'),'The components inputs were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.f,f1,'The components state equations were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.g,g1,'The components output equations were not added to the system correctly.');
            param = struct;
            param.Comp1_Parameter = [];
            testCase.verifyEqual(testCase.system.param,param,'The parameter structure of the system was not extanded correcty.');
            testCase.verifyEqual(testCase.system.p,Comp1_Parameter,'The p array of the system was not extanded correcty.');
            
            % Check if the method works correctly if there is a component
            % in the system already
            c2 = Test_ODESCA_System_CompS1I1O1P1CP0('Comp2');
            testCase.system.addComponent(c2);
            testCase.verifyEqual(testCase.system.components,{'Comp1';'Comp2'},'The component name was not added to the system correctly.');
            testCase.verifyEqual(testCase.system.stateNames,{'Comp1_State';'Comp2_State'},'The components stateNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.inputNames,{'Comp1_Input';'Comp2_Input'},'The components inputNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.outputNames,{'Comp1_Output';'Comp2_Output'},'The components outputNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.stateUnits,{'s';'s'},'The components stateUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.inputUnits,{'i';'i'},'The components inputUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.outputUnits,{'o';'o'},'The components outputUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.paramUnits,{'p';'p'},'The components paramUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.x,[sym('x1');sym('x2')],'The components states were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.u,[sym('u1');sym('u2')],'The components inputs were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.f,[f1;f2],'The components state equations were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.g,[g1;g2],'The components output equations were not added to the system correctly.');
            param = struct;
            param.Comp1_Parameter = [];
            param.Comp2_Parameter = [];
            testCase.verifyEqual(testCase.system.param,param,'The parameter structure of the system was not extended correcty.');
            testCase.verifyEqual(testCase.system.p,[Comp1_Parameter;Comp2_Parameter],'The p array of the system was not extended correcty.');
            
        end
        
        % ---------- checks for calculateValidSteadyStates ----------------
        
        function check_calculateValidSteadyStates_error(testCase)
            % Prepare the system
            c1 = Test_ODESCA_System_CompS0I1O1P1CP0('Comp1');
            testCase.system.addComponent(c1);
            
            % check the error
            testCase.verifyError(@()testCase.system.calculateValidSteadyStates,'ODESCA_System:calculateValidSteadyStates:noStates','The method does not throw a correct error if the system has no states.');
            
            % Prepare the system
            c2 = Test_ODESCA_System_CompS1I0O1P1CP0('Comp2');
            testCase.system.addComponent(c2);
            
            % check the error
            testCase.verifyError(@()testCase.system.calculateValidSteadyStates,'ODESCA_System:calculateValidSteadyStates:notAllParametersSet','The method does not throw a correct error if not all parameters were set.');
        end
        
        function check_calculateValidSteadyStates(testCase)
            % Prepare the system
            syms u_s1
            c1 = Test_ODESCA_System_CompS1I1O1P1CP0('Comp1');
            testCase.system.addComponent(c1);
            testCase.system.setParam('Comp1_Parameter',5);
            testCase.system.calculateValidSteadyStates();
            
            testCase.verifyEqual(testCase.system.validSteadyStates.x1,5*u_s1,'The method does not create the correct valid steady states.');
            testCase.verifyEqual(length(testCase.system.validSteadyStates.parameters),0,'The method does not create the correct valid steady states.');
            testCase.verifyEqual(length(testCase.system.validSteadyStates),1,'The method does not create the correct valid steady states.');
        end
        
        % ---------- checks for createPIDController ----------------
        
        function check_createPIDController_error(testCase)
            % Prepare the system
            c1 = Test_ODESCA_System_CompS1I1O1P1CP0('Comp1');
            c2 = Test_ODESCA_System_CompS1I1O1P1CP0('Comp2');
            testCase.system.addComponent(c1);
            testCase.system.addComponent(c2);
            
            % check the errors
            warning('off','all');
            testCase.system.createNonlinearSimulinkModel();
            testCase.verifyError(@()testCase.system.createPIDController(),'ODESCA_System:createPIDController:simulinkModelWithSameNameExists', 'The method does not throw a correct error if a simulink model with the same name already exists.');
            close_system('System',0);
            warning('on','all');

            testCase.verifyError(@()testCase.system.createPIDController(1),'ODESCA_System:createPIDController:sizeOfKWrong', 'The method does not throw a correct error if the size of Kp is wrong.');
            testCase.verifyError(@()testCase.system.createPIDController(1,1),'ODESCA_System:createPIDController:sizeOfKWrong', 'The method does not throw a correct error if the size of Kp or Ki is wrong.');
            testCase.verifyError(@()testCase.system.createPIDController(eye(2),1),'ODESCA_System:createPIDController:sizeOfKWrong', 'The method does not throw a correct error if the size of Kp or Ki is wrong.');
            testCase.verifyError(@()testCase.system.createPIDController(1,eye(2)),'ODESCA_System:createPIDController:sizeOfKWrong', 'The method does not throw a correct error if the size of Kp or Ki is wrong.');
            testCase.verifyError(@()testCase.system.createPIDController(1,1,1),'ODESCA_System:createPIDController:sizeOfKWrong', 'The method does not throw a correct error if the size of Kp or Ki is wrong.');
            testCase.verifyError(@()testCase.system.createPIDController(eye(2),eye(2),1),'ODESCA_System:createPIDController:sizeOfKWrong', 'The method does not throw a correct error if the size of Kp or Ki is wrong.');
            testCase.verifyError(@()testCase.system.createPIDController(1,eye(2),eye(2)),'ODESCA_System:createPIDController:sizeOfKWrong', 'The method does not throw a correct error if the size of Kp or Ki is wrong.');
            testCase.verifyError(@()testCase.system.createPIDController(eye(2),1,eye(2)),'ODESCA_System:createPIDController:sizeOfKWrong', 'The method does not throw a correct error if the size of Kp or Ki is wrong.');
            
            testCase.system.removeOutput('Comp1_Output');
            testCase.verifyError(@()testCase.system.createPIDController(),'ODESCA_System:createPIDController:ioSizeWrong', 'The method does not throw a correct error if the number of inputs does not match the number of outputs of the system.');
        end
        
        function check_createPIDController(testCase)
            % Prepare the system
            c1 = Test_ODESCA_System_CompS1I1O1P1CP0('Comp1');
            c1.setParam('Parameter',1);
            c2 = Test_ODESCA_System_CompS1I1O1P1CP0('Comp2');
            c2.setParam('Parameter',2);
            testCase.system.addComponent(c1);
            testCase.system.addComponent(c2);
            
            % check if simulating with no input
            warning('off','all');
            testCase.system.createPIDController();
            sim('System');
            close_system('System',0);
            
            % check if simulating with no input
            testCase.system.createPIDController([1 2; 0 1],[1 0; 0 2],[2 3; 0 1]);
            sim('System');
            close_system('System',0);
            warning('on','all');
        end
        
        % ---------- checks for connectInput ------------------------------
        
        function check_connectInput_error(testCase)
            % Prepare the system
            syms darkLord;
            syms x1 x2;
            syms u1 u2;
            p1 = sym('Comp1_Parameter');
            p2 = sym('Comp2_Parameter');
            c1 = Test_ODESCA_System_CompS1I1O1P1CP0('Comp1');
            c2 = Test_ODESCA_System_CompS1I1O1P1CP1('Comp2');
            c2.setConstructionParam('c',2);
            testCase.system.addComponent(c1);
            testCase.system.addComponent(c2);
            testCase.assertEqual(testCase.system.f,[-x1 + u1 * p1; -x2 + u2 * p2],'The method ''addComponent'' does not set the property f correctly so the test was aborted.');
            testCase.assertEqual(testCase.system.g,[x1 + u1 + p1; (u2 + p2)*(x2^2)],'The method ''addComponent'' does not set the property g correctly so the test was aborted.');
            
            % Check the errors for the first input argument ...
            testCase.verifyError(@()testCase.system.connectInput(sym('x'),x1),'ODESCA_System:connectInput:toConnectInvalid','The method does not throw a correct error if the first argument has the wrong type.');
            testCase.verifyError(@()testCase.system.connectInput(['test';'halo'],x1),'ODESCA_System:connectInput:toConnectInvalid','The method does not throw a correct error if the first argument has the wrong type.');
            testCase.verifyError(@()testCase.system.connectInput([],x1),'ODESCA_System:connectInput:toConnectInvalid','The method does not throw a correct error if the first argument has the wrong type.');
            testCase.verifyError(@()testCase.system.connectInput([1,5],x1),'ODESCA_System:connectInput:toConnectInvalid','The method does not throw a correct error if the first argument has the wrong type.');
            testCase.verifyError(@()testCase.system.connectInput([1;4],x1),'ODESCA_System:connectInput:toConnectInvalid','The method does not throw a correct error if the first argument has the wrong type.');
            
            % ... if the first input is a string
            testCase.verifyError(@()testCase.system.connectInput('Link',x1),'ODESCA_System:connectInput:inputNotFound','The method does not throw a correct error if there is no input with the given name in the system.');
            
            % ... if the first input is a number
            testCase.verifyError(@()testCase.system.connectInput(NaN,x1),'ODESCA_System:connectInput:invalidOutputNumber','The method does not throw a correct error if the first argument is an invalid number.');
            testCase.verifyError(@()testCase.system.connectInput(Inf,x1),'ODESCA_System:connectInput:invalidOutputNumber','The method does not throw a correct error if the first argument is an invalid number.');
            testCase.verifyError(@()testCase.system.connectInput(0,x1),'ODESCA_System:connectInput:invalidOutputNumber','The method does not throw a correct error if the first argument is an invalid number.');
            testCase.verifyError(@()testCase.system.connectInput(-1,x1),'ODESCA_System:connectInput:invalidOutputNumber','The method does not throw a correct error if the first argument is an invalid number.');
            testCase.verifyError(@()testCase.system.connectInput(3,x1),'ODESCA_System:connectInput:inputNumberExceedsIndex','The method does not throw a correct error if the number given exceeds the number of inputs of the system.');
            
            % Check the errors for the output argument
            testCase.verifyError(@()testCase.system.connectInput('Comp1_Input','YourMom'),'ODESCA_System:connectInput:outputNotFound','The method does not throw a correct error if there is no output with the name of the second input argument in the system.');
            testCase.verifyError(@()testCase.system.connectInput('Comp1_Input',5 + u1),'ODESCA_System:connectInput:substitutionLoop','The method does not throw a correct error if the symbolic variable for the input to be substituted is in the agrument ''connection''.');
            testCase.verifyError(@()testCase.system.connectInput('Comp1_Input',9 * darkLord),'ODESCA_System:connectInput:symbolicVariablesNotInSystem','The method does not thorw a correct error if the argument ''connection'' does contain symbolic variables which are not part of the system.');
        end
        
        function check_connectInput(testCase)
            % Prepare the system
            syms x1 x2;
            syms u1 u2;
            p1 = sym('Comp1_Parameter');
            p2 = sym('Comp2_Parameter');
            c1 = Test_ODESCA_System_CompS1I1O1P1CP0('Comp1');
            c2 = Test_ODESCA_System_CompS1I1O1P1CP1('Comp2');
            c2.setConstructionParam('c',2);
            testCase.system.addComponent(c1);
            testCase.system.addComponent(c2);
            testCase.assertEqual(testCase.system.f,[-x1 + u1 * p1; -x2 + u2 * p2],'The method ''addComponent'' does not set the property f correctly so the test was aborted.');
            testCase.assertEqual(testCase.system.g,[x1 + u1 + p1; (u2 + p2)*(x2^2)],'The method ''addComponent'' does not set the property g correctly so the test was aborted.');
            
            % Check the method for strings as input
            testCase.system.connectInput('Comp2_Input','Comp1_Output');
            testCase.verifyEqual(testCase.system.f,[-x1 + u1 * p1; -x2 + (x1 + u1 + p1) * p2],'The method does not change the state equations f correctly if both input arguments are strings.')
            testCase.verifyEqual(testCase.system.g,[x1 + u1 + p1; (x1 + u1 + p1 + p2)*(x2^2)],'The method does not change the output equations g correctly if both input arguments are strings.')
            testCase.verifyEqual(testCase.system.inputNames,{'Comp1_Input'},'The method does not change the input names correctly if both input arguments are strings.');
            testCase.verifyEqual(testCase.system.inputUnits,{'i'},'The method does not change the input names correctly if both input arguments are strings.');
            testCase.verifyEqual(testCase.system.u,u1,'The method does not change the inputs correctly if both input arguments are strings.');
            
            % Check the method for a number and a symbolic expression as
            % input
            testCase.resetSystem();
            testCase.system.addComponent(c1);
            testCase.system.addComponent(c2);
            testCase.system.connectInput(1, 5 + x1^2);
            testCase.verifyEqual(testCase.system.f,[-x1 + (5 + x1^2) * p1; -x2 + u1 * p2],'The method does not change the state equations f correctly if the inputs are a number and a symbolic expression.')
            testCase.verifyEqual(testCase.system.g,[x1 + (5 + x1^2) + p1; (u1 + p2)*(x2^2)],'The method does not change the output equations g correctly if both inputs are a number and a symbolic expression..')
            testCase.verifyEqual(testCase.system.inputNames,{'Comp2_Input'},'The method does not change the input names correctly if both input arguments are strings.');
            testCase.verifyEqual(testCase.system.inputUnits,{'i'},'The method does not change the input names correctly if both input arguments are strings.');
            testCase.verifyEqual(testCase.system.u,u1,'The method does not change the inputs correctly if both input arguments are strings.');
            
        end
        
        % ---------- checks for symLinearize ------------------------------
        
        function check_symLinearize(testCase)
            % Create symbolic variables for the test
            syms x1 x2;
            syms u1 u2;
            p1 = sym('Comp1_Parameter');
            p2 = sym('Comp2_Parameter');
            
            % Check the method for an empty system
            [A,B,C,D] = testCase.system.symLinearize();
            testCase.verifyEqual(A,[],'The symbolic linearization does not return a correct A matrix for an empty system.')
            testCase.verifyEqual(B,[],'The symbolic linearization does not return a correct B matrix for an empty system.')
            testCase.verifyEqual(C,[],'The symbolic linearization does not return a correct C matrix for an empty system.')
            testCase.verifyEqual(D,[],'The symbolic linearization does not return a correct D matrix for an empty system.')
            
            % Check the method for a system with components
            testCase.resetSystem();
            c1 = Test_ODESCA_System_CompS1I1O1P1CP0('Comp1');
            c2 = Test_ODESCA_System_CompS1I1O1P1CP1('Comp2');
            c2.setConstructionParam('c',2);
            testCase.system.addComponent(c1);
            testCase.system.addComponent(c2);
            testCase.system.connectInput(2,x1);
            testCase.assertEqual(testCase.system.f,[-x1 + u1 * p1; -x2 + x1 * p2],'The method ''addComponent'' does not set the property f correctly so the test was aborted.');
            testCase.assertEqual(testCase.system.g,[x1 + u1 + p1; (x1 + p2)*(x2^2)],'The method ''addComponent'' does not set the property g correctly so the test was aborted.');
            [A,B,C,D] = testCase.system.symLinearize();
            testCase.verifyEqual(A,[-1,0;p2,-1],'The symbolic linearization does not return a correct A matrix for a system with components.')
            testCase.verifyEqual(B,[p1;0],'The symbolic linearization does not return a correct B matrix for a system with components.')
            testCase.verifyEqual(C,[1,0;x2^2,2*x2*(p2+x1)],'The symbolic linearization does not return a correct C matrix for a system with components.')
            testCase.verifyEqual(D,[1;sym('0')],'The symbolic linearization does not return a correct D matrix for a system with components.')
            
        end
        
        % ---------- checks for removeOutput ------------------------------
        
        function check_removeOutput_error(testCase)
            % Prepare the system
            syms x1 x2;
            syms u1 u2;
            p1 = sym('Comp1_Parameter');
            p2 = sym('Comp2_Parameter');
            c1 = Test_ODESCA_System_CompS1I1O1P1CP0('Comp1');
            c2 = Test_ODESCA_System_CompS1I1O1P1CP0('Comp2');
            testCase.system.addComponent(c1);
            testCase.system.addComponent(c2);
            testCase.assertEqual(testCase.system.g,[x1 + u1 + p1; x2 + u2 + p2],'The method ''addComponent'' does not set the property g correctly so the test was aborted.');
            testCase.assertEqual(testCase.system.outputNames,{'Comp1_Output';'Comp2_Output'},'The method ''addComponent'' does not set the property g correctly so the test was aborted.');
            testCase.assertEqual(testCase.system.outputUnits,{'o';'o'},'The method ''addComponent'' does not set the property g correctly so the test was aborted.');
            
            % Check for errors because of a wrong input
            testCase.verifyError(@()testCase.system.removeOutput([1,4]),'ODESCA_System:removeOutputs:invalidInputArgument','The method does not throw a correct error if the input argument is invalid.');
            testCase.verifyError(@()testCase.system.removeOutput(sym('g')),'ODESCA_System:removeOutputs:invalidInputArgument','The method does not throw a correct error if the input argument is invalid.');
            testCase.verifyError(@()testCase.system.removeOutput(['Test';'Halo']),'ODESCA_System:removeOutputs:invalidInputArgument','The method does not throw a correct error if the input argument is invalid.');
            testCase.verifyError(@()testCase.system.removeOutput([]),'ODESCA_System:removeOutputs:invalidInputArgument','The method does not throw a correct error if the input argument is invalid.');
            
            % Check for errors if the output is given as string
            testCase.verifyError(@()testCase.system.removeOutput('Trollollol'),'ODESCA_System:removeOutputs:outputNotFound','The method does not throw a correct error if no output with the given name exists.');
            
            % Check for errors if the output is given as number
            testCase.verifyError(@()testCase.system.removeOutput(-1),'ODESCA_System:removeOutputs:invalidOutputNumber','The method does not throw a correct error if the input argument is an invalid number.');
            testCase.verifyError(@()testCase.system.removeOutput(0),'ODESCA_System:removeOutputs:invalidOutputNumber','The method does not throw a correct error if the input argument is an invalid number.');
            testCase.verifyError(@()testCase.system.removeOutput(NaN),'ODESCA_System:removeOutputs:invalidOutputNumber','The method does not throw a correct error if the input argument is an invalid number.');
            testCase.verifyError(@()testCase.system.removeOutput(Inf),'ODESCA_System:removeOutputs:invalidOutputNumber','The method does not throw a correct error if the input argument is an invalid number.');
            testCase.verifyError(@()testCase.system.removeOutput(3),'ODESCA_System:removeOutputs:outputNumberExceedsIndex','The method does not throw a correct error if the input number exceeds the number of outputs..');
                
            % Check if last output can not be removed
            testCase.system.removeOutput(1);
            testCase.verifyError(@()testCase.system.removeOutput(1),'ODESCA_System:removeOutputs:cannotRemoveLastOutput','The method does not give the correct error when the last output of a system is removed');
        end
        
        function check_removeOutput(testCase)
            % Prepare the system
            syms x1 x2 x3;
            syms u1 u2 u3;
            p1 = sym('Comp1_Parameter');
            p2 = sym('Comp2_Parameter');
            p3 = sym('Comp3_Parameter');
            c1 = Test_ODESCA_System_CompS1I1O1P1CP0('Comp1');
            c2 = Test_ODESCA_System_CompS1I1O1P1CP0('Comp2');
            c3 = Test_ODESCA_System_CompS1I1O1P1CP0('Comp3');
            testCase.system.addComponent(c1);
            testCase.system.addComponent(c2);
            testCase.system.addComponent(c3);
            testCase.assertEqual(testCase.system.g,[ x1 + u1 + p1;  x2 + u2 + p2;  x3 + u3 + p3],'The method ''addComponent'' does not set the property g correctly so the test was aborted.');
            testCase.assertEqual(testCase.system.outputNames,{'Comp1_Output';'Comp2_Output';'Comp3_Output'},'The method ''addComponent'' does not set the property g correctly so the test was aborted.');
            testCase.assertEqual(testCase.system.outputUnits,{'o';'o';'o'},'The method ''addComponent'' does not set the property g correctly so the test was aborted.');
            
            % Check if the remove of outputs works with index
            testCase.system.removeOutput(2);
            testCase.verifyEqual(testCase.system.g,[ x1 + u1 + p1; x3 + u3 + p3],'The method does not change the output equations g correctly for an index as input argument.');
            testCase.verifyEqual(testCase.system.outputNames,{'Comp1_Output';'Comp3_Output'},'The method does not change the output names correctly for an index as input argument.');
            testCase.verifyEqual(testCase.system.outputUnits,{'o';'o'},'The method does not change the output units correctly for an index as input argument.');
            
            % Check if the remove of outputs works with name
            testCase.system.removeOutput('Comp3_Output');
            testCase.verifyEqual(testCase.system.g,x1 + u1 + p1,'The method does not change the output equations g correctly for a string as input argument.');
            testCase.verifyEqual(testCase.system.outputNames,{'Comp1_Output'},'The method does not change the output names correctly for a string as input argument.');
            testCase.verifyEqual(testCase.system.outputUnits,{'o'},'The method does not change the output units correctly for a string as input argument.');  
        end
        
        % ---------- checks for equalizeParam ------------------------------
        
        function check_equalizeParam_error(testCase)
            % Prepare the system
            syms x1 x2 x3;
            syms u1 u2 u3;
            p1 = sym('Comp1_Parameter');
            p2 = sym('Comp2_Parameter');
            p3 = sym('Comp3_Parameter');
            c1 = Test_ODESCA_System_CompS1I1O1P1CP0('Comp1');
            c2 = Test_ODESCA_System_CompS1I1O1P1CP0('Comp2');
            c3 = Test_ODESCA_System_CompS1I1O1P2CP0('Comp3');
            testCase.system.addComponent(c1);
            testCase.system.addComponent(c2);
            testCase.system.addComponent(c3);
            testCase.assertEqual(testCase.system.g,[ x1 + u1 + p1;  x2 + u2 + p2;  x3 + u3 + p3],'The method ''addComponent'' does not set the property g correctly so the test was aborted.');
            testCase.assertEqual(testCase.system.outputNames,{'Comp1_Output';'Comp2_Output';'Comp3_Output'},'The method ''addComponent'' does not set the property g correctly so the test was aborted.');
            testCase.assertEqual(testCase.system.outputUnits,{'o';'o';'o'},'The method ''addComponent'' does not set the property g correctly so the test was aborted.');
            
            % Check for errors because of a wrong input
            testCase.verifyError(@()testCase.system.equalizeParam(1,{'Comp1_Parameter'}),'ODESCA_System:equalizeParam:parameterNameIsNoString','The method does not throw a correct error if the parameter to be kept is not a string.');
            testCase.verifyError(@()testCase.system.equalizeParam('Comp1_Parameter',1),'ODESCA_System:equalizeParam:parameterNameIsNoCell','The method does not throw a correct error if the parameter to be replaced is not a cell.');
            testCase.verifyError(@()testCase.system.equalizeParam('Comp1_Parameter',{'Comp2_Parameter',1}),'ODESCA_System:equalizeParam:parameterNameIsNoString','The method does not throw a correct error if the parameter to be replaced is not a cell of strings.');
            testCase.verifyError(@()testCase.system.equalizeParam('Comp1_Parameter',{'Comp2_Parameter','Comp3_Parameter','Comp3_anotherParameter','dummy'}),'ODESCA_System:equalizeParam:notEnoughParametersFound','The method does not throw a correct error if the system has less parameters than accessed.');
            testCase.verifyError(@()testCase.system.equalizeParam('Comp1_Parameter',{'Comp2_Parameter','dummy'}),'ODESCA_System:equalizeParam:parameterDoesNotExist','The method does not throw a correct error if one of the parameter names do not exist in the system.');
            testCase.verifyError(@()testCase.system.equalizeParam('Comp1_Parameter',{'dummy','Comp2_Parameter'}),'ODESCA_System:equalizeParam:parameterDoesNotExist','The method does not throw a correct error if one of the parameter names do not exist in the system.');
            testCase.verifyError(@()testCase.system.equalizeParam('dummy',{'Comp2_Parameter','Comp1_Parameter'}),'ODESCA_System:equalizeParam:parameterDoesNotExist','The method does not throw a correct error if one of the parameter names do not exist in the system.');
            testCase.verifyError(@()testCase.system.equalizeParam('dummy',{'Comp2_Parameter','Comp1_Parameter'}),'ODESCA_System:equalizeParam:parameterDoesNotExist','The method does not throw a correct error if one of the parameter names do not exist in the system.');
            testCase.verifyError(@()testCase.system.equalizeParam('Comp1_Parameter',{'Comp2_Parameter','Comp3_anotherParameter'}),'ODESCA_System:equalizeParam:unitsNotEqual','The method does not throw a correct error if the units of the parameters are not equal.');
            testCase.verifyError(@()testCase.system.equalizeParam('Comp1_Parameter',{'Comp3_anotherParameter','Comp2_Parameter'}),'ODESCA_System:equalizeParam:unitsNotEqual','The method does not throw a correct error if the units of the parameters are not equal.');
            testCase.verifyError(@()testCase.system.equalizeParam('Comp3_anotherParameter',{'Comp2_Parameter','Comp1_Parameter'}),'ODESCA_System:equalizeParam:unitsNotEqual','The method does not throw a correct error if the units of the parameters are not equal.');
            testCase.verifyError(@()testCase.system.equalizeParam('Comp1_Parameter',{'Comp2_Parameter','Comp1_Parameter'}),'ODESCA_System:equalizeParam:replaceParamAndKeepParamEqual','The method does not throw a correct error if the cell paramReplace contains paramKeep.');
        end
        
        function check_equalizeParam(testCase)
            % Prepare the system
            syms x1 x2 x3;
            syms u1 u2 u3;
            p1 = sym('Comp1_Parameter');
            p2 = sym('Comp2_Parameter');
            p3 = sym('Comp3_Parameter');
            p4 = sym('Comp3_anotherParameter');
            c1 = Test_ODESCA_System_CompS1I1O1P1CP0('Comp1');
            c2 = Test_ODESCA_System_CompS1I1O1P1CP0('Comp2');
            c3 = Test_ODESCA_System_CompS1I1O1P2CP0('Comp3');
            testCase.system.addComponent(c1);
            testCase.system.addComponent(c2);
            testCase.system.addComponent(c3);
            testCase.assertEqual(testCase.system.g,[ x1 + u1 + p1;  x2 + u2 + p2;  x3 + u3 + p3 ],'The method ''addComponent'' does not set the property g correctly so the test was aborted.');
            testCase.assertEqual(testCase.system.outputNames,{'Comp1_Output';'Comp2_Output';'Comp3_Output'},'The method ''addComponent'' does not set the property g correctly so the test was aborted.');
            testCase.assertEqual(testCase.system.outputUnits,{'o';'o';'o'},'The method ''addComponent'' does not set the property g correctly so the test was aborted.');
            
            % Check if equalizeParam works
            compare_param.Comp1_Parameter = [];
            compare_param.Comp3_anotherParameter = [];
            testCase.system.equalizeParam('Comp1_Parameter',{'Comp2_Parameter','Comp3_Parameter'});
            testCase.verifyEqual(testCase.system.f,[ p1 * u1 - x1; p1 * u2 - x2; p4 - x3 + p1 * u3 ],'The method does not change the state equations f correctly.');
            testCase.verifyEqual(testCase.system.g,[ x1 + u1 + p1;  x2 + u2 + p1;  x3 + u3 + p1 ],'The method does not change the output equations g correctly.');
            testCase.verifyEqual(testCase.system.p,[ p1; p4 ],'The method does not change the parameter list p correctly.');
            testCase.verifyEqual(testCase.system.param,compare_param,'The method does not change the param struct correctly.');
            testCase.verifyEqual(testCase.system.paramUnits,{'p';'anotherP'},'The method does not change the parameter units correctly.');     
        end
        
        % ---------- checks for renameComponent ---------------------------
        
        function check_renameComponent_error(testCase)
            % Prepare the system
            c1 = Test_ODESCA_System_CompS1I1O1P1CP0('Comp1');
            testCase.system.addComponent(c1);
            testCase.assertEqual(testCase.system.components,{'Comp1'},'The method ''addComponent'' does not set the property components correctly so the test was aborted.');
            
            testCase.verifyError(@()testCase.system.renameComponent([],'Renamed'),'ODESCA_System:renameComponent:oldNameNotAString','The method does not throw a correct error if the first input argument is not a string.');
            testCase.verifyError(@()testCase.system.renameComponent(5,'Renamed'),'ODESCA_System:renameComponent:oldNameNotAString','The method does not throw a correct error if the first input argument is not a string.');
            testCase.verifyError(@()testCase.system.renameComponent(['test';'halo'],'Renamed'),'ODESCA_System:renameComponent:oldNameNotAString','The method does not throw a correct error if the first input argument is not a string.');
            testCase.verifyError(@()testCase.system.renameComponent('TheCakeIsALie','Renamed'),'ODESCA_System:renameComponent:oldNameNotInSystem','The method does not throw a correct error if there is no componentn with the name of the first argument in the system.');
            testCase.verifyError(@()testCase.system.renameComponent('Comp1','#WTF'),'ODESCA_System:renameComponent:newNameNotValid','The method does not throw a correct error if the new name is not a valid MATLAB variable name.');
            testCase.verifyError(@()testCase.system.renameComponent('Comp1','abcdefghijabcdefghijabcdefghij123'),'ODESCA_System:renameComponent:newNameLengthInvalid','The method does not throw a correct error if the new name has more then 31 letters.');
            c2 = Test_ODESCA_System_CompS1I1O1P1CP0('Comp2');
            testCase.system.addComponent(c2);
            testCase.verifyError(@()testCase.system.renameComponent('Comp1','Comp2'),'ODESCA_System:renameComponent:newNameAlreadyInSystem','The method does not throw a correct error if there is already a component in the system with the same name.');
        end
        
        function check_renameComponent(testCase)
            % Prepare the system
            syms x1 x2;
            syms u1 u2;
            p1 = sym('Comp1_Parameter'); p1_neu = sym('Renamed_Parameter');
            p2_neu = sym('Second_Parameter');
            c1 = Test_ODESCA_System_CompS1I1O1P1CP0('Comp1');
            testCase.system.addComponent(c1);
            testCase.assertEqual(testCase.system.stateNames,{'Comp1_State'},'The method ''addComponent'' does not set the property stateNames correctly so the test was aborted.');
            testCase.assertEqual(testCase.system.inputNames,{'Comp1_Input'},'The method ''addComponent'' does not set the property inputNames correctly so the test was aborted.');
            testCase.assertEqual(testCase.system.outputNames,{'Comp1_Output'},'The method ''addComponent'' does not set the property outputNames correctly so the test was aborted.');
            testCase.assertEqual(testCase.system.p,p1,'The method ''addComponent'' does not set the property p correctly so the test was aborted.');
            testCase.assertEqual(testCase.system.f,-x1 + u1 * p1,'The method ''addComponent'' does not set the property f correctly so the test was aborted.');
            testCase.assertEqual(testCase.system.g, x1 + u1 + p1,'The method ''addComponent'' does not set the property g correctly so the test was aborted.');
            testCase.assertEqual(testCase.system.components,{'Comp1'},'The method ''addComponent'' does not set the property components correctly so the test was aborted.');
            
            % Check the method for only one component in the system
            testCase.system.renameComponent('Comp1','Renamed');
            testCase.verifyEqual(testCase.system.stateNames,{'Renamed_State'},'The method ''addComponent'' does not set the property stateNames correctly so the test was aborted.');
            testCase.verifyEqual(testCase.system.inputNames,{'Renamed_Input'},'The method ''addComponent'' does not set the property inputNames correctly so the test was aborted.');
            testCase.verifyEqual(testCase.system.outputNames,{'Renamed_Output'},'The method ''addComponent'' does not set the property outputNames correctly so the test was aborted.');
            testCase.verifyEqual(testCase.system.p,p1_neu,'The method ''addComponent'' does not set the property p correctly so the test was aborted.');
            testCase.verifyEqual(testCase.system.f,-x1 + u1 * p1_neu,'The method ''addComponent'' does not set the property f correctly so the test was aborted.');
            testCase.verifyEqual(testCase.system.g, x1 + u1 + p1_neu,'The method ''addComponent'' does not set the property g correctly so the test was aborted.');
            testCase.verifyEqual(testCase.system.components,{'Renamed'},'The method ''addComponent'' does not set the property components correctly so the test was aborted.');
            
            % Test the method for more than one component in the system
            c2 = Test_ODESCA_System_CompS1I1O1P1CP0('Comp2');
            testCase.system.addComponent(c2);
            testCase.system.renameComponent('Comp2','Second');
            testCase.verifyEqual(testCase.system.stateNames,{'Renamed_State';'Second_State'},'The method ''addComponent'' does not set the property stateNames correctly so the test was aborted.');
            testCase.verifyEqual(testCase.system.inputNames,{'Renamed_Input';'Second_Input'},'The method ''addComponent'' does not set the property inputNames correctly so the test was aborted.');
            testCase.verifyEqual(testCase.system.outputNames,{'Renamed_Output';'Second_Output'},'The method ''addComponent'' does not set the property outputNames correctly so the test was aborted.');
            testCase.verifyEqual(testCase.system.p,[p1_neu;p2_neu],'The method ''addComponent'' does not set the property p correctly so the test was aborted.');
            testCase.verifyEqual(testCase.system.f,[-x1 + u1 * p1_neu; -x2 + u2 * p2_neu],'The method ''addComponent'' does not set the property f correctly so the test was aborted.');
            testCase.verifyEqual(testCase.system.g,[ x1 + u1 + p1_neu;  x2 + u2 + p2_neu],'The method ''addComponent'' does not set the property g correctly so the test was aborted.');
            testCase.verifyEqual(testCase.system.components,{'Renamed';'Second'},'The method ''addComponent'' does not set the property components correctly so the test was aborted.');
        end
        
        % ---------- checks for addSystem ---------------------------------
        
        function check_addSystem_error(tc)
           sys1 = ODESCA_System();
           
           tc.system = getCommonSystem(tc,'WT',true);
           cp1 = Test_ODESCA_System_CompS0I0O1P0CP0();
           tc.verifyError(@()tc.system.addSystem(cp1),'ODESCA_System:addSystem:newSysNotASystem','The method ''addSystem'' does not throw the an correct error when a wrong data type is given.');
           tc.verifyError(@()tc.system.addSystem([1 2 3]), 'ODESCA_System:addSystem:newSysNotASystem','The method ''addSystem'' does not throw the an correct error when a wrong data type is given.');
           tc.verifyError(@()tc.system.addSystem('megaatomroflmfao'), 'ODESCA_System:addSystem:newSysNotASystem','The method ''addSystem'' does not throw the an correct error when a wrong data type is given.');
           
           % check if correct warnings will be given when new system is
           % empty

           tc.verifyWarning(@()tc.system.addSystem(sys1),'ODESCA_System:addSystem:newSystemEmpty','The method ''addSystem does not throw the correct warning when an empty system is given as system to add.');
           
           % check if the correct warning will be given when both systems
           % are empty
           tc.resetSystem();
           tc.verifyWarning(@()tc.system.addSystem(sys1),'ODESCA_System:addSystem:bothSystemsEmpty','The method ''addSystem does not throw the correct warning when the root system is emptry and an empty system is given as system to add.');
 
           % check if the correct warnings will be given when the root
           % system is empty
           tc.resetSystem();
           commonSys = getCommonSystem(tc,'WT',true);
           tc.verifyWarning(@()tc.system.addSystem(commonSys),'ODESCA_System:addSystem:rootSystemEmpty','The method ''addSystem does not throw the correct warning when the root system is empty.');
           
           % check if the correct warnings will be given when there are 2
           % systems with identical named components in it
           tc.resetSystem();
           tc.system = getCommonSystem(tc,'SameName',true);
           sys1 = getCommonSystem(tc,'SameName',true);
           tc.verifyWarning(@()tc.system.addSystem(sys1),'ODESCA_System:addSystem:namesChanged','The method ''addSystem does not throw the correct warning when there are components with identical names in both systems.');
        end
        
        function check_addSystem(testCase)
            % checks overtaken from addComponent()
            % changed from addComponent to addSystem method.
            
            % expected values
            x = [];
            u = [];
            f = [];
            g = sym('1');
            param = [];
            
            c1 = Test_ODESCA_System_CompS0I0O1P0CP0('Comp1');
            sys1 = ODESCA_System('Sys1',c1);
            
            % deactivate warning that the rootsystem is empty
            warning('off','all');
            testCase.system.addSystem(sys1);
            warning('on','all');
            testCase.verifyEqual(testCase.system.components,{'Comp1'},'The component name was not added to the system correctly.');
            testCase.verifyEqual(testCase.system.stateNames,{},'The components stateNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.inputNames,{},'The components inputNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.outputNames,{'Comp1_Output'},'The components outputNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.stateUnits,{},'The components stateUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.inputUnits,{},'The components inputUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.outputUnits,{'o'},'The components outputUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.paramUnits,{},'The components paramUnits were not added to the system correctly.');
            
            testCase.verifyEqual(testCase.system.x,x,'The components states were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.u,u,'The components inputs were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.f,f,'The components state equations were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.g,g,'The components output equations were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.param,param,'The parameter structure of the system was not extanded correcty.');
            
            % add a second component without states inputs and parameters
            % to ensure that adding a second component will work correctly
            
            % expected values
            x = [];
            u = [];
            f = [];
            g = [sym('1'); sym('1')];
            param = [];
            
            
            c2 = Test_ODESCA_System_CompS0I0O1P0CP0('Comp2');
            sys2 = ODESCA_System('Sys2',c2);
            testCase.system.addSystem(sys2);
            testCase.verifyEqual(testCase.system.components,{'Comp1';'Comp2'},'The component name was not added to the system correctly.');
            testCase.verifyEqual(testCase.system.stateNames,{},'The components stateNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.inputNames,{},'The components inputNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.outputNames,{'Comp1_Output';'Comp2_Output'},'The components outputNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.stateUnits,{},'The components stateUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.inputUnits,{},'The components inputUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.outputUnits,{'o';'o'},'The components outputUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.paramUnits,{},'The components paramUnits were not added to the system correctly.');
            
            testCase.verifyEqual(testCase.system.x,x,'The components states were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.u,u,'The components inputs were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.f,f,'The components state equations were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.g,g,'The components output equations were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.param,param,'The parameter structure of the system was not extended correcty.');
                
            % add a third component. Now with 1 state, 1 inputs and a
            % parameter
            
            % expected values
            syms x1;
            syms u1;
            syms Comp3_Parameter;
            f3 = - x1 + u1 * Comp3_Parameter;
            g3 = x1 + u1 + Comp3_Parameter;

            x = [x1];
            u = [u1];
            f = [f3];
            g = [sym('1'); sym('1');g3];
            param = struct;
            param.Comp3_Parameter = [];
            
            c3 = Test_ODESCA_System_CompS1I1O1P1CP0('Comp3');
            sys3 = ODESCA_System('Sys3',c3);
            testCase.system.addSystem(sys3);
            
            testCase.verifyEqual(testCase.system.components,{'Comp1';'Comp2';'Comp3'},'The component name was not added to the system correctly.');
            testCase.verifyEqual(testCase.system.stateNames,{'Comp3_State'},'The components stateNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.inputNames,{'Comp3_Input'},'The components inputNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.outputNames,{'Comp1_Output';'Comp2_Output';'Comp3_Output'},'The components outputNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.stateUnits,{'s'},'The components stateUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.inputUnits,{'i'},'The components inputUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.outputUnits,{'o';'o';'o'},'The components outputUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.paramUnits,{'p'},'The components paramUnits were not added to the system correctly.');
            
            testCase.verifyEqual(testCase.system.x,x,'The components states were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.u,u,'The components inputs were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.f,f,'The components state equations were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.g,g,'The components output equations were not added to the system correctly.');

            testCase.verifyEqual(testCase.system.param,param,'The parameter structure of the system was not extanded correcty.');
            testCase.verifyEqual(testCase.system.p,Comp3_Parameter,'The p array of the system was not extanded correcty.');
            
            % add a fourth component without states inputs and parameters
            % again
            
            % expected values
            syms x1;
            syms u1;
            syms Comp3_Parameter;
            f3 = - x1 + u1 * Comp3_Parameter;
            g3 = x1 + u1 + Comp3_Parameter;

            x = [x1];
            u = [u1];
            f = [f3];
            g = [sym('1'); sym('1');g3;sym('1')];
            param = struct;
            param.Comp3_Parameter = [];
            
            c4 = Test_ODESCA_System_CompS0I0O1P0CP0('Comp4');
            sys4 = ODESCA_System('Sys4',c4);
            testCase.system.addSystem(sys4);
            
            testCase.verifyEqual(testCase.system.components,{'Comp1';'Comp2';'Comp3';'Comp4'},'The component name was not added to the system correctly.');
            testCase.verifyEqual(testCase.system.stateNames,{'Comp3_State'},'The components stateNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.inputNames,{'Comp3_Input'},'The components inputNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.outputNames,{'Comp1_Output';'Comp2_Output';'Comp3_Output';'Comp4_Output'},'The components outputNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.stateUnits,{'s'},'The components stateUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.inputUnits,{'i'},'The components inputUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.outputUnits,{'o';'o';'o';'o'},'The components outputUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.paramUnits,{'p'},'The components paramUnits were not added to the system correctly.');
            
            testCase.verifyEqual(testCase.system.x,x,'The components states were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.u,u,'The components inputs were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.f,f,'The components state equations were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.g,g,'The components output equations were not added to the system correctly.');

            testCase.verifyEqual(testCase.system.param,param,'The parameter structure of the system was not extanded correcty.');
            testCase.verifyEqual(testCase.system.p,Comp3_Parameter,'The p array of the system was not extanded correcty.');

            
            % check if adding a system will work when the system that
            % should be added consits more than one component.
            % The expected values are still the same as the step before.
            testCase.resetSystem();
            testCase.system.addComponent(c1);
            
            sys5 = ODESCA_System('Sys5',c2);
            sys5.addComponent(c3);
            sys5.addComponent(c4);
            
            testCase.system.addSystem(sys5);
            testCase.verifyEqual(testCase.system.components,{'Comp1';'Comp2';'Comp3';'Comp4'},'The component name was not added to the system correctly.');
            testCase.verifyEqual(testCase.system.stateNames,{'Comp3_State'},'The components stateNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.inputNames,{'Comp3_Input'},'The components inputNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.outputNames,{'Comp1_Output';'Comp2_Output';'Comp3_Output';'Comp4_Output'},'The components outputNames were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.stateUnits,{'s'},'The components stateUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.inputUnits,{'i'},'The components inputUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.outputUnits,{'o';'o';'o';'o'},'The components outputUnits were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.paramUnits,{'p'},'The components paramUnits were not added to the system correctly.');
            
            testCase.verifyEqual(testCase.system.x,x,'The components states were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.u,u,'The components inputs were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.f,f,'The components state equations were not added to the system correctly.');
            testCase.verifyEqual(testCase.system.g,g,'The components output equations were not added to the system correctly.');

            testCase.verifyEqual(testCase.system.param,param,'The parameter structure of the system was not extanded correcty.');
            testCase.verifyEqual(testCase.system.p,Comp3_Parameter,'The p array of the system was not extanded correcty.'); 
        end
        
        % ---------- Checks for createMatlabFunction ----------------------
        
        function check_createMatlabFunction_error(tc)
            % check if the correct error is thrown if the number of
            % arguments is not even.
            tc.resetSystem();
            tc.system =  getCommonSystem(tc, 'WT', false);
            
            tc.verifyError(@()tc.system.createMatlabFunction('no1','no2','no3'),'ODESCA_System:createMatlabFunction:oddNumberOfInputArguments','The method ''createMatlabFunction'' does not throw the correct error if an odd number of arguments is given');
            
            % check if the correct warning is thriwn if the given option in
            % the arguments is not a string
            tc.verifyWarning(@()tc.system.createMatlabFunction(1,5),'ODESCA_System:createMatlabFunction:optionNotAString','The method ''createMatlabFunction'' does not throw the correct warning if the option argument is not a string.');
            
            % check if the correct warning is thrown if the given option
            % does not exist
            tc.verifyWarning(@()tc.system.createMatlabFunction('beatifulRain',5),'ODESCA_System:createMatlabFunction:invalidInputOption','The method ''createMatlabFunction'' does not throw the correct warning if the given option does not exist.');
            
            % check if the correct warning is thrown if the argument given
            % within the 'type' option is not correct
            tc.verifyWarning(@()tc.system.createMatlabFunction('type','TrumpTheDog'),'ODESCA_System:createMatlabFunction:invalidType','The method ''createMatlabFunction'' does not throw the correct warning if the given argument within the ''type'' option is not of correct format.');
            tc.verifyWarning(@()tc.system.createMatlabFunction('type',[1 0]),'ODESCA_System:createMatlabFunction:invalidType','The method ''createMatlabFunction'' does not throw the correct warning if the given argument within the ''type'' option is not of correct format.');
            tc.verifyWarning(@()tc.system.createMatlabFunction('type',[1 0]'),'ODESCA_System:createMatlabFunction:invalidType','The method ''createMatlabFunction'' does not throw the correct warning if the given argument within the ''type'' option is not of correct format.');
            
            % check if the correct warning is thrown if the argument given
            % within the 'usenumericparam' option is not correct
            tc.verifyWarning(@()tc.system.createMatlabFunction('usenumericparam',1),'ODESCA_System:createMatlabFunction:invalidOptionUseNumericParam','The method ''createMatlabFunction'' does not throw the correct warning if the given argument within the ''usenumericparam'' option is not of correct format.');
            tc.verifyWarning(@()tc.system.createMatlabFunction('usenumericparam',[true true]),'ODESCA_System:createMatlabFunction:invalidOptionUseNumericParam','The method ''createMatlabFunction'' does not throw the correct warning if the given argument within the ''usenumericparam'' option is not of correct format.');
            tc.verifyWarning(@()tc.system.createMatlabFunction('usenumericparam',[true true]'),'ODESCA_System:createMatlabFunction:invalidOptionUseNumericParam','The method ''createMatlabFunction'' does not throw the correct warning if the given argument within the ''usenumericparam'' option is not of correct format.');
        
            % check if the correct warning is thrown if the argument given
            % within the 'usenumericparam' option is not correct
            tc.verifyWarning(@()tc.system.createMatlabFunction('arrayinputs',1),'ODESCA_System:createMatlabFunction:invalidOptionArrayInputs','The method ''createMatlabFunction'' does not throw the correct warning if the given argument within the ''arrayinputs'' option is not of correct format.');
            tc.verifyWarning(@()tc.system.createMatlabFunction('arrayinputs',[true true]),'ODESCA_System:createMatlabFunction:invalidOptionArrayInputs','The method ''createMatlabFunction'' does not throw the correct warning if the given argument within the ''arrayinputs'' option is not of correct format.');
            tc.verifyWarning(@()tc.system.createMatlabFunction('arrayinputs',[true true]'),'ODESCA_System:createMatlabFunction:invalidOptionArrayInputs','The method ''createMatlabFunction'' does not throw the correct warning if the given argument within the ''arrayinputs'' option is not of correct format.');
            
            % check if the correct error is thrown if a matlab function
            % with numeric parameters should be generated and there are
            % unset parameter
            tc.system.setParam('WT_c',4200);
            tc.verifyError(@()tc.system.createMatlabFunction('useNumericParam',true),'ODESCA_System:createMatlabFunction:notAllParamSet','The method ''createMatlabFunction'' does not throw the correct error if the option ''useNumericParam'' is selected but there a unset parameters.');
        end
        
        function check_createMatlabFunction(tc)
            % check if a system with one input state output and parameter
            % can be correctly generated into a matlab function with
            % different options
            tc.resetSystem();
            cp1 = Test_ODESCA_System_CompS1I1O1P1CP0('Comp1');
            cp2 = Test_ODESCA_System_CompS1I1O1P1CP0('Comp2');
            tc.system.addComponent(cp1);
            tc.system.addComponent(cp2);
            
            % continuous, useNumericParam = false, arrayInputs = false
            [funF, funG] = tc.system.createMatlabFunction('type','continuous','useNumericParam',false,'arrayInputs',false);
            tc.verifyEqual(rat(funF(1,1,1,1,1,1)),rat([0;0]),'The method ''createMatlabFunction'' calculates wrong results for function f.');
            tc.verifyEqual(rat(funG(1,1,1,1,1,1)),rat([3;3]),'The method ''createMatlabFunction'' calculates wrong results for function g.');
             
            % discrete, useNumericParam = false, arrayInputs = false
            tc.system.setDefaultSampleTime(0.1);
            [funF, funG] = tc.system.createMatlabFunction('type','euler','useNumericParam',false,'arrayInputs',false);
            tc.verifyEqual(rat(funF(1,1,1,1,1,1)),rat([1;1]),'The method ''createMatlabFunction'' calculates wrong results for function f.');
            tc.verifyEqual(rat(funG(1,1,1,1,1,1)),rat([3;3]),'The method ''createMatlabFunction'' calculates wrong results for function g.');
            
            % continuous, useNumericParam = true, arrayInputs = false
            tc.system.setParam('Comp1_Parameter',1);
            tc.system.setParam('Comp2_Parameter',1);
            [funF, funG] = tc.system.createMatlabFunction('type','continuous','useNumericParam',true,'arrayInputs',false);
            tc.verifyEqual(rat(funF(1,1,1,1)),rat([0;0]),'The method ''createMatlabFunction'' calculates wrong results for function f.');
            tc.verifyEqual(rat(funG(1,1,1,1)),rat([3;3]),'The method ''createMatlabFunction'' calculates wrong results for function g.');
            
            [funF, funG] = tc.system.createMatlabFunction('type','continuous','useNumericParam',false,'arrayInputs',true);
            tc.verifyEqual(rat(funF([1, 1],[1, 1],[1, 1])),rat([0;0]),'The method ''createMatlabFunction'' calculates wrong results for function f.');
            tc.verifyEqual(rat(funG([1, 1],[1, 1],[1, 1])),rat([3;3]),'The method ''createMatlabFunction'' calculates wrong results for function g.');
            
            % check if an empty system can be generated to a matlabFunction
            tc.resetSystem(); 
            tc.verifyError(@()tc.system.createMatlabFunction('type','continuous','useNumericParam',false,'arrayInputs',false),'ODESCA_System:createMatlabFunction:emptySystem','The method ''createMatlabFunction'' does not throw the correct error if the system is empty.');
            
            % TODO: implement detailed checks here when matlabFunction is
            % adjusted so that it can be called with either no state
            % equations or no output equations
            
        end
        
        % ---------- Checks for SimulateStep ------------------------------
        
        function check_simulateStep_error(tc)
        
            % check if the correct error is given when the system that should
            % be simulated has no input
            cp1 = Test_ODESCA_System_CompS1I0O1P1CP0();
            tc.system.addComponent(cp1);
            tc.verifyError(@()tc.system.simulateStep(20,1,1),'ODESCA_System:simulateStep:emptyStatesOrInputs','The method does not throw a correct error if the system has no input.');
        
            % check if the correct error is given if the system that should be
            % simulated has no states
            tc.resetSystem();
            cp2 = Test_ODESCA_System_CompS0I1O1P1CP0();
            tc.system.addComponent(cp2);
            tc.verifyError(@()tc.system.simulateStep(20,1,1),'ODESCA_System:simulateStep:emptyStatesOrInputs','The method does not throw a correct error if the system has no states.');
        
            % check if the correct error is given if nargin < 4
            tc.resetSystem();
            cp3 = Test_ODESCA_System_CompS1I1O1P1CP0();
            tc.system.addComponent(cp3);
            tc.verifyError(@()tc.system.simulateStep(20,1),'ODESCA_System:simulateStep:wrongNumberOfInputArguments','The method does not throw a correct error if there are not enoght input arguments.');
            
            % check if the correct error is given if nargin > 7 is given
            tc.verifyError(@()tc.system.simulateStep(20,1,1,1,1,1,1),'ODESCA_System:simulateStep:wrongNumberOfInputArguments','The method does not throw a correct error if there are too much input arguments.');
        
            % check if the correct error is thrown when the timespan is given
            % in an invalid format
            tc.verifyError(@()tc.system.simulateStep(1,1,1),'ODESCA_System:simulateStep:invalidTimespan','The method does not throw a correct error if timespan is not given in the correct format.');
            tc.verifyError(@()tc.system.simulateStep('hallo',1,1),'ODESCA_System:simulateStep:invalidTimespan','The method does not throw a correct error if timespan is not given in the correct format.');
            tc.verifyError(@()tc.system.simulateStep([20 30 40],1,1),'ODESCA_System:simulateStep:invalidTimespan','The method does not throw a correct error if timespan is not given in the correct format.');
            tc.verifyError(@()tc.system.simulateStep([0 inf],1,1),'ODESCA_System:simulateStep:invalidTimespan','The method does not throw a correct error if timespan is not given in the correct format.');
            tc.verifyError(@()tc.system.simulateStep([0 inf],1,1),'ODESCA_System:simulateStep:invalidTimespan','The method does not throw a correct error if timespan is not given in the correct format.');
            tc.verifyError(@()tc.system.simulateStep([nan 1000],1,1),'ODESCA_System:simulateStep:invalidTimespan','The method does not throw a correct error if timespan is not given in the correct format.');
            tc.verifyError(@()tc.system.simulateStep([0 complex(1,1)],1,1),'ODESCA_System:simulateStep:invalidTimespan','The method does not throw a correct error if timespan is not given in the correct format.');
            tc.verifyError(@()tc.system.simulateStep([1000 5],1,1),'ODESCA_System:simulateStep:invalidTimespan','The method does not throw a correct error if timespan is not given in the correct format.');
            tc.verifyError(@()tc.system.simulateStep({1,5},1,1),'ODESCA_System:simulateStep:invalidTimespan','The method does not throw a correct error if timespan is not given in the correct format.');
            
            % check if the correct error is thrown when the initial states are
            % given in the wrong format
            tc.verifyError(@()tc.system.simulateStep([0 10],'hallo',1),'ODESCA_System:simulateStep:invalidInitialState','The method does not throw a correct error if x0 is not given in the correct format.');
            tc.verifyError(@()tc.system.simulateStep([0 10],{1},1),'ODESCA_System:simulateStep:invalidInitialState','The method does not throw a correct error if x0 is not given in the correct format.');
            tc.verifyError(@()tc.system.simulateStep([0 10],[50 50 50 50],1),'ODESCA_System:simulateStep:invalidInitialState','The method does not throw a correct error if x0 is not given in the correct format.');
            tc.verifyError(@()tc.system.simulateStep([0 10],complex(1,1),1),'ODESCA_System:simulateStep:invalidInitialState','The method does not throw a correct error if x0 is not given in the correct format.');
            tc.verifyError(@()tc.system.simulateStep([0 10],inf,1),'ODESCA_System:simulateStep:invalidInitialState','The method does not throw a correct error if x0 is not given in the correct format.');
            tc.verifyError(@()tc.system.simulateStep([0 10],nan,1),'ODESCA_System:simulateStep:invalidInitialState','The method does not throw a correct error if x0 is not given in the correct format.');
                    
            % check if the correct error is thrown when the given input values
            % are invalid
            % - not numeric
            % - wrong dimension
            % - complex, infs, nans
            tc.verifyError(@()tc.system.simulateStep([0 10],1,'hallo'),'ODESCA_System:simulateStep:invalidFirstInput','The method does not throw a correct error if u0 is not given in the correct format.');
            tc.verifyError(@()tc.system.simulateStep([0 10],1,{1}),'ODESCA_System:simulateStep:invalidFirstInput','The method does not throw a correct error if u0 is not given in the correct format.');
            tc.verifyError(@()tc.system.simulateStep([0 10],1,[50 50 50 50]),'ODESCA_System:simulateStep:invalidFirstInput','The method does not throw a correct error if u0 is not given in the correct format.');
            tc.verifyError(@()tc.system.simulateStep([0 10],1,complex(1,1)),'ODESCA_System:simulateStep:invalidFirstInput','The method does not throw a correct error if u0 is not given in the correct format.');
            tc.verifyError(@()tc.system.simulateStep([0 10],1,inf),'ODESCA_System:simulateStep:invalidFirstInput','The method does not throw a correct error if u0 is not given in the correct format.');
            tc.verifyError(@()tc.system.simulateStep([0 10],1,nan),'ODESCA_System:simulateStep:invalidFirstInput','The method does not throw a correct error if u0 is not given in the correct format.');
        
            % check if the correct error is thrown when the time for the
            % second step is invalid
            % - not numeric
            % - wrong dimension
            % - complex, infs, nans
            % - lower than t_step1
            % - bigger than tspan
            tc.verifyError(@()tc.system.simulateStep([0 10],1,1,'hallo',2),'ODESCA_System:simulateStep:invalidSteptime','The method does not throw a correct error if the second step time is not given in the correct format.');
            tc.verifyError(@()tc.system.simulateStep([0 10],1,1,{5},2),'ODESCA_System:simulateStep:invalidSteptime','The method does not throw a correct error if the second step time is not given in the correct format.');
            tc.verifyError(@()tc.system.simulateStep([0 10],1,1,[5 5 5 5],2),'ODESCA_System:simulateStep:invalidSteptime','The method does not throw a correct error if the second step time is not given in the correct format.');
            tc.verifyError(@()tc.system.simulateStep([0 10],1,1,complex(5,5),2),'ODESCA_System:simulateStep:invalidSteptime','The method does not throw a correct error if the second step time is not given in the correct format.');
            tc.verifyError(@()tc.system.simulateStep([0 10],1,1,inf,2),'ODESCA_System:simulateStep:invalidSteptime','The method does not throw a correct error if the second step time is not given in the correct format.');
            tc.verifyError(@()tc.system.simulateStep([0 10],1,1,nan,2),'ODESCA_System:simulateStep:invalidSteptime','The method does not throw a correct error if the second step time is not given in the correct format.');
        

            % check if the correct error is thrown when the given input values
            % for the second step are invalid
            % - not numeric
            % - wrong dimension
            % - complex, infs, nans
            tc.verifyError(@()tc.system.simulateStep([0 10],1,1,5,'hallo'),'ODESCA_System:simulateStep:invalidSecondInput','The method does not throw a correct error if the input of the second steps are not given in the correct format.');
            tc.verifyError(@()tc.system.simulateStep([0 10],1,1,5,{5}),'ODESCA_System:simulateStep:invalidSecondInput','The method does not throw a correct error if the input of the second steps are not given in the correct format.');
            tc.verifyError(@()tc.system.simulateStep([0 10],1,1,5,[5 5 5 5]),'ODESCA_System:simulateStep:invalidSecondInput','The method does not throw a correct error if the input of the second steps are not given in the correct format.');
            tc.verifyError(@()tc.system.simulateStep([0 10],1,1,5,complex(5,5)),'ODESCA_System:simulateStep:invalidSecondInput','The method does not throw a correct error if the input of the second steps are not given in the correct format.');
            tc.verifyError(@()tc.system.simulateStep([0 10],1,1,5,inf),'ODESCA_System:simulateStep:invalidSecondInput','The method does not throw a correct error if the input of the second steps are not given in the correct format.');
            tc.verifyError(@()tc.system.simulateStep([0 10],1,1,5,nan),'ODESCA_System:simulateStep:invalidSecondInput','The method does not throw a correct error if the input of the second steps are not given in the correct format.');
        end
        
        % checks for simulateStep possible?
        
        
        
        % ---------- Checks for createSteadyState -------------------------
        
        function check_createSteadyState_error(tc)
            tc.resetSystem();
            tc.system = tc.getCommonSystem('WT',true);
            
            tc.verifyError(@()tc.system.createSteadyState(),'ODESCA_System:addSteadyState:wrongNumerOfInputArguments','The method does not throw a correct error if no input arguments are given.');
            tc.verifyError(@()tc.system.createSteadyState(1),'ODESCA_System:addSteadyState:wrongNumerOfInputArguments','The method does not throw a correct error if to less input arguments are given.');
            tc.verifyError(@()tc.system.createSteadyState(1,2,3,4),'MATLAB:TooManyInputs','The method does not throw a correct error if to much input arguments are given.');
            
            tc.verifyError(@()tc.system.createSteadyState([0 0 0], [0 0 0 0], 5),'ODESCA_System:addSteadyState:nameNotAString', 'The method does not throw a correct error if the given argument for the name is not a string.');
            tc.system.createSteadyState([0 0 0],[0 0 0 0],'SameName');
            tc.verifyError(@()tc.system.createSteadyState([0 0 0], [0 0 0 0], 'SameName'),'ODESCA_System:addSteadyState:nameAlreadyExist','The method does not throw a correct error if a steady state with the same name already exists.');
            
            tc.verifyError(@()tc.system.createSteadyState([0 0 0 0], [0 0 0 0]),'ODESCA_System:addSteadyState:wrongNumberOfStates','The method does not throw a correct error if the number of state values does not match the number of states in the system.');
            tc.verifyError(@()tc.system.createSteadyState([0 0 0], [0 0 0 0 0]),'ODESCA_System:addSteadyState:wrongNumberOfInputs','The method does not throw a correct error if the number of input values does not match the number of inputs in the system.');
            
            tc.resetSystem();
            tc.system = tc.getCommonSystem('WT',false);
            tc.verifyError(@()tc.system.createSteadyState([0 0 0],[0 0 0 0]),'ODESCA_System:createSteadyState:notAllParametersSet','The method does not throw a correct error if not all parameters are set to  numberic values.');
        end
        
        function check_createSteadyState(tc)
            % Add the first steady state
            tc.resetSystem();
            tc.system = tc.getCommonSystem('WT',true);
            warning('off','all');
            tc.system.createSteadyState([62.2579; 46.5408; 46.5408],[0.275; 75; 0.1; 12.5],'First');
            warning('on','all');    
            
            % Check if a steady state is added to the system
            tc.assertNotEmpty(tc.system.steadyStates, 'No steady state was added to the system.');
            ss = tc.system.steadyStates(1);
            tc.verifyEqual(tc.system, ss.system, 'The system was not added to the first steady state');
            
            % Check if the added steady state has the correct values
            tc.verifyEqual(ss.name,'First','The name of the first steady state was not saved correctly on creation.');
            tc.verifyEqual(ss.x0,[62.2579; 46.5408; 46.5408],'The values of the states of the first steady state where not saved correctly on creation.');
            tc.verifyEqual(ss.u0,[0.275; 75; 0.1; 12.5],'The values of the inputs of the first steady state where not saved correctly on creation.');
            tc.verifyEqual(ss.y0, [46.5408; 46.5408; 62.2579], 'The values of the outputs of the first steady state where not calculated correctly on creation.');
            tc.verifyEmpty(ss.approximations,'The property ''approximations'' was not empty after the creation of the steady state.');
            tc.verifyTrue(ss.structuralValid,'The first steady state was not marked as strucutral valid on creation.');
            tc.verifyEqual(ss.param,tc.system.param,'The parameters of the steady state have not been set to the parameters of the system.');

            % Add a second steady state
            warning('off','all');
            ss = tc.system.createSteadyState([53.786952085632410 40.835881747478204 40.835881557076700], [0.275 65 0.1 10],'Second');
            warning('on','all');
            
            % Check if second steady state is added and returned correctly
            tc.verifyEqual(class(ss),'ODESCA_SteadyState','The method does not return the correct class.');
            tc.verifyEqual(numel(tc.system.steadyStates),2,'The second steady state was not added correctly to the system.');
            tc.verifyEqual(tc.system, ss.system, 'The system was not added to the second steady state');
            
            % Check if the values of the second steady state are correct
            tc.verifyEqual(ss.name,'Second','The name of the second steady state was not saved correctly on creation.');
            tc.verifyEqual(rat(ss.x0),rat([53.786952085632410; 40.835881747478204; 40.835881557076700]),'The values of the states of the second steady state where not saved correctly on creation.');
            tc.verifyEqual(rat(ss.u0),rat([0.275; 65; 0.1; 10]),'The values of the inputs of the second steady state where not saved correctly on creation.');
            tc.verifyEqual(rat(ss.y0),rat([40.835881747478204; 40.835881557076700; 53.786952085632414]), 'The values of the outputs of the second steady state where not calculated correctly on creation.');  
            
        end
        
        % ---------- Checks for removeSteadyState -------------------------
        
        function check_removeSteadyState_error(tc)
            % Check behavior if no steady state is at the system
            tc.verifyWarning(@()tc.system.removeSteadyState(1),'ODESCA_System:removeSteadyState','The method does not throw a correct warning if there are no steady states in the system.')
            
            % Prepare the system
            tc.resetSystem();
            tc.system = tc.getCommonSystem('WT',true);
            warning('off','all');
            tc.system.createSteadyState([62.2579; 46.5408; 46.5408],[0.275; 75; 0.1; 12.5],'First');
            tc.system.createSteadyState([53.786952085632410 40.835881747478204 40.835881557076700], [0.275 65 0.1 10],'Second');
            warning('on','all');
            
            tc.verifyError(@()tc.system.removeSteadyState(0.5),'ODESCA_System:removeSteadyState:argumentInvalid','The method does not throw a correct error if an invalid input argument is given.');
            tc.verifyError(@()tc.system.removeSteadyState(3),'ODESCA_System:removeSteadyState:steadyStateNotFound','The method does not throw a correct error if the number given is higher than the number of steady states.');
            tc.verifyError(@()tc.system.removeSteadyState('Nope'),'ODESCA_System:removeSteadyState:steadyStateNotFound','The method does not throw a correct error if there is no steady state with the given name.');
        end
        
        function check_removeSteadyState(tc)
            % Prepare the system
            tc.resetSystem();
            tc.system = tc.getCommonSystem('WT',true);
            warning('off','all');
            ss1 = tc.system.createSteadyState([62.2579; 46.5408; 46.5408],[0.275; 75; 0.1; 12.5],'First');
            ss2 = tc.system.createSteadyState([53.786952085632410 40.835881747478204 40.835881557076700], [0.275 65 0.1 10],'Second');
            tc.system.createSteadyState([62.2579; 46.5408; 46.5408],[0.275; 75; 0.1; 12.5],'Third');
            warning('on','all');
            
            % Check if the steady state is removed correctly
            tc.system.removeSteadyState('Second');
            tc.assertEqual({tc.system.steadyStates.name},{'First','Third'},'The method does not remove the correct steady state while using a string as input argument.');
            tc.verifyFalse(isvalid(ss2),'The instance of the removed steady state was not deleted while using a string as input argument.');
            tc.system.removeSteadyState(1);
            tc.assertEqual(tc.system.steadyStates.name,'Third','The method does not remove the correct steady state while using an integer as input argument.');
            tc.verifyFalse(isvalid(ss1),'The instance of the removed steady state was not deleted while using an integer as input argument.');
            
            % Prepare the system
            tc.resetSystem();
            tc.system = tc.getCommonSystem('WT',true);
            warning('off','all');
            tc.system.createSteadyState([62.2579; 46.5408; 46.5408],[0.275; 75; 0.1; 12.5],'First');
            tc.system.createSteadyState([53.786952085632410 40.835881747478204 40.835881557076700], [0.275 65 0.1 10],'Second');
            tc.system.connectInput(1,sym(5));
            tc.system.createSteadyState([62.2579; 46.5408; 46.5408],[0.275; 75; 0.1],'Third');
            warning('on','all');
            
            % Check if the method removes the structural invalid steady
            % states correctly
            tc.assertEqual([tc.system.steadyStates.structuralValid], logical([0 0 1]),'Test aborted because of the first and second steady state are not marked as structural invalid.');
            tc.system.removeSteadyState();
            tc.assertEqual(tc.system.steadyStates.name,'Third','The invalid steady states where not removed correctly.');     
        end
        
        % ---------- Checks for delete ------------------------------------
        
        function check_delete(tc)
            % Prepare the system
            tc.resetSystem();
            tc.system = tc.getCommonSystem('WT',true);
            warning('off','all');
            ss1 = tc.system.createSteadyState([62.2579; 46.5408; 46.5408],[0.275; 75; 0.1; 12.5],'First');
            ss2 = tc.system.createSteadyState([53.786952085632410 40.835881747478204 40.835881557076700], [0.275 65 0.1 10],'Second');
            warning('on','all');
            
            % Delete the system
            tc.system.delete();
            tc.verifyFalse(isvalid(tc.system),'The system instance was not deleted correclty.');
            tc.verifyFalse(isvalid(ss1),'The first steady state of the system was not deleted correctly.');
            tc.verifyFalse(isvalid(ss2),'The second steady state of the system was not deleted correctly.');
        end
        
        % ---------- Checks for copy --------------------------------------
        
        % TODO
        
        
        % ---------- Checks for createControlAffinesystem -----------------
        
        function check_createControlAffineSystem(tc)
            
            tc.resetSystem();          
            
            % Check if the function creates the right answer for a known
            % system, one is allready control affine and one is not. 
            
            % Control affine
            CA = Test_controlaffine('CAComp');
            CASys = ODESCA_System('CASys',CA);
            [CASys_test, CAflag] = CASys.createControlAffineSystem;

            
            syms x1 x2 x3;
            syms u1 u2;
            
            f0 = [-x1 ; 0];
            f1 = [sin(x2) , x1*x2 ; x1^2 , 2];
            
            % Check if the answer is the same as above
            tc.verifyEqual(CASys_test.f0,f0,'The f0 function was not added to the system correctly.');
            tc.verifyEqual(CASys_test.f1,f1,'The f1 function was not added to the system correctly.');
            tc.verifyEqual(CAflag,0,'The apprxFlag was not correctly calculated.');
            
       
            % Not control affine
            NCA = Test_notcontrolaffine('NCAComp');
            NCASys = ODESCA_System('NCASys',NCA);
            [NCASys_test, NCAflag] = NCASys.createControlAffineSystem;
            
            f0 = [sin(x3) - x1 + x3^2 ; x1 + sin(x2) ; -1000*x3];
            f1 = [0 , 0 ; 0 , x2^2 ; 1000 , 0];
            
            % Check if the answer is the same as above
            tc.verifyEqual(NCASys_test.f0,f0,'The f0 function was not added to the system correctly.');
            tc.verifyEqual(NCASys_test.f1,f1,'The f1 function was not added to the system correctly.');
            tc.verifyEqual(NCAflag,1,'The apprxFlag was not correctly calculated.');
            
       end        
        
    end
    
    %######################################################################
    
    methods(Access = private)
        % Method to create an empty instance of the
        % ODESCA_System_Wrapper class
        function resetSystem(testCase)
            testCase.system = [];
            testCase.system = ODESCA_System();
        end
        
        % Method to create an heat exchanger example system
        function sys = getCommonSystem(testCase, name, withParamSet)
            sys = ODESCA_System();
            wt = Test_ODESCA_System_CompCommonWT(name);
            if(withParamSet)
                wt.setParam('c',4200);
                wt.setParam('rho',1000);
                wt.setParam('k',10000);
                wt.setParam('A',0.1);
                wt.setParam('V_store',0.0003);
                wt.setParam('V_dhw',0.0003);
                wt.setParam('tau',1.8);
            end
            sys.addComponent(wt);
        end
    end
    
end

