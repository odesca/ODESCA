function createFSF(obj,p)
% Creates a full state feedback controller.
%
% SYNTAX
%   obj.createFSF();
%   obj.createFSF(p);
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
%   This function creates a full state feedback controller with
%   precompensation using the state space model of the linearized system.
%   The K and V matrices are stored in the instance of ODESCA_Linear and
%   the nonlinear system including the controller is created in simulink.
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
%     PendulumSys.removeOutput('Pendulum_Angle')
%     ss1 = PendulumSys.createSteadyState([0,0,0,0],0,'ss1');
%     sys_lin = ss1.linearize();
%     sys_lin.createFSF();

% Copyright 2017 Tim Grunert, Christian Schade, Lars Brandes, Sven Fielsch,
% Claudia Michalik, Matthias Stursberg, Julia Sudhoff
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
    error('ODESCA_Linear:createFSF:simulinkModelWithSameNameExists','A Sinmulink Model with the same name already exists.');
end

% Check if all parameters are set
if( ~obj.steadyState.system.checkParam() )
    error('ODESCA_Linear:createFSF:notAllParametersSet', 'A controller can not be created if there are unset parameters in the system.');
end

% Check if system is contollable
if ~obj.isControllable
    error('ODESCA_Linear:createFSF:notControllable','The System is not controllable.');
end

% Eigenvalues are set by the user
if (nargin == 2)
    % Check if p is numeric
    if( ~isnumeric(p) )
        error('ODESCA_Linear:createFSF:valueNotNumeric','The argument p has to be numeric.');
    end
    
    % Check if the number of eigenvalues is correct
    if( numel(p) ~= numel(obj.steadyState.system.f))
        error('ODESCA_Linear:createFSF:dimensionMismatch','The number of user defined eigenvalues does not match the number of states in the system.');
    end
    
    % Check if all eigenvalues are negative
    if( ~all(p < 0) )
        error('ODESCA_Linear:createFSF:eigenvaluesPositive','All eigenvalues have to be negative.');
    end
end

%% Warnings
if ~(numel(obj.steadyState.system.u) == numel(obj.steadyState.system.g))
    warning('ODESCA_Linear:createFSF:precompensationNotPossible','Calculating a precompensation matrix is not possible due to different I/O dimensions.');
end

%% Evaluation of the task

% If eigenvalues are not set by the user, take the eigenvalues of the
% system and shift them into the stable area
if (nargin == 1)
    p = eig(obj.A);
    for i=1:length(p)
        p(i) = abs(p(i))*(-1)*2;
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

%create K Matrix
obj.K = place(obj.A,obj.B,p);

%create V Matrix
if numel(obj.steadyState.system.u) == numel(obj.steadyState.system.g)
    obj.V = -inv(obj.C/(obj.A-obj.B*obj.K)*obj.B);
else
    obj.V = zeros(numel(obj.steadyState.system.g),numel(obj.steadyState.system.u));
end

% create nonlinear simulink model
SysName = obj.steadyState.system.name;

obj.steadyState.system.createNonlinearSimulinkModel();
add_block('simulink/Math Operations/Gain',[SysName,'/MatrixK'],'Gain',mat2str(obj.K));
add_block('simulink/Math Operations/Gain',[SysName,'/MatrixV'],'Gain',mat2str(obj.V));
add_block('simulink/Math Operations/Sum',[SysName,'/Sum']);
add_block('simulink/Signal Routing/Mux',[SysName,'/Mux1']);
add_block('simulink/Signal Routing/Demux',[SysName,'/Demux1']);

u = numel(obj.steadyState.system.u);
y = numel(obj.steadyState.system.g);
set_param([SysName,'/MatrixK'],'Multiplication','Matrix(K*u)');
set_param([SysName,'/MatrixK'],'Orientation','left');
set_param([SysName,'/MatrixV'],'Multiplication','Matrix(K*u)');
set_param([SysName,'/Sum'],'Inputs','|+-');
set_param([SysName,'/Mux1'],'Inputs',num2str(y));
set_param([SysName,'/Demux1'],'Outputs',num2str(u));

p = get_param([SysName,'/',SysName],'Position');
p1 = get_param([SysName,'/MatrixK'],'Position');
set_param([SysName,'/MatrixK'],'Position',[(p(3)+p(1)-p1(3)+p1(1))/2 p(4)+50 (p(3)+p(1)-p1(3)+p1(1))/2+p1(3)-p1(1) p(4)+50+p1(4)-p1(2)]);
set_param([SysName,'/MatrixV'],'Position',[p(1)-150 (p(2)+p(4)-p1(4)+p1(2))/2 p(1)-150+p1(3)-p1(1) (p(2)+p(4)-p1(4)+p1(2))/2+p1(4)-p1(2)]);
p1 = get_param([SysName,'/Sum'],'Position');
set_param([SysName,'/Sum'],'Position',[p(1)-100 (p(2)+p(4)-p1(4)+p1(2))/2 p(1)-100+p1(3)-p1(1) (p(2)+p(4)-p1(4)+p1(2))/2+p1(4)-p1(2)]);
p1 = get_param([SysName,'/Demux1'],'Position');
set_param([SysName,'/Demux1'],'Position',[p(1)-50 p(2) p(1)+p1(3)-p1(1)-50 p(4)]);
set_param([SysName,'/Mux1'],'Position',[p(1)-200 p(2) p(1)+p1(3)-p1(1)-200 p(4)]);

for i=1:u
    delete_line(SysName,['In_',cell2mat(obj.steadyState.system.inputNames(i)),'/1'],[SysName,'/',num2str(i)]);
    delete_block([SysName,'/In_',cell2mat(obj.steadyState.system.inputNames(i))]);
    add_line(SysName,['Demux1/',num2str(i)],[SysName,'/',num2str(i)],'autorouting','on');
end

ph1 = get_param([SysName,'/Mux1'],'PortConnectivity');
for i=1:y
    add_block('simulink/Commonly Used Blocks/In1',[SysName,'/Setpoint_',cell2mat(obj.steadyState.system.outputNames(i))]);
    % set positions
    p1 = ph1(i).Position;
    p_in = get_param([SysName,'/Setpoint_',cell2mat(obj.steadyState.system.outputNames(i))],'Position');
    set_param([SysName,'/Setpoint_',cell2mat(obj.steadyState.system.outputNames(i))],'Position',[p1(1)-100 p1(2)-(p_in(4)-p_in(2))/2 p1(1)-100+p_in(3)-p_in(1) p1(2)+p_in(4)-p_in(2)-(p_in(4)-p_in(2))/2]);
    % connect lines
    add_line(SysName,['Setpoint_',cell2mat(obj.steadyState.system.outputNames(i)),'/1'],['Mux1/',num2str(i)],'autorouting','on');
end

add_line(SysName,[SysName,'/',mat2str(y+1)],'MatrixK/1','autorouting','on');
add_line(SysName,'Mux1/1','MatrixV/1','autorouting','on');
add_line(SysName,'MatrixK/1','Sum/2','autorouting','on');
add_line(SysName,'MatrixV/1','Sum/1','autorouting','on');
add_line(SysName,'Sum/1','Demux1/1','autorouting','on');

end