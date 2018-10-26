function createLuenbergerObserver(obj,p)
% Creates a Luenberger observer.
%
% SYNTAX
%   obj.createLuenbergerObserver();
%   obj.createLuenbergerObserver(p);
%
% INPUT ARGUMENTS
%   obj:    Instance of the class ODESCA_Linear
%
% OPTIONAL INPUT ARGUMENTS
%   p:      Vector of chosen eigenvalues
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   This function creates a Luenberger Observer using the state space model
%   of the linearized system. The L matrix is stored in the instance of
%   ODESCA_Linear and the nonlinear system including the observer is
%   created in simulink.
%
% NOTE
%
% SEE ALSO
%
% EXAMPLE
%     MyPendulum = OCLib_Pendulum('Pendulum');
%     MyPendulum.setParam('M0',4);
%     MyPendulum.setParam('M1',.36);
%     MyPendulum.setParam('l_s',.451);
%     MyPendulum.setParam('theta',.08433);
%     MyPendulum.setParam('Fr',10);
%     MyPendulum.setParam('C',.00145);
%     MyPendulum.setParam('g',9.81);
%     PendulumSys = ODESCA_System('MyPendulumSys',MyPendulum);
%     ss1 = PendulumSys.createSteadyState([0,0,pi,0],0,'ss1');
%     sys_lin = ss1.linearize();
%     sys_lin.createLuenbergerObserver();

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

% Check if a nonlinear Simulink Model already exists
if (exist(obj.steadyState.system.name) == 4)
    error('ODESCA_Linear:createLuenbergerObserver:simulinkModelWithSameNameExists','A Sinmulink Model with the same name already exists.');
end

% p is given
if (nargin == 2)
    % check data type of p
    if ~isnumeric(p)
        error('ODESCA_Linear:createLuenbergerObserver:valueNotNumeric','The vector p has to be numeric.');
    end
    % Check if the number of eigenvalues is correct
    if( numel(p) ~= numel(obj.steadyState.system.f))
        error('ODESCA_Linear:createLuenbergerObserver:dimensionMismatch','The number of user defined eigenvalues does not match the number of states in the system.');
    end
    % check Inf or NaN
    if (any(any(isnan(p))) || any(any(isinf(p))))
        error('ODESCA_Linear:createLuenbergerObserver:vectorContainsInfOrNan','The vector p must not contain NaN or Inf.')
    end
    % Check if all eigenvalues are negative
    if( ~all(p < 0) )
        error('ODESCA_Linear:createLuenbergerObserver:eigenvaluesPositive','All eigenvalues have to be negative.');
    end
end

% Check if system is observable
if ~obj.isObservable
    error('ODESCA_Linear:createLuenbergerObserver:notObservable','The System is not observable.');
end

%% Evaluation of the task

% If eigenvalues are not set by the user, take the eigenvalues of the
% system and shift them into the stable area
if (nargin == 1)
    p = eig(obj.A);
    for i=1:length(p)
        p(i) = abs(p(i))*(-1)*6;
    end
    
    % If one or more eigenvalues of the system are zero, replace them with
    % the closest negative eigenvalue of the system
    for i=1:length(p)
        if p(i)==0
            p(i) = max(p(p<0));
        end
    end
end

% For further tasks we need a row vector
if iscolumn(p)
    p=p';
end

% If there are eigenvalues with the same value, shift them by 1%
while ~(length(unique(p))==length(p))
    [~,ip] = unique(p);
    same = ones(size(p));
    same(ip) = 0;
    result = [p; same];
    for i=1:length(p)
        if result(2,i)>0
            p(1,i) = p(1,i)*1.01;
        end
    end
end

obj.L = (place(obj.A',obj.C',p))';

% create nonlinear simulink model
SysName = obj.steadyState.system.name;
obj.steadyState.system.createNonlinearSimulinkModel();

add_block('built-in/Subsystem',[SysName,'/Observer']);
add_block('simulink/Math Operations/Gain',[SysName,'/Observer/AMatrix'],'Gain',mat2str(obj.A));
add_block('simulink/Math Operations/Gain',[SysName,'/Observer/BMatrix'],'Gain',mat2str(obj.B));
add_block('simulink/Math Operations/Gain',[SysName,'/Observer/CMatrix'],'Gain',mat2str(obj.C));
add_block('simulink/Math Operations/Gain',[SysName,'/Observer/LMatrix'],'Gain',mat2str(obj.L));
add_block('simulink/Math Operations/Sum',[SysName,'/Observer/Sum1']);
add_block('simulink/Math Operations/Sum',[SysName,'/Observer/Sum2']);
add_block('simulink/Continuous/Integrator',[SysName,'/Observer/Integrator1']);
add_block('simulink/Sources/In1',[SysName,'/Observer/InY']);
add_block('simulink/Sources/In1',[SysName,'/Observer/InU']);
add_block('simulink/Sinks/Out1',[SysName,'/Observer/OutX']);
add_block('simulink/Sinks/Out1',[SysName,'/Observer/OutY']);

set_param([SysName,'/Observer/Sum1'],'Inputs','+|+|+');
set_param([SysName,'/Observer/Sum2'],'Inputs','|+-');
set_param([SysName,'/Observer/AMatrix'],'Multiplication','Matrix(K*u)');
set_param([SysName,'/Observer/BMatrix'],'Multiplication','Matrix(K*u)');
set_param([SysName,'/Observer/CMatrix'],'Multiplication','Matrix(K*u)');
set_param([SysName,'/Observer/LMatrix'],'Multiplication','Matrix(K*u)');

