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

%##########################################################################
% Skript to run the unit test for ODESCA
%##########################################################################
%   NOTE: The skript uses relativ pathes. To run the skript correctly, the
%   working directory has to be the place where the skript is located!

% TODO use correct path handling

% Preparation
clear;
disp('Starting TestSuit ...');

import matlab.unittest.TestSuite;
import matlab.unittest.plugins.*;
disp('Execute ''addODESCAPaths.m'' ...');
run('../addODESCAPaths.m'); % add the paths of the framework

% =========================================================================
%% Add the names of the TestCase-Folder, set save options
% =========================================================================
% Option "saveResults": if the results of the test should be saved to a 
% .mat file
saveResults = false;

% Name of the test case folder.
% NOTE: Each folder has to contain a file with the name of the folder where
%       the präfix 'Test_' is added which contains the test case. 
%       For example the folder 'ODESCA_Object' has to contain the test
%       case file 'Test_ODESCA_Object'
testNames = {'ODESCA_BaseClass', 'ODESCA_Object', 'ODESCA_ODE', 'ODESCA_Component', 'ODESCA_System', 'ODESCA_SteadyState', 'ODESCA_Linear'}; 

% =========================================================================
%% Script Code 
% Create array with Testsuits
TestSuiteAll = [];
for numTestCase = 1:numel(testNames)
    testName = testNames{numTestCase};
    %path = [testingPath,'\',testName];
    %addpath(path);
    newSuite = TestSuite.fromFile([testName,'\Test_',testName,'.m']);
    if( ~isempty(TestSuiteAll) )
        TestSuiteAll = [TestSuiteAll, newSuite];  %#ok<AGROW>
    else
        TestSuiteAll = newSuite;
    end
end

% Run testsuite with outputs
results = run(TestSuiteAll) %#ok<NOPTS>

% Save the results in the folder by the name of their creation time
clear TestSuiteAll newSuite numTestCase runner testName testNames testingPath

if(saveResults)
    save(['results/',datestr(now,'yyyy_mm_dd-HH_MM_SS'),'.mat']);
end
