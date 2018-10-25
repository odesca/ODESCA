classdef(Abstract) ODESCA_BaseClass < handle
    %ODESCA_BaseClass Base Class for all classes in ODESCA
    %
    % DESCRIPTION
    %   This class is the base class for all classes used in ODESCA. It
    %   stores the current version number of ODESCA aswell as the version
    %   number the instance was created in. This second version number is 
    %   saved with the instance if the save command is used and can be seen 
    %   after loading the instance even if the version of the class 
    %   definition has changed.
    %
    % ODESCA_BaseClass
    %
    % PROPERTIES:
    %   classDefinitionVersion
    %   version
    %
    % CONSTRUCTOR:
    %   ODESCA_BaseClass()
    %
    % METHODS:
    %
    % LISTENERS
    %
    % NOTE:
    %   - WARNING: The constructor of this class should not be called 
    %     durning the load process of the class instances! Otherwise the 
    %     version can not be saved correctly!!!
    %   - The current version of ODESCA has to be updated manually for each
    %     version. It is stored in the property 'classDefinitionVersion'.   
    %
    % SEE ALSO
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
    
    %######################################################################
    %% Properties
    %######################################################################
    
    properties(Hidden, Constant)
        % Current version of ODESCA (version of the class definition)
        %
        % TYPE
        %   string
        %
        % DESCRIPTION
        %   This property stores the version the current class
        %   definition which should be equal to the current version of
        %   ODESCA.
        %
        % NOTE
        %   For each version, this string has to be updated.
        %
        % SEE ALSO
        %
        classDefinitionVersion = 'v1.1';
    end
    
    properties(Hidden, SetAccess = private)
        % Version of ODESCA the instance of the class was first created in
        %
        % TYPE
        %   string
        %
        % DESCRIPTION
        %   This property stores the version of ODESCA in which the
        %   instance was first created in. It is not overwritten if the
        %   object was saved and is loaded again
        %
        % NOTE
        %
        % SEE ALSO
        %
        version
    end
    
    %######################################################################
    %% Constructor
    %######################################################################
    
    methods
        function obj = ODESCA_BaseClass()
            % Constructor of the class ODESCA_BaseClass
            %
            % SYNTAX
            %
            % INPUT ARGUMENTS
            %
            % OPTIONAL INPUT ARGUMENTS
            %
            % OUTPUT ARGUMENTS
            %   obj:    Instance of the instance which is created in the
            %           constructor.
            %
            % DESCRIPTION
            %   This Method is the default constructor of the class. It
            %   sets the version number to the instance. It is not called
            %   when the object is loaded from a .mat-file.
            %
            % NOTE
            %   WARNING: The constructor of this class should not be called
            %   during the load process of the class instances! Otherwise 
            %   the version can not be saved correctly!!! 
            %
            % SEE ALSO
            %
            % EXAMPLE
            %
            
            % Set the current verison of ODESCA
            obj.version = obj.classDefinitionVersion;
        end
    end
    
end