set_param([SysName,'/Observer/AMatrix'],'Position',[2*170 2*90 2*200 2*110]);
set_param([SysName,'/Observer/BMatrix'],'Position',[2*110 2*50 2*140 2*70]);
set_param([SysName,'/Observer/CMatrix'],'Position',[2*230 2*50 2*260 2*70]);
set_param([SysName,'/Observer/LMatrix'],'Position',[2*170 2*10 2*200 2*30]);

set_param([SysName,'/Observer/Integrator1'],'Position',[2*180 2*50 2*200 2*70]);
set_param([SysName,'/Observer/Sum1'],'Position',[2*152 2*52 2*156 2*56]);
set_param([SysName,'/Observer/Sum2'],'Position',[2*260 2*15 2*270 2*25]);
set_param([SysName,'/Observer/InU'],'Position',[2*50 2*55 2*70 2*65]);
set_param([SysName,'/Observer/InY'],'Position',[2*280 2*15 2*300 2*25]);
set_param([SysName,'/Observer/OutX'],'Position',[2*280 2*95 2*300 2*105]);
set_param([SysName,'/Observer/OutY'],'Position',[2*280 2*55 2*300 2*65]);

set_param([SysName,'/Observer/Sum2'],'Orientation','left');
set_param([SysName,'/Observer/AMatrix'],'Orientation','left');
set_param([SysName,'/Observer/LMatrix'],'Orientation','left');
set_param([SysName,'/Observer/InY'],'Orientation','left');

add_line([SysName,'/Observer'],'BMatrix/1','Sum1/2','autorouting','on');
add_line([SysName,'/Observer'],'Sum1/1','Integrator1/1','autorouting','on');
add_line([SysName,'/Observer'],'Integrator1/1','CMatrix/1','autorouting','on');
add_line([SysName,'/Observer'],'Integrator1/1','AMatrix/1','autorouting','on');
add_line([SysName,'/Observer'],'AMatrix/1','Sum1/3','autorouting','on');
add_line([SysName,'/Observer'],'CMatrix/1','Sum2/2','autorouting','on');
add_line([SysName,'/Observer'],'Sum2/1','LMatrix/1','autorouting','on');
add_line([SysName,'/Observer'],'LMatrix/1','Sum1/1','autorouting','on');

add_line([SysName,'/Observer'],'InU/1','BMatrix/1','autorouting','on');
add_line([SysName,'/Observer'],'InY/1','Sum2/1','autorouting','on');
add_line([SysName,'/Observer'],'Integrator1/1','OutX/1','autorouting','on');
add_line([SysName,'/Observer'],'CMatrix/1','OutY/1','autorouting','on');

p = get_param([SysName,'/',SysName],'Position');
set_param([SysName,'/Observer'],'Position',[p(1) 2*p(4)-p(2) p(3) 3*p(4)-2*p(2)]);

add_block('simulink/Signal Routing/Mux',[SysName,'/MuxY']);
add_block('simulink/Signal Routing/Mux',[SysName,'/MuxU']);
add_block('simulink/Commonly Used Blocks/Out1',[SysName,'/OutY']);
add_block('simulink/Commonly Used Blocks/Out1',[SysName,'/OutX']);

o = numel(obj.steadyState.system.g);
i = numel(obj.steadyState.system.u);
set_param([SysName,'/MuxU'],'Inputs',num2str(i));
set_param([SysName,'/MuxY'],'Inputs',num2str(o));

ixy = get_param([SysName,'/Observer'],'PortConnectivity');
p1 = get_param([SysName,'/MuxY'],'Position');
set_param([SysName,'/MuxY'],'Position',[ixy(1).Position(1)-40 ixy(1).Position(2)-10*o ixy(1).Position(1)-40+p1(3)-p1(1) ixy(1).Position(2)+10*o]);
set_param([SysName,'/MuxU'],'Position',[ixy(2).Position(1)-60 ixy(2).Position(2)-10*i ixy(2).Position(1)-60+p1(3)-p1(1) ixy(2).Position(2)+10*i]);
p1 = get_param([SysName,'/OutX'],'Position');
set_param([SysName,'/OutX'],'Position',[ixy(3).Position(1)+85 ixy(3).Position(2)-(p1(4)-p1(2))/2 ixy(3).Position(1)+85+p1(3)-p1(1) ixy(3).Position(2)+(p1(4)-p1(2))/2]);
set_param([SysName,'/OutY'],'Position',[ixy(4).Position(1)+85 ixy(4).Position(2)-(p1(4)-p1(2))/2 ixy(4).Position(1)+85+p1(3)-p1(1) ixy(4).Position(2)+(p1(4)-p1(2))/2]);

for z=1:i
    add_line(SysName,['In_',obj.steadyState.system.inputNames{z},'/1'],['MuxU/',num2str(z)],'autorouting','on');
end
for z=1:o
    add_line(SysName,[SysName,'/',num2str(z)],['MuxY/',num2str(z)],'autorouting','on');
end

add_line(SysName,'MuxY/1','Observer/1','autorouting','on');
add_line(SysName,'MuxU/1','Observer/2','autorouting','on');
add_line(SysName,'Observer/1','OutX/1','autorouting','on');
add_line(SysName,'Observer/2','OutY/1','autorouting','on');

end