function [newControlAffineSystem, approxflag] = createControlAffineSystem(sys, timeConst)
% Creates a new ODESCA_ControlAffineSystem and links the system to it
%
% SYNTAX
%   sys.createControlAffineSystem
%   sys.createControlAffineSystem(timeConst)
%
% INPUT ARGUMENTS
%   sys:        Instance of the object where the method was
%               called. This parameter is given automatically.
%
% OPTIONAL INPUT ARGUMENTS
%   timeConst:  PT1 Time constant, if an approximation is necessary. Default
%               value is 0.001.
%
% OUTPUT ARGUMENTS
%   newControlAffineSystem: ODESCA_ControlAffineSystem instance which was 
%                           created in this method
%   approxflag: boolean to indicate, if there was an approximation made
%
% DESCRIPTION
%
% SEE ALSO
%   
%
% EXAMPLE
%     
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

%% Check of the conditions
if (nargin == 2)
    % Check if the time constant is a scalar numeric value greater than zero
    if( ~isnumeric(timeConst) || numel(timeConst) ~= 1 || timeConst <= 0)
        error('ODESCA_System:createControlAffineSystem:invalidTimeConstant','The time constant has to be a scalar numeric value greater than zero.'); 
    end
end

%% Evaluation of the task

% Check if system is already control affine
% if it is control affine, f0 and f1 will be calculated
isControlAffine = true;
f0 = sym('f0', [length(sys.f),1]);
f0(:) = 0;
f1 = sym('f1', [length(sys.f),length(sys.u)]);
f1(:) = 0;
for i=1:length(sys.f)
    eqParts = children(expand(sys.f(i)));
    for j=1:length(eqParts)
        % Check if any input is in eq part
        if ~has(eqParts(j),sys.u)
            % Add eqPart#j to f0(i)
            f0(i) = simplify(f0(i) + simplify(eqParts(j)));
        else
            % Check for different inputs 
            for k=1:length(sys.u)
                resultingVariables = symvar(simplify(diff(eqParts(j),sys.u(k)))); 
                if any(has(resultingVariables,sys.u))
                    isControlAffine = false;
                    break
                else
                    % add eqPart#j/u to f1(i,k)
                    f1(i,k) = simplify(f1(i,k) + simplify(diff(eqParts(j),sys.u(k))));
                end
            end
        
        end
        if ~isControlAffine
            break
        end
    end
    if ~isControlAffine
        break
    end
end

% without approximation
if isControlAffine
    
    if (nargin == 2)
        warning('ODESCA_System:createControlAffineSystem:NoNeedOfTimeConst','The original system is already control affine. Therefore, ''timeConst'' will not be used.');
    end
    
    % Create control affine system
    newControlAffineSystem = ODESCA_ControlAffineSystem(sys, f0, f1, 0,[sys.name,'_ControlAffine']);
    newControlAffineSystem.u = sys.u;
    newControlAffineSystem.x = sys.x;
    newControlAffineSystem.stateNames = sys.stateNames;
    newControlAffineSystem.inputNames = sys.inputNames;
    newControlAffineSystem.stateUnits = sys.stateUnits;
    newControlAffineSystem.inputUnits = sys.inputUnits;
    
% With approximation
else
    if (nargin == 2)
        T = timeConst;
    else % default
        T = 0.001;
        warning('ODESCA_System:createControlAffineSystem:ControlAffineFormIsApproximation','The generated control affine system is only an approximation of the given nonlinear system. The PT1 time constant for the approximation was chosen as 0.001 (default). To get better results, please set the time constant accordingly to your system.');
    end

    % Buffer System
    buffersys = ODESCA_System();
    buffersys.f = sys.f;
    buffersys.u = sys.u;
    buffersys.x = sys.x;
    buffersys.stateNames = sys.stateNames;
    buffersys.inputNames = sys.inputNames;
    buffersys.stateUnits = sys.stateUnits;
    buffersys.inputUnits = sys.inputUnits;
    
    for i=1:length(buffersys.f)
        eqParts = children(expand(buffersys.f(i)));
        for j=1:length(eqParts)
            for k=1:length( buffersys.u)               
                resultingVariables = symvar(simplify(diff(eqParts(j), buffersys.u(k)))); 
                if any(has(resultingVariables, buffersys.u))                
                    % Find non linear input
                    nonlinear_input =  buffersys.u(k);                     
                    numberNewX = 1; 
                    numberOldX = numel( buffersys.x); 
                    
                    % Add new symbolic states to the system 
                    newX = sym('x',[numberOldX + numberNewX,1]);
                    newX = newX((numberOldX + 1):(numberOldX + numberNewX));
                    buffersys.x = [buffersys.x; newX];
                    
                    % Add new state names and units
                    newXname = [sys.name,'_Approx_u',num2str(k)];
                    buffersys.stateNames = [buffersys.stateNames ; newXname];
                    buffersys.stateUnits = [buffersys.stateUnits ; buffersys.stateUnits(i)];
                    
                    % Non linear u replaced with the new state                    
                    buffersys.f(i) = subs(buffersys.f(i),nonlinear_input,newX);
                    
                    % Forming new f with PT1
                    newf = 1/T * (nonlinear_input - newX);
                    
                    % Add f 
                    buffersys.f = [buffersys.f; newf];
                    
                    % Refresh equation parts
                    eqParts = children(expand(buffersys.f(i)));
                    break                    
                end   
            end
        end
    end

    % f0 and f1 building with approximation
    f0 = sym('f0', [length(buffersys.f),1]);
    f0(:) = 0;
    f1 = sym('f1', [length(buffersys.f),length(sys.u)]);
    f1(:) = 0;
    for i=1:length(buffersys.f)
        eqParts = children(expand(buffersys.f(i)));
        for j=1:length(eqParts)
            if ~has(eqParts(j), buffersys.u)
                f0(i) = simplify(f0(i) + simplify(eqParts(j)));
            else
                for k=1:length(sys.u)
                    f1(i,k) = simplify(f1(i,k) + simplify(diff(eqParts(j), buffersys.u(k))));
                end
            end
        end
    end
    
    % Create control affine system
    newControlAffineSystem = ODESCA_ControlAffineSystem(buffersys, f0, f1, 1,[sys.name,'_ControlAffine']);
    newControlAffineSystem.u = buffersys.u;
    newControlAffineSystem.x = buffersys.x;
    newControlAffineSystem.stateNames = buffersys.stateNames;
    newControlAffineSystem.inputNames = buffersys.inputNames;
    newControlAffineSystem.stateUnits = buffersys.stateUnits;
    newControlAffineSystem.inputUnits = buffersys.inputUnits;
    
end

%##########################################################################

if(nargout >= 2)
   approxflag = newControlAffineSystem.approxflag;
end

end