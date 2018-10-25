function toOCF(obj)
% Creates the observable canonical form of the linear system
%
% SYNTAX
%   obj.toOCF()
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the method was
%           called. This parameter is given automatically.
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   This method changes the linear system matrices into the observable
%   canonical form.
%
% NOTE
%   This function is not reversible.
%
% SEE ALSO
%   Ludyk: Theoretische Regelungstechnik 2: Zustandsrekonstruktion,
%   optimale und nichtlineare Regelungssysteme
%
% EXAMPLE
%   Pipe = OCLib_Pipe('MyPipe');
%   Pipe.setConstructionParam('Nodes',2);
%   Pipe.setParam('cPipe',500);
%   Pipe.setParam('mPipe',0.5);
%   Pipe.setParam('VPipe',0.001);
%   Pipe.setParam('RhoFluid', 998);
%   Pipe.setParam('cFluid',4182);
%   PipeSys = ODESCA_System('MySystem',Pipe);
%   ss1 = PipeSys.createSteadyState([40; 40],[40; 0.1] ,'ss1');
%   sys_lin = ss1.linearize();
%   sys_lin.A
%   sys_lin.B
%   sys_lin.C
%   sys_lin.toOCF();
%   sys_lin.A
%   sys_lin.B
%   sys_lin.C
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

% check if the system is observable
if ~(obj.isObservable)
    error('ODESCA_Linear:toOCF:notObservable','The observable canonical form cannot be created for non observable systems.');
end

%% Evaluation of the task

if (size(obj.B,2) == 1 && size(obj.C,1) == 1)
    %% SISO
    [A,B,C,D] = canon(ss(obj.A,obj.B,obj.C,obj.D),'companion');
    
    % other possibility:
    % Qb = obsv(obj.A,obj.C);
    % invQb = inv(Qb);
    % sB = invQb(:,end);
    % TBinv = zeros(length(obj.A));
    % for i=0:length(obj.A)-1
    %     TBinv(:,i+1) = obj.A^i*sB;
    % end
    % TB = inv(TBinv);
    
    % A = TBinv*obj.A*TB;
    % B = TBinv*obj.B;
    % C = obj.C*TB;
    % D = obj.D;
elseif (size(obj.B,2) ~= 1 || size(obj.C,1) ~= 1)
    %% MISO, SIMO and MIMO
    % get Qs
    Qb = obsv(obj.A,obj.C);
    
    % get cell array of vectors
    q = size(obj.C,1);
    m = size(obj.C,2);
    k=1;
    for i=1:m
        for j=1:q
            Qb_c{i,j} = Qb(k,:);
            k=k+1;
        end
    end
    
    % get linearily independend vectors and ni's
    mi = zeros(1,q); % array of n1 n2 ... np
    Qb_rt = []; % array of rank test
    flag = 0;
    
    for i=1:m
        for j=1:q
            Qb_rt = [Qb_rt; Qb_c{i,j}]; % extend Qs_rt by the next element
            mi(1,j) = mi(1,j)+1; % increase counter
            if (rank(Qb_rt) == size(Qb_rt,1)) % if not linearily dependend go ahead
                if all(size(Qb_rt)==m) % if already nxn
                    flag = 1;
                    break
                else
                    continue
                end
            else
                Qb_rt = Qb_rt(1:size(Qb_rt,1)-1,:); % delete last element
                mi(1,j) = mi(1,j)-1; % decrease counter
            end
        end
        if (flag == 1)
            break
        end
    end
    
    % sort correctly to get Rn
    k=1;
    for j=1:q
        for i=0:(mi(1,j)-1)
            idx(k) = i*q+j;
            k=k+1;
        end
    end
    Rn = Qb(idx,:);
    
    % get ti
    Rninv = inv(Rn);
    for i=1:q
        if mi(1,i) % only if ni is not zero (then the corresponding b vector is not considered)
            t(:,i) = Rninv(:,sum(mi(1,1:i)));
        end
    end
    
    % get TR
    TB = [];
    for i=1:size(t,2)
        for j=0:(mi(1,i)-1)
            TB = [TB, obj.A^j*t(:,i)];
        end
    end
    
    % get AR, BR, CR
    A = TB\obj.A*TB;
    B = TB\obj.B;
    C = obj.C*TB;
    D = obj.D;
end

% save result in structure
obj.A = A;
obj.B = B;
obj.C = C;
obj.D = D;
obj.form = 'OCF';

end