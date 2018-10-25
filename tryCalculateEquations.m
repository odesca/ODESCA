function calculationCorrect = tryCalculateEquations(obj)
% Calculates the equations if all construction parameters are set.
%
% SYNTAX
%   obj.tryCalculateEquations()
%   calculationPossible = obj.tryCalculateEquations()
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%   calculationPossible: true, if all construction parameters are set
%
% DESCRIPTION
%   This method triggers the calculation of the equations f and g if two
%   conditions are met:
%       1: The equations have not been calculated already.
%           -> If the equations were calculated before, changes may have
%              been made to the component which would be lost if the
%              equations are calculated again.
%       2: If there are construction parameters they have to be set
%           -> The construction parameters are necessary for the
%              calculation of the equations therefore all of them have to
%              be set.
%   If the construction parameters are not set, the method returns false
%   and a warning is thrown. Otherwise the method returns true. 
%   If the calculation is triggerd the method afterwards checks if the
%   equations are calculated correctly (wright number and symbolic
%   expressions in it, see checkEquationsCorrect). If this is not the case,
%   the method throws a warning.
%
% NOTE
%   - It is necessary to have the calculation in an extra method
%     because on initialization the forced parameters are not set.
%
% SEE ALSO
%   checkEquationsCalculated()
%   checkEquationsCorrect()
%
% EXAMPLE
%    Pipe = OCLib_Pipe('MyPipe');
%    calculationPossible_before = Pipe.tryCalculateEquations
%    Pipe.setConstructionParam('Nodes',2);
%    calculationPossible_after = Pipe.tryCalculateEquations


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

%% Evaluation of the task
% If the equations have not been initialized...
if( ~obj.FLAG_EquationsCalculated )
    % Calculate the equations if possible
    correct = false; % Boolean to determine if the equations are calculated correctly
    if(obj.checkConstructionParam())
        % Calculate the equations and set the flag
        obj.calculateEquations();
          
        % Check if all equations are set correct
        if( ~obj.checkEquationsCorrect() )
            warning('ODESCA_Component:tryCalculateEquations:equationsNotCorrect',['The equations in f and g of the object ''',obj.name,''' have not been set correctly in calculateEquations(). Check the equations in the class ''',class(obj),'''.']);  
        else
            correct = true;
            obj.FLAG_EquationsCalculated = true;
        end
    else
        warning('ODESCA_Component:tryCalculateEquations:calculationNotPossible','The calculation of the equations was not possible because not all construction parameters are set.');
    end
else
    correct = true;
end

% Set the value to be returned
calculationCorrect = correct;

end