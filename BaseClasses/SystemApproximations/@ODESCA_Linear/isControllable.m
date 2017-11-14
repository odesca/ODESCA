function cntr = isControllable(obj, method)
% Checks if the linearizations are controllable
%
% SYNTAX
%   cntr = obj.isControllable()
%   cntr = obj.isControllable(method)
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
% OPTIONAL INPUT ARGUMENTS
%   method: String which determines the method used to check the
%           controllability.
%
% OUTPUT ARGUMENTS
%   cntr: boolean array, true for each linearization which is 
%         controllable, false otherwise
%
% DESCRIPTION
%   This method checks if the linearizations are controllable. It returns 
%   a logical array where true indicates that the corresponding 
%   linearization is controllable. The method to determine if the 
%   linearizations are controllable can be chosen by the argument 'method'.
%
% NOTE
%
% SEE ALSO
%
% EXAMPLE
%   cntr = obj.isObservable('kalman')
%

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

%% Constants used in the method
% =========================================================================
% Set the default parameter for the function
% =========================================================================

default_method = 'hautus';

% =========================================================================

%% Check of the conditions
% List ot methods 
methodList = {'kalman','hautus'};

% Set the default method if no argument is given
if( nargin < 2 )
    method = default_method;
end

% Check if the option is a valid string
if( ~ischar(method) || size(method,1) ~= 1)
    error('ODESCA_Linear:isControllable:argumentNotAString','The input argument ''method'' has to be a string.');
end

% Check if the value matches one of the methods
if( ~ismember(lower(method),methodList))
    errStr = ['''',method,''' is not a valid method. Use one of the following: ''',strrep(strjoin(methodList),' ',''', '''),'''.'];
    error('ODESCA_Linear:isControllable:invalidMethod',errStr);
end

%% Evaluation of the task
cntr = false(size(obj));
for numObj = 1:numel(obj)
    lin = obj(numObj);
    % Switch between the chosen method
    switch(lower(method))
        case 'hautus'
            % Get required values
            A = lin.A;          % System matrix
            B = lin.B;          % Input matrix
            I = eye(length(A)); % Identity matrix
            s = eig(A);         % Eigenvalues
            n = length(A);      % Expected rank
            
            % Check if the controllability condition is correct for every
            % eigenvalue
            controllable = true;
            for num = 1:numel(s)
                % Create the matrix to check the rank
                checkmat = [s(num) * I - A , B ];
                % Check the rank of the check matrix
                if( rank(checkmat) ~= n )
                    controllable = false;
                end
            end
            
        case 'kalman'
            % Get required values
            A = lin.A;          % System matrix
            B = lin.B;          % Output matrix
            n = length(A);      % Expected rank
            
            % Create the matrix to check the rank
            checkmat = B;
            for num = 1:(n-1)
                checkmat = [ checkmat , (A^num) * B ]; %#ok<AGROW>
            end
            
            % Check the rank of the check matrix
            if( rank(checkmat) == n )
                controllable = true;
            else
                controllable = false;
            end
    end
    cntr(numObj) = controllable;
    
end