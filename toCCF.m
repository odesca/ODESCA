function toCCF(obj)
% Creates the controllable canonical form of the linear system
%
% SYNTAX
%   obj.toCCF()
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
%   This method changes the linear system matrices into the controllable
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
%   sys_lin.toCCF();
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

% check if a nonlinear Simulink Model already exists
if ~(obj.isControllable)
    error('ODESCA_Linear:toCCF:notControllable','The controllable canonical form cannot be created for non controllable systems.');
end

%% Evaluation of the task

if (size(obj.B,2) == 1 && size(obj.C,1) == 1)
    %% SISO
    [A,B,C,D] = tf2ss(obj.tf.num{1},obj.tf.den{1});
    
    % other possibility:
    % Qs = ctrb(obj.A,obj.B);
    % invQs = inv(Qs);
    % sR = invQs(end,:);
    % TRinv = zeros(length(obj.A));
    % for i=0:length(obj.A)-1
    %     TRinv(i+1,:) = sR*obj.A^i;
    % end
    % TR = inv(TRinv);
    
    % A = TRinv*obj.A*TR;
    % B = TRinv*obj.B;
    % C = obj.C*TR;
    % D = obj.D;
elseif (size(obj.B,2) ~= 1 || size(obj.C,1) ~= 1)
    %% MISO, SIMO and MIMO
    % get Qs
    Qs = ctrb(obj.A,obj.B);
    
    % get cell array of vectors
    p = size(obj.B,2);
    n = size(obj.B,1);
    k=1;
    for i=1:n
        for j=1:p
            Qs_c{i,j} = Qs(:,k);
            k=k+1;
        end
    end
    
    % get linearily independend vectors and ni's
    ni = zeros(1,p); % array of n1 n2 ... np
    Qs_rt = []; % array of rank test
    flag = 0;
    
    for i=1:n
        for j=1:p
            Qs_rt = [Qs_rt, Qs_c{i,j}]; % extend Qs_rt by the next element
            ni(1,j) = ni(1,j)+1; % increase counter
            if (rank(Qs_rt) == size(Qs_rt,2)) % if not linearily dependend go ahead
                if all(size(Qs_rt)==n) % if already nxn
                    flag = 1;
                    break
                else
                    continue
                end
            else
                Qs_rt = Qs_rt(:,1:size(Qs_rt,2)-1); % delete last element
                ni(1,j) = ni(1,j)-1; % decrease counter
            end
        end
        if (flag == 1)
            break
        end
    end
    
    % sort correctly to get Sn
    k=1;
    for j=1:p
        for i=0:(ni(1,j)-1)
            idx(k) = i*p+j;
            k=k+1;
        end
    end
    Sn = Qs(:,idx);
    
    % get ti
    Sninv = inv(Sn);
    for i=1:p
        if ni(1,i) % only if ni is not zero (then the corresponding b vector is not considered)
            t(i,:) = Sninv(sum(ni(1,1:i)),:);
        end
    end
    
    % get TR
    TR = [];
    for i=1:size(t,1)
        for j=0:(ni(1,i)-1)
            TR = [TR; t(i,:)*obj.A^j];
        end
    end
    
    % get AR, BR, CR
    A = TR*obj.A/TR;
    B = TR*obj.B;
    C = obj.C/TR;
    D = obj.D;
end

% save result in structure
obj.A = A;
obj.B = B;
obj.C = C;
obj.D = D;
obj.form = 'CCF';

end