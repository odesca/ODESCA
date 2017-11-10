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

classdef Test_Wrapper_ODESCA_BaseClass < ODESCA_BaseClass
    %CLASSNAME ODESCA_Component_Wrapper
    %
    % DESCRIPTION
    %   This class enambles a set access to the protected properties and
    %   methods for testing cases.
    %
    % ODESCA_BaseClass_Wrapper
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
    %   This class is for testing the Framework only. It should not be used
    %   to create an component for the system in the working process.
    %
    % SEE ALSO
    %
    
    properties  
        
    end
    
    % Constructor and Wrapped methods
    methods
        
        function obj = Test_Wrapper_ODESCA_BaseClass()
           obj = obj@ODESCA_BaseClass();
        end
        
        function set_version(obj, value)
            obj.version = value;
        end
    end
end