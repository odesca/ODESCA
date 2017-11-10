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

classdef Test_ODESCA_Linear < matlab.unittest.TestCase
    %ODESCA_Linear_Test Class to test ODESCA_SteadyState
    %
    % DESCRIPTION
    %   This class tests the class ODESCA_Linear for the correct 
    %   working of all methods and properties.
    %
    % ODESCA_Linear_Test
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
        S1I1O1P1CP0
        S1I0O1P1CP0
        systemS1I1O1P1CP0
        systemS1I0O1P1CP0
        steadystateS1I1O1P1CP0
        steadystateS1I0O1P1CP0
        approximationS1I1O1P1CP0
        approximationS1I0O1P1CP0
        linearS1I1O1P1CP0
        linearS1I0O1P1CP0
    end
    
    % Method to create new ODESCA_Linear for every test method
    methods(TestMethodSetup)
        function createTestLinear(testCase)
            warning('off','all');
            testCase.S1I1O1P1CP0 = Test_ODESCA_Linear_CompS1I1O1P1CP0('S1I1O1P1CP0');
            testCase.S1I0O1P1CP0 = Test_ODESCA_Linear_CompS1I0O1P1CP0('S1I0O1P1CP0');
            testCase.S1I1O1P1CP0.setParam('Parameter',5);
            testCase.S1I0O1P1CP0.setParam('Parameter',5);
            testCase.systemS1I1O1P1CP0 = ODESCA_System('SystemS1I1O1P1CP0',testCase.S1I1O1P1CP0);
            testCase.systemS1I0O1P1CP0 = ODESCA_System('SystemS1I0O1P1CP0',testCase.S1I0O1P1CP0);
            testCase.steadystateS1I1O1P1CP0 = testCase.systemS1I1O1P1CP0.createSteadyState(0,0,'steadystateS1I1O1P1CP0');
            testCase.steadystateS1I0O1P1CP0 = testCase.systemS1I0O1P1CP0.createSteadyState(5,[],'steadystateS1I0O1P1CP0');
            testCase.linearS1I1O1P1CP0 = testCase.steadystateS1I1O1P1CP0.linearize();
            testCase.linearS1I0O1P1CP0 = testCase.steadystateS1I0O1P1CP0.linearize();
            warning('on','all');
        end
    end
    
    % Method to remove instance of the ODESCA_Linear which was tested
    methods(TestMethodTeardown)
        function removeTestSteadyState(testCase)
            testCase.linearS1I1O1P1CP0 = [];
            testCase.linearS1I0O1P1CP0 = [];
        end
    end
    
    methods(Test)
        % ---------- Checks for the object itself -------------------------
        
        % Check if the properties can not be set public
        function check_PropertiesSetProhibited(testCase)
            % Create list of all parameters and the diagnostic displayed if
            % the set access is not prohibited and does not throw an error
            nameList = {...
                'A';
                'B';
                'C';
                'D';
                'Ad';
                'Bd';
                'discreteSampleTime';
                'ss';                
                };
            
            % Check the fields
            for num = 1:size(nameList,1)
                result = 'No Error';
                name = nameList{num};
                try
                    testCase.linearS1I1O1P1CP0.(name) = 1;
                catch err
                    result = err.identifier;
                end
                testCase.verifyEqual(result,'MATLAB:class:SetProhibited',['The public set access for the property ''',name,''' is not prohibited.']);
            end
        end
        
        % Check for the dependent property
        function check_DependentProperty(testCase)
            try
                testCase.linearS1I1O1P1CP0.tf = 1;
            catch err
                result = err.identifier;
            end
            testCase.verifyEqual(result,'MATLAB:class:noSetMethod', 'The public access for the dependent property ''tf'' is not prohibited.');
        end
        
        
        % Check if the particular methods have the correct access
        function check_MethodAccessProhibited(testCase)
            warning('off','all');
            system2 = ODESCA_System();
            steadystate2 = system2.createSteadyState([],[],'steadystate');            
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.copyElement(testCase.linear,steadystate2), 'MATLAB:class:MethodRestricted', 'The method ''copyElement'' of the class ''ODESCA_Linear'' doesn''t have a restricted access.');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.deleteElement(), 'MATLAB:class:MethodRestricted', 'The method ''deleteElement'' of the class ''ODESCA_Linear'' doesn''t have a restricted access.');
            warning('on','all');
        end
      
        % Check if the constructor of the class is restricted
        function check_Constructor_Prohibited(testCase)           
           testCase.verifyError(@ODESCA_Linear,'MATLAB:class:MethodRestricted', 'The constructor of the class ''ODESCA_Linear'' is not restricted.');
        end
                
        
        % ---------- Checks for bodeplot ----------------------------------
        
        function check_bodeplot(testCase)
            % Suppress figure
            set(0,'DefaultFigureVisible','off');
            
            % Check the errors                     
            linearArray = [testCase.linearS1I1O1P1CP0, testCase.linearS1I0O1P1CP0];                
            testCase.verifyError(@()linearArray.bodeplot(),'ODESCA_Linear:plotBode:dimensionMismatch', 'The method does not throw a correct error if the linearizations have different dimensions.');
            
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.bodeplot('Hallo'),'ODESCA_Linear:bodeplot:oddNumberOfInputArguments', 'The method does not throw a correct error if the number of arguments is not even.');
            
            testCase.verifyWarning(@()testCase.linearS1I1O1P1CP0.bodeplot(5,42), 'ODESCA_Linear:bodeplot:optionNotAString', 'The method ''bodeplot'' of the class ''ODESCA_Linear'' does now throw a correct warning if the given option is not a scalar string (double).');
            testCase.verifyWarning(@()testCase.linearS1I1O1P1CP0.bodeplot({'Hallo'},5), 'ODESCA_Linear:bodeplot:optionNotAString', 'The method ''bodeplot'' of the class ''ODESCA_Linear'' does now throw a correct warning if the given option is not a scalar string (cell).');            
            
            testCase.verifyWarning(@()testCase.linearS1I1O1P1CP0.bodeplot('bodeoptions','Hallo'), 'ODESCA_Linear:bodeplot:bodeOptionsNotCorrect', 'The method ''bodeplot'' of the class ''ODESCA_Linear'' does now throw a correct warning if the input for ''bodeoptions'' is not valid.');
            testCase.verifyWarning(@()testCase.linearS1I1O1P1CP0.bodeplot('bodeoptions',42), 'ODESCA_Linear:bodeplot:bodeOptionsNotCorrect', 'The method ''bodeplot'' of the class ''ODESCA_Linear'' does now throw a correct warning if the input for ''bodeoptions'' is not valid (numeric).');
            
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.bodeplot('from','Hallo'),'ODESCA_Linear:bodeplot:invalidInputOption', 'The method does not throw a correct error if the value for ''from'' is not an integer array (string).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.bodeplot('from',[1,2,3.5]),'ODESCA_Linear:bodeplot:invalidInputOption', 'The method does not throw a correct error if the value for ''from'' is not an integer array (double array).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.bodeplot('from',0.0001),'ODESCA_Linear:bodeplot:invalidInputOption', 'The method does not throw a correct error if the value for ''from'' is not an integer array (double).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.bodeplot('from',{1,2,3}),'ODESCA_Linear:bodeplot:invalidInputOption', 'The method does not throw a correct error if the value for ''from'' is not an integer array (cell array).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.bodeplot('from',1:0.5:10),'ODESCA_Linear:bodeplot:invalidInputOption', 'The method does not throw a correct error if the value for ''from'' is not an integer array (1:0.5:10).');            
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.bodeplot('from',logical([1,2,3])),'ODESCA_Linear:bodeplot:invalidInputOption', 'The method does not throw a correct error if the value for ''from'' is not an integer array (logical).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.bodeplot('from',nan),'ODESCA_Linear:bodeplot:invalidInputOption', 'The method does not throw a correct error if the value for ''from'' is not an integer array (NaN).');
            
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.bodeplot('from',-1),'ODESCA_Linear:bodeplot:invalidInputOption', 'The method does not throw a correct error if the entries for ''from'' are not in the range of inputs (negative).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.bodeplot('from',1:1000),'ODESCA_Linear:bodeplot:invalidInputOption', 'The method does not throw a correct error if the entries for ''from'' are not in the range of inputs (1000).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.bodeplot('from',-1:1),'ODESCA_Linear:bodeplot:invalidInputOption', 'The method does not throw a correct error if the entries for ''from'' are not in the range of inputs (-1).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.bodeplot('from',42),'ODESCA_Linear:bodeplot:invalidInputOption', 'The method does not throw a correct error if the entries for ''from'' are not in the range of inputs (42).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.bodeplot('from',inf),'ODESCA_Linear:bodeplot:invalidInputOption', 'The method does not throw a correct error if the entries for ''from'' are not in the range of inputs (Inf).');
            
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.bodeplot('to','Hallo'),'ODESCA_Linear:bodeplot:invalidOutputOption', 'The method does not throw a correct error if the value for ''to'' is not an integer array (string).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.bodeplot('to',[1,2,3.5]),'ODESCA_Linear:bodeplot:invalidOutputOption', 'The method does not throw a correct error if the value for ''to'' is not an integer array (double array).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.bodeplot('to',0.0001),'ODESCA_Linear:bodeplot:invalidOutputOption', 'The method does not throw a correct error if the value for ''to'' is not an integer array (double).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.bodeplot('to',{1,2,3}),'ODESCA_Linear:bodeplot:invalidOutputOption', 'The method does not throw a correct error if the value for ''to'' is not an integer array (cell array).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.bodeplot('to',1:0.5:10),'ODESCA_Linear:bodeplot:invalidOutputOption', 'The method does not throw a correct error if the value for ''to'' is not an integer array (1:0.5:10).');            
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.bodeplot('to',logical([1,2,3])),'ODESCA_Linear:bodeplot:invalidOutputOption', 'The method does not throw a correct error if the value for ''to'' is not an integer array (logical).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.bodeplot('to',nan),'ODESCA_Linear:bodeplot:invalidOutputOption', 'The method does not throw a correct error if the value for ''to'' is not an integer array (NaN).');
            
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.bodeplot('to',-1),'ODESCA_Linear:bodeplot:invalidOutputOption', 'The method does not throw a correct error if the entries for ''to'' are not in the range of inputs (negative).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.bodeplot('to',1:1000),'ODESCA_Linear:bodeplot:invalidOutputOption', 'The method does not throw a correct error if the entries for ''to'' are not in the range of inputs (1000).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.bodeplot('to',-1:1),'ODESCA_Linear:bodeplot:invalidOutputOption', 'The method does not throw a correct error if the entries for ''to'' are not in the range of inputs (-1).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.bodeplot('to',42),'ODESCA_Linear:bodeplot:invalidOutputOption', 'The method does not throw a correct error if the entries for ''to'' are not in the range of inputs (42).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.bodeplot('to',inf),'ODESCA_Linear:bodeplot:invalidOutputOption', 'The method does not throw a correct error if the entries for ''to'' are not in the range of inputs (Inf).');
            
            testCase.verifyWarning(@()testCase.linearS1I1O1P1CP0.bodeplot('option',5), 'ODESCA_Linear:bodeplot:invalidInputOption', 'The method ''bodeplot'' of the class ''ODESCA_Linear'' does now throw a correct warning if the given option does not exist.');
            testCase.verifyWarning(@()testCase.linearS1I1O1P1CP0.bodeplot('bodeoption',5), 'ODESCA_Linear:bodeplot:invalidInputOption', 'The method ''bodeplot'' of the class ''ODESCA_Linear'' does now throw a correct warning if the given option does not exist (''bodeoption'').');
            testCase.verifyWarning(@()testCase.linearS1I1O1P1CP0.bodeplot('nyquistoptions',5), 'ODESCA_Linear:bodeplot:invalidInputOption', 'The method ''bodeplot'' of the class ''ODESCA_Linear'' does now throw a correct warning if the given option does not exist (''nyquistoptions'').');
            testCase.verifyWarning(@()testCase.linearS1I1O1P1CP0.bodeplot('timeoptions',5), 'ODESCA_Linear:bodeplot:invalidInputOption', 'The method ''bodeplot'' of the class ''ODESCA_Linear'' does now throw a correct warning if the given option does not exist (''timeoptions'').');
            
            % Check working
            
        end
        
        % ---------- Checks for nyquistplot -------------------------------
        
        function check_nyquistplot(testCase)
            % Suppress figure
            set(0,'DefaultFigureVisible','off');
            
            % Check the errors
            linearArray = [testCase.linearS1I1O1P1CP0, testCase.linearS1I0O1P1CP0];
            testCase.verifyError(@()linearArray.nyquistplot(),'ODESCA_Linear:nyquistplot:dimensionMismatch', 'The method does not throw a correct error if the linearizations have different dimensions.');
            
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.nyquistplot('Hallo'),'ODESCA_Linear:nyquistplot:oddNumberOfInputArguments', 'The method does not throw a correct error if the number of arguments is not even.');
            
            testCase.verifyWarning(@()testCase.linearS1I1O1P1CP0.nyquistplot(5,42), 'ODESCA_Linear:nyquistplot:optionNotAString', 'The method ''nyquistplot'' of the class ''ODESCA_Linear'' does now throw a correct warning if the given option is not a scalar string (double).');
            testCase.verifyWarning(@()testCase.linearS1I1O1P1CP0.nyquistplot({'Hallo'},5), 'ODESCA_Linear:nyquistplot:optionNotAString', 'The method ''nyquistplot'' of the class ''ODESCA_Linear'' does now throw a correct warning if the given option is not a scalar string (cell).');            
            
            testCase.verifyWarning(@()testCase.linearS1I1O1P1CP0.nyquistplot('nyquistoptions','Hallo'), 'ODESCA_Linear:nyquistplot:nyquistOptionsNotCorrect', 'The method ''nyquistplot'' of the class ''ODESCA_Linear'' does now throw a correct warning if the input for ''nyquistoptions'' is not valid.');
            testCase.verifyWarning(@()testCase.linearS1I1O1P1CP0.nyquistplot('nyquistoptions',42), 'ODESCA_Linear:nyquistplot:nyquistOptionsNotCorrect', 'The method ''nyquistplot'' of the class ''ODESCA_Linear'' does now throw a correct warning if the input for ''nyquistoptions'' is not valid (numeric).');
            
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.nyquistplot('from','Hallo'),'ODESCA_Linear:nyquistplot:invalidInputOption', 'The method does not throw a correct error if the value for ''from'' is not an integer array (string).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.nyquistplot('from',[1,2,3.5]),'ODESCA_Linear:nyquistplot:invalidInputOption', 'The method does not throw a correct error if the value for ''from'' is not an integer array (double array).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.nyquistplot('from',0.0001),'ODESCA_Linear:nyquistplot:invalidInputOption', 'The method does not throw a correct error if the value for ''from'' is not an integer array (double).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.nyquistplot('from',{1,2,3}),'ODESCA_Linear:nyquistplot:invalidInputOption', 'The method does not throw a correct error if the value for ''from'' is not an integer array (cell array).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.nyquistplot('from',1:0.5:10),'ODESCA_Linear:nyquistplot:invalidInputOption', 'The method does not throw a correct error if the value for ''from'' is not an integer array (1:0.5:10).');            
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.nyquistplot('from',logical([1,2,3])),'ODESCA_Linear:nyquistplot:invalidInputOption', 'The method does not throw a correct error if the value for ''from'' is not an integer array (logical).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.nyquistplot('from',nan),'ODESCA_Linear:nyquistplot:invalidInputOption', 'The method does not throw a correct error if the value for ''from'' is not an integer array (NaN).');
            
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.nyquistplot('from',-1),'ODESCA_Linear:nyquistplot:invalidInputOption', 'The method does not throw a correct error if the entries for ''from'' are not in the range of inputs (negative).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.nyquistplot('from',1:1000),'ODESCA_Linear:nyquistplot:invalidInputOption', 'The method does not throw a correct error if the entries for ''from'' are not in the range of inputs (1000).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.nyquistplot('from',-1:1),'ODESCA_Linear:nyquistplot:invalidInputOption', 'The method does not throw a correct error if the entries for ''from'' are not in the range of inputs (-1).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.nyquistplot('from',42),'ODESCA_Linear:nyquistplot:invalidInputOption', 'The method does not throw a correct error if the entries for ''from'' are not in the range of inputs (42).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.nyquistplot('from',inf),'ODESCA_Linear:nyquistplot:invalidInputOption', 'The method does not throw a correct error if the entries for ''from'' are not in the range of inputs (Inf).');
            
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.nyquistplot('to','Hallo'),'ODESCA_Linear:nyquistplot:invalidOutputOption', 'The method does not throw a correct error if the value for ''to'' is not an integer array (string).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.nyquistplot('to',[1,2,3.5]),'ODESCA_Linear:nyquistplot:invalidOutputOption', 'The method does not throw a correct error if the value for ''to'' is not an integer array (double array).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.nyquistplot('to',0.0001),'ODESCA_Linear:nyquistplot:invalidOutputOption', 'The method does not throw a correct error if the value for ''to'' is not an integer array (double).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.nyquistplot('to',{1,2,3}),'ODESCA_Linear:nyquistplot:invalidOutputOption', 'The method does not throw a correct error if the value for ''to'' is not an integer array (cell array).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.nyquistplot('to',1:0.5:10),'ODESCA_Linear:nyquistplot:invalidOutputOption', 'The method does not throw a correct error if the value for ''to'' is not an integer array (1:0.5:10).');            
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.nyquistplot('to',logical([1,2,3])),'ODESCA_Linear:nyquistplot:invalidOutputOption', 'The method does not throw a correct error if the value for ''to'' is not an integer array (logical).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.nyquistplot('to',nan),'ODESCA_Linear:nyquistplot:invalidOutputOption', 'The method does not throw a correct error if the value for ''to'' is not an integer array (NaN).');
            
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.nyquistplot('to',-1),'ODESCA_Linear:nyquistplot:invalidOutputOption', 'The method does not throw a correct error if the entries for ''to'' are not in the range of inputs (negative).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.nyquistplot('to',1:1000),'ODESCA_Linear:nyquistplot:invalidOutputOption', 'The method does not throw a correct error if the entries for ''to'' are not in the range of inputs (1000).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.nyquistplot('to',-1:1),'ODESCA_Linear:nyquistplot:invalidOutputOption', 'The method does not throw a correct error if the entries for ''to'' are not in the range of inputs (-1).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.nyquistplot('to',42),'ODESCA_Linear:nyquistplot:invalidOutputOption', 'The method does not throw a correct error if the entries for ''to'' are not in the range of inputs (42).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.nyquistplot('to',inf),'ODESCA_Linear:nyquistplot:invalidOutputOption', 'The method does not throw a correct error if the entries for ''to'' are not in the range of inputs (Inf).');
            
            testCase.verifyWarning(@()testCase.linearS1I1O1P1CP0.nyquistplot('option',5), 'ODESCA_Linear:nyquistplot:invalidInputOption', 'The method ''nyquistplot'' of the class ''ODESCA_Linear'' does now throw a correct warning if the given option does not exist.');
            testCase.verifyWarning(@()testCase.linearS1I1O1P1CP0.nyquistplot('bodeoptions',5), 'ODESCA_Linear:nyquistplot:invalidInputOption', 'The method ''nyquistplot'' of the class ''ODESCA_Linear'' does now throw a correct warning if the given option does not exist (''bodeoptions'').');
            testCase.verifyWarning(@()testCase.linearS1I1O1P1CP0.nyquistplot('nyquistoption',5), 'ODESCA_Linear:nyquistplot:invalidInputOption', 'The method ''nyquistplot'' of the class ''ODESCA_Linear'' does now throw a correct warning if the given option does not exist (''nyquistoption'').');
            testCase.verifyWarning(@()testCase.linearS1I1O1P1CP0.nyquistplot('timeoptions',5), 'ODESCA_Linear:nyquistplot:invalidInputOption', 'The method ''nyquistplot'' of the class ''ODESCA_Linear'' does now throw a correct warning if the given option does not exist (''timeoptions'').');
            
            % Check working
                        
        end
        
        % ---------- Checks for stepplot ----------------------------------
        
        function check_stepplot(testCase)
            % Suppress figure
            set(0,'DefaultFigureVisible','off');
            
            % Check the errors
            linearArray = [testCase.linearS1I1O1P1CP0, testCase.linearS1I0O1P1CP0];
            testCase.verifyError(@()linearArray.stepplot(),'ODESCA_Linear:stepplot:dimensionMismatch', 'The method does not throw a correct error if the linearizations have different dimensions.');
            
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.stepplot('Hallo'),'ODESCA_Linear:stepplot:oddNumberOfInputArguments', 'The method does not throw a correct error if the number of arguments is not even.');
            
            testCase.verifyWarning(@()testCase.linearS1I1O1P1CP0.stepplot(5,42), 'ODESCA_Linear:stepplot:optionNotAString', 'The method ''stepplot'' of the class ''ODESCA_Linear'' does now throw a correct warning if the given option is not a scalar string (double).');
            testCase.verifyWarning(@()testCase.linearS1I1O1P1CP0.stepplot({'Hallo'},5), 'ODESCA_Linear:stepplot:optionNotAString', 'The method ''stepplot'' of the class ''ODESCA_Linear'' does now throw a correct warning if the given option is not a scalar string (cell).');
            
            testCase.verifyWarning(@()testCase.linearS1I1O1P1CP0.stepplot('timeoptions','Hallo'), 'ODESCA_Linear:stepplot:timeOptionsNotCorrect', 'The method ''stepplot'' of the class ''ODESCA_Linear'' does now throw a correct warning if the input for ''timeoptions'' is not valid.');
            testCase.verifyWarning(@()testCase.linearS1I1O1P1CP0.stepplot('timeoptions',42), 'ODESCA_Linear:stepplot:timeOptionsNotCorrect', 'The method ''stepplot'' of the class ''ODESCA_Linear'' does now throw a correct warning if the input for ''timeoptions'' is not valid (numeric).');
            
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.stepplot('from','Hallo'),'ODESCA_Linear:stepplot:invalidFromOption', 'The method does not throw a correct error if the value for ''from'' is not an integer array (string).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.stepplot('from',[1,2,3.5]),'ODESCA_Linear:stepplot:invalidFromOption', 'The method does not throw a correct error if the value for ''from'' is not an integer array (double array).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.stepplot('from',0.0001),'ODESCA_Linear:stepplot:invalidFromOption', 'The method does not throw a correct error if the value for ''from'' is not an integer array (double).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.stepplot('from',{1,2,3}),'ODESCA_Linear:stepplot:invalidFromOption', 'The method does not throw a correct error if the value for ''from'' is not an integer array (cell array).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.stepplot('from',1:0.5:10),'ODESCA_Linear:stepplot:invalidFromOption', 'The method does not throw a correct error if the value for ''from'' is not an integer array (1:0.5:10).');            
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.stepplot('from',logical([1,2,3])),'ODESCA_Linear:stepplot:invalidFromOption', 'The method does not throw a correct error if the value for ''from'' is not an integer array (logical).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.stepplot('from',nan),'ODESCA_Linear:stepplot:invalidFromOption', 'The method does not throw a correct error if the value for ''from'' is not an integer array (NaN).');
            
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.stepplot('from',-1),'ODESCA_Linear:stepplot:invalidFromOption', 'The method does not throw a correct error if the entries for ''from'' are not in the range of inputs (negative).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.stepplot('from',1:1000),'ODESCA_Linear:stepplot:invalidFromOption', 'The method does not throw a correct error if the entries for ''from'' are not in the range of inputs (1000).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.stepplot('from',-1:1),'ODESCA_Linear:stepplot:invalidFromOption', 'The method does not throw a correct error if the entries for ''from'' are not in the range of inputs (-1).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.stepplot('from',42),'ODESCA_Linear:stepplot:invalidFromOption', 'The method does not throw a correct error if the entries for ''from'' are not in the range of inputs (42).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.stepplot('from',inf),'ODESCA_Linear:stepplot:invalidFromOption', 'The method does not throw a correct error if the entries for ''from'' are not in the range of inputs (Inf).');
            
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.stepplot('to','Hallo'),'ODESCA_Linear:stepplot:invalidToOption', 'The method does not throw a correct error if the value for ''to'' is not an integer array (string).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.stepplot('to',[1,2,3.5]),'ODESCA_Linear:stepplot:invalidToOption', 'The method does not throw a correct error if the value for ''to'' is not an integer array (double array).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.stepplot('to',0.0001),'ODESCA_Linear:stepplot:invalidToOption', 'The method does not throw a correct error if the value for ''to'' is not an integer array (double).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.stepplot('to',{1,2,3}),'ODESCA_Linear:stepplot:invalidToOption', 'The method does not throw a correct error if the value for ''to'' is not an integer array (cell array).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.stepplot('to',1:0.5:10),'ODESCA_Linear:stepplot:invalidToOption', 'The method does not throw a correct error if the value for ''to'' is not an integer array (1:0.5:10).');            
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.stepplot('to',logical([1,2,3])),'ODESCA_Linear:stepplot:invalidToOption', 'The method does not throw a correct error if the value for ''to'' is not an integer array (logical).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.stepplot('to',nan),'ODESCA_Linear:stepplot:invalidToOption', 'The method does not throw a correct error if the value for ''to'' is not an integer array (NaN).');
            
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.stepplot('to',-1),'ODESCA_Linear:stepplot:invalidToOption', 'The method does not throw a correct error if the entries for ''to'' are not in the range of inputs (negative).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.stepplot('to',1:1000),'ODESCA_Linear:stepplot:invalidToOption', 'The method does not throw a correct error if the entries for ''to'' are not in the range of inputs (1000).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.stepplot('to',-1:1),'ODESCA_Linear:stepplot:invalidToOption', 'The method does not throw a correct error if the entries for ''to'' are not in the range of inputs (-1).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.stepplot('to',42),'ODESCA_Linear:stepplot:invalidToOption', 'The method does not throw a correct error if the entries for ''to'' are not in the range of inputs (42).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.stepplot('to',inf),'ODESCA_Linear:stepplot:invalidToOption', 'The method does not throw a correct error if the entries for ''to'' are not in the range of inputs (Inf).');
            
            testCase.verifyWarning(@()testCase.linearS1I1O1P1CP0.stepplot('option',5), 'ODESCA_Linear:stepplot:invalidInputOption', 'The method ''stepplot'' of the class ''ODESCA_Linear'' does now throw a correct warning if the given option does not exist.');
            testCase.verifyWarning(@()testCase.linearS1I1O1P1CP0.stepplot('bodeoptions',5), 'ODESCA_Linear:stepplot:invalidInputOption', 'The method ''stepplot'' of the class ''ODESCA_Linear'' does now throw a correct warning if the given option does not exist (''bodeoptions'').');
            testCase.verifyWarning(@()testCase.linearS1I1O1P1CP0.stepplot('nyquistoptions',5), 'ODESCA_Linear:stepplot:invalidInputOption', 'The method ''stepplot'' of the class ''ODESCA_Linear'' does now throw a correct warning if the given option does not exist (''nyquistoptions'').');
            testCase.verifyWarning(@()testCase.linearS1I1O1P1CP0.stepplot('timeoption',5), 'ODESCA_Linear:stepplot:invalidInputOption', 'The method ''stepplot'' of the class ''ODESCA_Linear'' does now throw a correct warning if the given option does not exist (''timeoption'').');
            
            % Check working
                        
        end
        
        % ---------- Checks for discretize --------------------------------
        
        function check_discretize(testCase)
            % Check the warnings
            testCase.verifyWarning(@()testCase.linearS1I1O1P1CP0.discretize(5,42), 'ODESCA_Linear:discretize:optionNotAString', 'The method ''discretize'' of the class ''ODESCA_Linear'' does now throw a correct warning if the given option is not a scalar string (double).');
            testCase.verifyWarning(@()testCase.linearS1I1O1P1CP0.discretize({'Hallo'},5), 'ODESCA_Linear:discretize:optionNotAString', 'The method ''discretize'' of the class ''ODESCA_Linear'' does now throw a correct warning if the given option is not a scalar string (cell).');
            
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.discretize('Hallo'),'ODESCA_Linear:discretize:oddNumberOfInputArguments', 'The method does not throw a correct error if the number of arguments is not even.');
            
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.discretize('sampletime',-1),'ODESCA_Linear:discretize:invalidSampleTime', 'The method does not throw a correct error if the value for ''sampletime'' is not numeric and positive (negative).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.discretize('sampletime',[5,42]),'ODESCA_Linear:discretize:invalidSampleTime', 'The method does not throw a correct error if the value for ''sampletime'' is not numeric and positive (array).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.discretize('sampletime','Hallo Welt'),'ODESCA_Linear:discretize:invalidSampleTime', 'The method does not throw a correct error if the value for ''sampletime'' is not numeric and positive (string).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.discretize('sampletime',logical(5)),'ODESCA_Linear:discretize:invalidSampleTime', 'The method does not throw a correct error if the value for ''sampletime'' is not numeric and positive (logical).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.discretize('sampletime',[]),'ODESCA_Linear:discretize:invalidSampleTime', 'The method does not throw a correct error if the value for ''sampletime'' is not numeric and positive (empty).');
            
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.discretize('method',5.42),'ODESCA_Linear:discretize:methodNotAString', 'The method does not throw a correct error if the value for ''method'' is not a string (double).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.discretize('method',[5,42]),'ODESCA_Linear:discretize:methodNotAString', 'The method does not throw a correct error if the value for ''method'' is not a string (array).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.discretize('method',string({'Hallo','Welt'})),'ODESCA_Linear:discretize:methodNotAString', 'The method does not throw a correct error if the value for ''method'' is not a string (string array).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.discretize('method',logical(5)),'ODESCA_Linear:discretize:methodNotAString', 'The method does not throw a correct error if the value for ''method'' is not a string (logical).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.discretize('method',[]),'ODESCA_Linear:discretize:methodNotAString', 'The method does not throw a correct error if the value for ''method'' is not a string (empty).');
            
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.discretize('method','backwardeuler'),'ODESCA_Linear:discretize:invalidMethod', 'The method does not throw a correct error if the method is not valid.');
            
            testCase.verifyWarning(@()testCase.linearS1I1O1P1CP0.discretize('option',5), 'ODESCA_Linear:linearizeDiscrete:invalidInputOption', 'The method ''discretize'' of the class ''ODESCA_Linear'' does now throw a correct warning if the given option does not exist.');        
                                  
            % Check working
            testCase.linearS1I1O1P1CP0.discretize;
            AD = testCase.linearS1I1O1P1CP0.Ad;
            BD = testCase.linearS1I1O1P1CP0.Bd;
            testCase.verifyEqual(AD,exp(-1),'The method does not discretize exact correctly (Ad)');
            testCase.verifyEqual(BD,-1\(exp(-1)-1)*5,'The method does not discretize exact correctly (Bd)');
            
            testCase.linearS1I1O1P1CP0.discretize('sampleTime',0.1);
            AD = testCase.linearS1I1O1P1CP0.Ad;
            BD = testCase.linearS1I1O1P1CP0.Bd;
            testCase.verifyEqual(AD,exp(-0.1),'The method does not discretize exact correctly (Ad-ST)');
            testCase.verifyEqual(BD,-1\(exp(-0.1)-1)*5,'The method does not discretize exact correctly (Bd-ST)');
            
            testCase.linearS1I1O1P1CP0.discretize('method','forwardeuler','sampleTime',0.1);
            AD = testCase.linearS1I1O1P1CP0.Ad;
            BD = testCase.linearS1I1O1P1CP0.Bd;
            testCase.verifyEqual(AD,0.9,'The method does not discretize forwardeuler correctly (Ad)');
            testCase.verifyEqual(BD,0.5,'The method does not discretize forwardeuler correctly (Bd)');
           
            testCase.linearS1I1O1P1CP0.discretize('method','tustintransform','sampleTime',0.1);
            AD = testCase.linearS1I1O1P1CP0.Ad;
            BD = testCase.linearS1I1O1P1CP0.Bd;
            testCase.verifyEqual(AD,(1+0.5*(-1)*0.1)/(1-0.5*(-1)*0.1),'The method does not discretize tustintransform correctly (Ad)');
            testCase.verifyEqual(BD,0.5,'The method does not discretize tustintransform correctly (Bd)');
            
            linearArray = [testCase.linearS1I1O1P1CP0, testCase.linearS1I0O1P1CP0];
            linearArray.discretize('method','exact');
            AD1 = linearArray(1,1).Ad;
            AD2 = linearArray(1,2).Ad;
            BD1 = linearArray(1,1).Bd;
            BD2 = linearArray(1,2).Bd;
            testCase.verifyEqual(AD1,exp(-1),'The method does not discretize exact correctly (Ad1 Array)');
            testCase.verifyEqual(AD2,exp(-1),'The method does not discretize exact correctly (Ad2 Array)');
            testCase.verifyEqual(BD1,-1\(exp(-1)-1)*5,'The method does not discretize exact correctly (Bd1 Array)');
            testCase.verifyEqual(BD2,[],'The method does not discretize exact correctly (Bd2 Array)');            
        end
        
        % ---------- Checks for isAsymptoticStable ------------------------
        
        function check_isAsymptoticStable(testCase)
            % stable
            stab = testCase.linearS1I1O1P1CP0.isAsymptoticStable;
            testCase.verifyEqual(stab,true,'The method does not check the asymptotic stability correctly');
            linearArray = [testCase.linearS1I1O1P1CP0, testCase.linearS1I0O1P1CP0];
            stab2 = linearArray.isAsymptoticStable;
            testCase.verifyEqual(stab2,[true true],'The method does not check the asymptotic stability correctly (array)');
            
            % unstable
            % TODO
        end
        
        % ---------- Checks for isObservable ------------------------------
        
        function check_isObservable(testCase)
            % Check the errors
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.isObservable([]),'ODESCA_Linear:isObservable:argumentNotAString', 'The method does not throw a correct error if the input argument is not a string (empty).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.isObservable(5.42),'ODESCA_Linear:isObservable:argumentNotAString', 'The method does not throw a correct error if the input argument is not a string (double).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.isObservable(strings),'ODESCA_Linear:isObservable:argumentNotAString', 'The method does not throw a correct error if the input argument is not a string (empty string).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.isObservable({'Name'}),'ODESCA_Linear:isObservable:argumentNotAString', 'The method does not throw a correct error if the input argument is not a string (cell).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.isObservable(string({'Hallo1','Hallo2'})),'ODESCA_Linear:isObservable:argumentNotAString', 'The method does not throw a correct error if the input argument is not a string (array).');
            
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.isObservable('Kalmar'),'ODESCA_Linear:isObservable:invalidMethod', 'The method does not throw a correct error if the input is not a valid method.');
            
            % Check working
            linearArray = [testCase.linearS1I1O1P1CP0, testCase.linearS1I0O1P1CP0];
            obsv = linearArray.isObservable;
            testCase.verifyEqual(obsv(1),true,'The method does not check the observability correctly (true)');
            testCase.verifyEqual(obsv(2),false,'The method does not check the observability correctly (false)');
            obsv2 = linearArray.isObservable('kalman');
            testCase.verifyEqual(obsv2(1),true,'The method does not check the observability correctly (true)');
            testCase.verifyEqual(obsv2(2),false,'The method does not check the observability correctly (false)');           
        end
        
        % ---------- Checks for isControllable ----------------------------
        
        function check_isControllable(testCase)
            % Check the errors
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.isControllable([]),'ODESCA_Linear:isControllable:argumentNotAString', 'The method does not throw a correct error if the input argument is not a string (empty).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.isControllable(5.42),'ODESCA_Linear:isControllable:argumentNotAString', 'The method does not throw a correct error if the input argument is not a string (double).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.isControllable(strings),'ODESCA_Linear:isControllable:argumentNotAString', 'The method does not throw a correct error if the input argument is not a string (empty string).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.isControllable({'Name'}),'ODESCA_Linear:isControllable:argumentNotAString', 'The method does not throw a correct error if the input argument is not a string (cell).');
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.isControllable(string({'Hallo1','Hallo2'})),'ODESCA_Linear:isControllable:argumentNotAString', 'The method does not throw a correct error if the input argument is not a string (array).');
            
            testCase.verifyError(@()testCase.linearS1I1O1P1CP0.isControllable('Kalmar'),'ODESCA_Linear:isControllable:invalidMethod', 'The method does not throw a correct error if the input is not a valid method.');
            
            % Check working
            linearArray = [testCase.linearS1I1O1P1CP0, testCase.linearS1I0O1P1CP0];
            ctrl = linearArray.isControllable;
            testCase.verifyEqual(ctrl(1),true,'The method does not check the controllability correctly (true)');
            testCase.verifyEqual(ctrl(2),false,'The method does not check the controllability correctly (false)');
            ctrl2 = linearArray.isControllable('kalman');
            testCase.verifyEqual(ctrl2(1),true,'The method does not check the controllability correctly (true)');
            testCase.verifyEqual(ctrl2(2),false,'The method does not check the controllability correctly (false)');           
        end
        
        % ---------- Checks for copyElement/copy/removeApproximationFromList
        
        %function check_copyElement(testCase)
            %newApprox = testcase.linear.copyElement();
            %testCase.verifyEqual(,,'The method does not copy correctly.');
            
        %end
        
        % ---------- Checks for deleteElement/delete ----------------------
        
        %function check_deleteElement(testCase)
            
        %end
    end
    
end