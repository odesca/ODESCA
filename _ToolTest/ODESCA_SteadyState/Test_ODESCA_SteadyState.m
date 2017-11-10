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

classdef Test_ODESCA_SteadyState < matlab.unittest.TestCase
    %ODESCA_SteadyState_Test Class to test ODESCA_SteadyState
    %
    % DESCRIPTION
    %   This class tests the class ODESCA_SteadyState for the correct 
    %   working of all methods and properties.
    %
    % ODESCA_SteadyState_Test
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
        steadystate
        systemWT
        steadystateWT
        systemSimple
        steadystateSimple
    end
    
    % Method to create new ODESCA_SteadyState for every test method
    methods(TestMethodSetup)
        function createTestSteadyState(testCase)
            warning('off','all');
            testCase.system = ODESCA_System();
            testCase.steadystate = testCase.system.createSteadyState([],[],'steadystate');
            warning('on','all');
            wt = Test_ODESCA_SteadyState_CompCommonWT('WT');
            wt.setParam('c',4200); 
            wt.setParam('rho',1000); 
            wt.setParam('k',10000); 
            wt.setParam('A',0.1);
            wt.setParam('V_store',0.0003); 
            wt.setParam('V_dhw',0.0003);
            wt.setParam('tau',1.8);
            testCase.systemWT = ODESCA_System('SystemWT',wt);
            testCase.steadystateWT = testCase.systemWT.createSteadyState([62.257900097209230;47.540774712899704;47.540774491808264],[0.275,75,0.1,12.5],'steadystateWT');            
            simpleTest = TestSimple('SimpleTest');           
            testCase.systemSimple = ODESCA_System('SimpleSystem',simpleTest);
            testCase.steadystateSimple = testCase.systemSimple.createSteadyState(0,0,'steadystateSimple');            
        end
    end
    
    % Method to remove instance of the ODESCA_SteadyState which was tested
    methods(TestMethodTeardown)
        function removeTestSteadyState(testCase)
            testCase.steadystate = [];
            testCase.steadystateWT = [];
            testCase.steadystateSimple = [];
        end
    end
    
    methods(Test)
        % ---------- checks for the object itself -------------------------
        
        % Check if the properties can not be set public
        function check_PropertiesSetProhibited(testCase)
            % Create list of all parameters and the diagnostic displayed if
            % the set access is not prohibited and does not throw an error
            nameList = {...
                'name';
                'x0';
                'u0';
                'y0';
                'approximations';
                'system';
                'param';
                'structuralValid';
                'numericValid';                
                };
            
            % Check the fields
            for num = 1:size(nameList,1)
                result = 'No Error';
                name = nameList{num};
                try
                    testCase.steadystate.(name) = 1;
                catch err
                    result = err.identifier;
                end
                testCase.verifyEqual(result,'MATLAB:class:SetProhibited',['The public set access for the property ''',name,''' is not prohibited.']);
            end
        end
        
        
        
        % Check if the particular methods have the correct access
        function check_MethodAccessProhibited(testCase)
            warning('off','all');
            system2 = ODESCA_System();
            warning('on','all');
            testCase.verifyError(@()testCase.steadystate.copy(testCase.steadystate,system2), 'MATLAB:class:MethodRestricted', 'The method ''copy'' of the class ''ODESCA_SteadyState'' doesn''t have a restricted access.');
            testCase.verifyError(@()testCase.steadystate.removeApproximationFromList(1), 'MATLAB:class:MethodRestricted', 'The method ''removeApproximationFromList'' of the class ''ODESCA_SteadyState'' doesn''t have a restricted access.');            
        end
      
        % Check if the constructor of the class is restricted
        function check_Constructor_Prohibited(testCase)           
           testCase.verifyError(@ODESCA_SteadyState,'MATLAB:class:MethodRestricted', 'The constructor of the class ''ODESCA_SteadyState'' is not restricted.');
        end
        
        % ---------- Checks for setName -----------------------------------
        
        function check_setName(testCase)
            % Check the errors
            warning('off','all');
            steadystate2 = testCase.system.createSteadyState([],[],'steadystate2');
            warning('on','all');
            steadystatearray = [testCase.steadystate;steadystate2];
            testCase.verifyError(@()steadystatearray.setName('Name'),'ODESCA_SteadyState:setName:tooManyObjects', 'The method does not throw a correct error if it is called for more than one object.');
            testCase.verifyError(@()testCase.steadystate.setName(1),'ODESCA_SteadyState:setName:nameNotAString', 'The method does not throw a correct error if the name is not a string but numerical.');
            testCase.verifyError(@()testCase.steadystate.setName({'Name'}),'ODESCA_SteadyState:setName:nameNotAString', 'The method does not throw a correct error if the name is not a string but cell.');
            testCase.verifyError(@()testCase.steadystate.setName(string({'name1','name2'})),'ODESCA_SteadyState:setName:nameNotAString', 'The method does not throw a correct error if the name is not one string.');
            testCase.verifyError(@()testCase.steadystate.setName(strings),'ODESCA_SteadyState:setName:nameNotAString', 'The method does not throw a correct error if the name is an empty string.');
            testCase.verifyError(@()testCase.steadystate.setName([]),'ODESCA_SteadyState:setName:nameNotAString', 'The method does not throw a correct error if the name is not a string but empty.');
            testCase.verifyError(@()testCase.steadystate.setName(false),'ODESCA_SteadyState:setName:nameNotAString', 'The method does not throw a correct error if the name is not a string but logical.');
            warning('off','all');
            testCase.system.createSteadyState([],[],'Name2');
            warning('on','all');
            testCase.verifyError(@()testCase.steadystate.setName('Name2'),'ODESCA_SteadyState:setName:nameAlreadyInSystem', 'The method does not throw a correct error if there is another steady state in the system which has the same name.');
            
            % Check working
            testCase.steadystate.setName('Steady1');
            testCase.verifyEqual(testCase.steadystate.name,'Steady1','The method does not set the name correctly.');
        end        
        
        % ---------- Checks for isNumericValid ----------------------------
        
        function check_isNumericValid(testCase)
            % Check the errors
            testCase.verifyError(@()testCase.steadystate.isNumericValid([0.1 0.2]),'ODESCA_SteadyState:isValidSteadyState:maximumVarianceNotAScalarNumericValue', 'The method does not throw a correct error if the maximal variance given is not a scalar numeric value.');
            testCase.verifyError(@()testCase.steadystate.isNumericValid('c'),'ODESCA_SteadyState:isValidSteadyState:maximumVarianceNotAScalarNumericValue', 'The method does not throw a correct error if the maximal variance given is not numeric but char.');
            testCase.verifyError(@()testCase.steadystate.isNumericValid({5}),'ODESCA_SteadyState:isValidSteadyState:maximumVarianceNotAScalarNumericValue', 'The method does not throw a correct error if the maximal variance given is not numeric but cell.');
            testCase.verifyError(@()testCase.steadystate.isNumericValid(true),'ODESCA_SteadyState:isValidSteadyState:maximumVarianceNotAScalarNumericValue', 'The method does not throw a correct error if the maximal variance given is not numeric but logical.');
            testCase.verifyError(@()testCase.steadystate.isNumericValid([]),'ODESCA_SteadyState:isValidSteadyState:maximumVarianceNotAScalarNumericValue', 'The method does not throw a correct error if the maximal variance given is empty.');
            
            % Check working
            s = testCase.steadystate.isNumericValid();
            testCase.verifyEqual(s,0,'The method does not validate correctly (false).');
            s = testCase.steadystateWT.isNumericValid(0.01);
            testCase.verifyEqual(s,1,'The method does not validate correctly (true).');
            [s,t] = testCase.steadystateSimple.isNumericValid();
            testCase.verifyEqual(s,1,'The method does not validate correctly.');
            testCase.verifyEqual(t,0,'The method does not compute the right maximal difference.');
            s = testCase.steadystateWT.isNumericValid(0.00000000001);
            testCase.verifyEqual(s,0,'The method does not validate correctly (given Variance).');           
        end
        
        % ---------- Checks for delete ------------------------------------
        
        function check_delete(testCase)
            sst = testCase.steadystate;
            sst.delete();
            testCase.verifyFalse(isvalid(sst),'The steady state was not deleted correctly.');
            sstWT = testCase.steadystateWT;
            linWT = sstWT.linearize();
            sstWT.delete();
            testCase.verifyFalse(isvalid(sstWT),'The steady state (WT) was not deleted correctly.');
            testCase.verifyFalse(isvalid(linWT),'The approximation of the steady state was not deleted correctly.');            
        end
        
        % ---------- Checks for copy --------------------------------------
        
        %function check_copy(testCase)
                        
        %end
        
        % ---------- Checks for linearize ---------------------------------
        
        function check_linearize(testCase)
            % Check the warnings
            testCase.systemWT.switchInputs('WT_mdot_store','WT_mdot_dhw');
            testCase.verifyWarning(@()testCase.steadystateWT.linearize(), 'ODESCA_SteadyState:linearize:structuralInvalid', 'The method ''linearize'' of the class ''ODESCA_SteadyState'' does now throw a correct warning if the steady state is structural invalid.');
            testCase.verifyWarning(@()testCase.steadystate.linearize(), 'ODESCA_SteadyState:linearize:steadyStateInvalid', 'The method ''linearize'' of the class ''ODESCA_SteadyState'' does now throw a correct warning if the steady state is numerical invalid.');            
            
            % Check working
            linSimple = testCase.steadystateSimple.linearize();
            testCase.verifyEqual(linSimple.A,1,'The method does not linearize correctly (A).');
            testCase.verifyEqual(linSimple.B,1,'The method does not linearize correctly (B).');
            testCase.verifyEqual(linSimple.C,1,'The method does not linearize correctly (C).');
            testCase.verifyEqual(linSimple.D,1,'The method does not linearize correctly (D).');
            
            % Create steady states from example components for more working
            % testing
            S0I0O1P0CP0 = Test_ODESCA_SteadyState_CompS0I0O1P0CP0('S0I0O1P0CP0');
            S0I1O1P1CP0 = Test_ODESCA_SteadyState_CompS0I1O1P1CP0('S0I1O1P1CP0');
            S1I0O1P1CP0 = Test_ODESCA_SteadyState_CompS1I0O1P1CP0('S1I0O1P1CP0');
            S1I1O1P1CP0 = Test_ODESCA_SteadyState_CompS1I1O1P1CP0('S1I1O1P1CP0');
            S1I1O1P1CP1 = Test_ODESCA_SteadyState_CompS1I1O1P1CP1('S1I1O1P1CP1');            
            S1I1O1P1CP1.setConstructionParam('c',2);
            S1I1O1P1CP1.tryCalculateEquations;
            S0I1O1P1CP0.setParam('Parameter',5);
            S1I0O1P1CP0.setParam('Parameter',5);
            S1I1O1P1CP0.setParam('Parameter',5);
            S1I1O1P1CP1.setParam('Parameter',5);
            systemS0I0O1P0CP0 = ODESCA_System('SystemS0I0O1P0CP0',S0I0O1P0CP0);
            systemS0I1O1P1CP0 = ODESCA_System('SystemS0I1O1P1CP0',S0I1O1P1CP0);
            systemS1I0O1P1CP0 = ODESCA_System('SystemS1I0O1P1CP0',S1I0O1P1CP0);
            systemS1I1O1P1CP0 = ODESCA_System('SystemS1I1O1P1CP0',S1I1O1P1CP0);
            systemS1I1O1P1CP1 = ODESCA_System('SystemS1I1O1P1CP1',S1I1O1P1CP1);
            warning('off','all');
            steadystateS0I0O1P0CP0 = systemS0I0O1P0CP0.createSteadyState([],[],'steadystateS0I0O1P0CP0');
            steadystateS0I1O1P1CP0 = systemS0I1O1P1CP0.createSteadyState([],-5,'steadystateS0I1O1P1CP0');
            steadystateS1I0O1P1CP0 = systemS1I0O1P1CP0.createSteadyState(5,[],'steadystateS1I0O1P1CP0');
            steadystateS1I1O1P1CP0 = systemS1I1O1P1CP0.createSteadyState(0,0,'steadystateS1I1O1P1CP0');
            steadystateS1I1O1P1CP1 = systemS1I1O1P1CP1.createSteadyState(0,0,'steadystateS1I1O1P1CP1');
                        
            %linS0I0O1P0CP0 = steadystateS0I0O1P0CP0.linearize();  %ERROR
            %testCase.verifyEqual(linS0I0O1P0CP0.A,[],'The method does not linearize correctly (A S0I0O1P0CP0).');
            %testCase.verifyEqual(linS0I0O1P0CP0.B,[],'The method does not linearize correctly (B S0I0O1P0CP0).');
            %testCase.verifyEqual(linS0I0O1P0CP0.C,[],'The method does not linearize correctly (C S0I0O1P0CP0).');
            %testCase.verifyEqual(linS0I0O1P0CP0.D,[],'The method does not linearize correctly (D S0I0O1P0CP0).');
            
            linS0I1O1P1CP0 = steadystateS0I1O1P1CP0.linearize();
            testCase.verifyEqual(linS0I1O1P1CP0.A,[],'The method does not linearize correctly (A S0I1O1P1CP0).');
            testCase.verifyEqual(linS0I1O1P1CP0.B,[],'The method does not linearize correctly (B S0I1O1P1CP0).');
            testCase.verifyEqual(linS0I1O1P1CP0.C,[],'The method does not linearize correctly (C S0I1O1P1CP0).');
            testCase.verifyEqual(linS0I1O1P1CP0.D,1,'The method does not linearize correctly (D S0I1O1P1CP0).');
            
            linS1I0O1P1CP0 = steadystateS1I0O1P1CP0.linearize();
            testCase.verifyEqual(linS1I0O1P1CP0.A,-1,'The method does not linearize correctly (A S1I0O1P1CP0).');
            testCase.verifyEqual(linS1I0O1P1CP0.B,[],'The method does not linearize correctly (B S1I0O1P1CP0).');
            testCase.verifyEqual(linS1I0O1P1CP0.C,0,'The method does not linearize correctly (C S1I0O1P1CP0).');
            testCase.verifyEqual(linS1I0O1P1CP0.D,[],'The method does not linearize correctly (D S1I0O1P1CP0).');
            
            linS1I1O1P1CP0 = steadystateS1I1O1P1CP0.linearize();
            testCase.verifyEqual(linS1I1O1P1CP0.A,-1,'The method does not linearize correctly (A S1I1O1P1CP0).');
            testCase.verifyEqual(linS1I1O1P1CP0.B,5,'The method does not linearize correctly (B S1I1O1P1CP0).');
            testCase.verifyEqual(linS1I1O1P1CP0.C,1,'The method does not linearize correctly (C S1I1O1P1CP0).');
            testCase.verifyEqual(linS1I1O1P1CP0.D,1,'The method does not linearize correctly (D S1I1O1P1CP0).');
            
            linS1I1O1P1CP1 = steadystateS1I1O1P1CP1.linearize();
            testCase.verifyEqual(linS1I1O1P1CP1.A,-1,'The method does not linearize correctly (A S1I1O1P1CP1).');
            testCase.verifyEqual(linS1I1O1P1CP1.B,5,'The method does not linearize correctly (B S1I1O1P1CP1).');
            testCase.verifyEqual(linS1I1O1P1CP1.C,0,'The method does not linearize correctly (C S1I1O1P1CP1).');
            testCase.verifyEqual(linS1I1O1P1CP1.D,0,'The method does not linearize correctly (D S1I1O1P1CP1).'); 
                        
            nosteadystateS1I1O1P1CP1 = systemS1I1O1P1CP1.createSteadyState(2,5,'nosteadystateS1I1O1P1CP1');
            nolinS1I1O1P1CP1 = nosteadystateS1I1O1P1CP1.linearize();
            testCase.verifyEqual(nolinS1I1O1P1CP1.A,-1,'The method does not linearize correctly (A noS1I1O1P1CP1).');
            testCase.verifyEqual(nolinS1I1O1P1CP1.B,5,'The method does not linearize correctly (B noS1I1O1P1CP1).');
            testCase.verifyEqual(nolinS1I1O1P1CP1.C,40,'The method does not linearize correctly (C noS1I1O1P1CP1).');
            testCase.verifyEqual(nolinS1I1O1P1CP1.D,4,'The method does not linearize correctly (D noS1I1O1P1CP1).');
            warning('on','all'); 
        end
        
        % ---------- Checks for linear ------------------------------------
        
        function check_linear(testCase)
            % Check the errors and warnings
            testCase.verifyError(@()testCase.steadystate.linear(3:5),'ODESCA_SteadyState:linear:invalidIndex', 'The method does not throw a correct error if the index is not valid (Range).');
            testCase.verifyError(@()testCase.steadystate.linear(inf),'ODESCA_SteadyState:linear:invalidIndex', 'The method does not throw a correct error if the index is not valid (Inf).');
            testCase.verifyError(@()testCase.steadystate.linear(nan),'ODESCA_SteadyState:linear:invalidIndex', 'The method does not throw a correct error if the index is not valid (NaN).');
            testCase.verifyError(@()testCase.steadystate.linear(1.5),'ODESCA_SteadyState:linear:invalidIndex', 'The method does not throw a correct error if the index is not valid (~Integer).');
            testCase.verifyError(@()testCase.steadystate.linear(-1),'ODESCA_SteadyState:linear:invalidIndex', 'The method does not throw a correct error if the index is not valid (negative).');
            testCase.verifyError(@()testCase.steadystate.linear('a'),'ODESCA_SteadyState:linear:invalidIndex', 'The method does not throw a correct error if the index is not valid (char).');            
            testCase.verifyWarning(@()testCase.steadystate.linear(), 'ODESCA_SteadyState:linear:notAllLinearized', 'The method ''linear'' of the class ''ODESCA_SteadyState'' does now throw a correct warning if there is a steady state without linearization.');
            steadystatearray = [testCase.steadystateWT, testCase.steadystateSimple];
            steadystatearray.linearize();
            steadystatearray = [testCase.steadystate, testCase.steadystateWT, testCase.steadystateSimple];
            testCase.verifyWarning(@()steadystatearray.linear(), 'ODESCA_SteadyState:linear:notAllLinearized', 'The method ''linear'' of the class ''ODESCA_SteadyState'' does now throw a correct warning if there is a steady state without linearization in an array.');
            
            % Check working with additional linearizations
            S1I1O1P1CP0 = Test_ODESCA_SteadyState_CompS1I1O1P1CP0('S1I1O1P1CP0');
            S1I1O1P1CP1 = Test_ODESCA_SteadyState_CompS1I1O1P1CP1('S1I1O1P1CP1');            
            S1I1O1P1CP0.setParam('Parameter',5);
            S1I1O1P1CP1.setConstructionParam('c',2);
            S1I1O1P1CP1.tryCalculateEquations;
            S1I1O1P1CP1.setParam('Parameter',5);
            systemS1I1O1P1CP0 = ODESCA_System('SimpleSystem',S1I1O1P1CP0);            
            systemS1I1O1P1CP1 = ODESCA_System('SimpleSystem',S1I1O1P1CP1);
            steadystateS1I1O1P1CP0 = systemS1I1O1P1CP0.createSteadyState(0,0,'steadystateS1I1O1P1CP0');
            steadystateS1I1O1P1CP1 = systemS1I1O1P1CP1.createSteadyState(0,0,'steadystateS1I1O1P1CP1');
            
            steadystatearray = [steadystatearray, steadystateS1I1O1P1CP0, steadystateS1I1O1P1CP1];
            warning('off','all');
            steadystatearray.linearize();            
            linList = steadystatearray.linear();
            warning('on','all');
            testCase.verifyEqual(linList(1,1).steadyState.name,'steadystate', 'The method does not take the right linearization from the array.');
            testCase.verifyEqual(linList(2,1).steadyState.name,'steadystateWT', 'The method does not take the right linearization from the array (WT).');
            testCase.verifyEqual(linList(3,1).steadyState.name,'steadystateSimple', 'The method does not take the right linearization from the array (simple).');
            testCase.verifyEqual(linList(4,1).steadyState.name,'steadystateS1I1O1P1CP0', 'The method does not take the right linearization from the array (S1I1O1P1CP0).');
            testCase.verifyEqual(linList(5,1).steadyState.name,'steadystateS1I1O1P1CP1', 'The method does not take the right linearization from the array (S1I1O1P1CP1).');
            
            linVier = steadystatearray.linear(4);
            testCase.verifyEqual(linVier.steadyState.name,'steadystateS1I1O1P1CP0', 'The method does not take the right linearization (4) from the array (S1I1O1P1CP0).');
            
            linDreiVier = steadystatearray.linear(3:4);
            testCase.verifyEqual(linDreiVier(1).steadyState.name,'steadystateSimple', 'The method does not take the right linearization (3-4) from the array (Simple).');
            testCase.verifyEqual(linDreiVier(2).steadyState.name,'steadystateS1I1O1P1CP0', 'The method does not take the right linearization (3-4) from the array (S1I1O1P1CP0).');
        end       
    end
end

