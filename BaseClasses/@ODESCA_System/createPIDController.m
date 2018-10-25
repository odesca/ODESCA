function createPIDController (sys,Kp,Ki,Kd)
% Creates a PID controller for MIMO systems and links it to the nonlinear
% simulink model.
%
% SYNTAX
%   sys.createPIDController();
%   sys.createPIDController(Kp);
%   sys.createPIDController(Kp,Ki);
%   sys.createPIDController(Kp,Ki,Kd);
%
% INPUT ARGUMENTS
%   sys:    Instance of the class ODESCA_System
%
% OPTIONAL INPUT ARGUMENTS
%   Kp:     Values for proportional gain
%   Ki:     Values for integral gain
%   Kd:     Values for derivative gain
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   This function creates a PID controller for a system with multiple 
%   inputs and ouputs. The nonlinear system including the controller is 
%   created in simulink.
%
% NOTE
%
% SEE ALSO
%
% EXAMPLE
%   Pipe = OCLib_Pipe('MyPipe');
%   Pipe.setConstructionParam('Nodes',2);
%   PipeSys = ODESCA_System('MySystem',Pipe);
%   PipeSys.createPIDController([500 1000; 10 10],[200 300; 10 10],[300 200; 10 20]);

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

% check if a nonlinear Simulink Model already exists
if (exist(sys.name) == 4)
    error('ODESCA_System:createPIDController:simulinkModelWithSameNameExists','A Sinmulink Model with the same name already exists.');
end

% check if the dimensions of the input Kp,Ki,Kd match the system
if( nargin == 2 ) % only Kp was set
    if ~all(size(Kp) == [numel(sys.u),numel(sys.g)])
        error('ODESCA_System:createPIDController:sizeOfKWrong','The size of Kp,Ki or Kd does not match the system.');
    end
end

if( nargin == 3 ) % only Kp and Ki were set
    if ~all(size(Kp) == [numel(sys.u),numel(sys.g)]) || ~all(size(Ki) == [numel(sys.u),numel(sys.g)])
        error('ODESCA_System:createPIDController:sizeOfKWrong','The size of Kp,Ki or Kd does not match the system.');
    end
end

if( nargin == 4 ) % all parameters were set
    if ~all(size(Kp) == [numel(sys.u),numel(sys.g)]) || ~all(size(Ki) == [numel(sys.u),numel(sys.g)]) || ~all(size(Ki) == [numel(sys.u),numel(sys.g)])
        error('ODESCA_System:createPIDController:sizeOfKWrong','The size of Kp,Ki or Kd does not match the system.');
    end
end

%% Check number inputs

% if Kp, Ki or Kd were not set by the user, set them all to eyes
if( nargin == 1 )
    Kp = eye(numel(sys.u),numel(sys.g));
    Ki = eye(numel(sys.u),numel(sys.g));
    Kd = eye(numel(sys.u),numel(sys.g));
end

if( nargin == 2 )
    Ki = eye(numel(sys.u),numel(sys.g));
    Kd = eye(numel(sys.u),numel(sys.g));
end

if( nargin == 3 )
    Kd = eye(numel(sys.u),numel(sys.g));
end

%% Evaluation of the task

SysName = sys.name;

% create nonlinear simulink model
sys.createNonlinearSimulinkModel();

% add PID controller structure
add_block('simulink/Commonly Used Blocks/Subsystem',[SysName,'/PIDController']);
add_block('simulink/Math Operations/Gain',[SysName,'/PIDController/MatrixP'],'Gain',mat2str(Kp));
add_block('simulink/Math Operations/Gain',[SysName,'/PIDController/MatrixI'],'Gain',mat2str(Ki));
add_block('simulink/Math Operations/Gain',[SysName,'/PIDController/MatrixD'],'Gain',mat2str(Kd));
add_block('simulink/Continuous/Integrator',[SysName,'/PIDController/Integrator']);
add_block('simulink/Continuous/Derivative',[SysName,'/PIDController/Derivative']);
add_block('simulink/Signal Routing/Mux',[SysName,'/Mux1'],'Orientation','left');
add_block('simulink/Signal Routing/Mux',[SysName,'/Mux2']);
add_block('simulink/Signal Routing/Demux',[SysName,'/Demux1']);
add_block('simulink/Math Operations/Add',[SysName,'/PIDController/Add']);
add_block('simulink/Math Operations/Sum',[SysName,'/Sum']);

y = numel(sys.g);
u = numel(sys.u);
set_param([SysName,'/PIDController/MatrixP'],'Multiplication','Matrix(K*u)');
set_param([SysName,'/PIDController/MatrixI'],'Multiplication','Matrix(K*u)');
set_param([SysName,'/PIDController/MatrixD'],'Multiplication','Matrix(K*u)');
set_param([SysName,'/PIDController/Add'],'Inputs','+++');
set_param([SysName,'/Sum'],'Inputs','|+-');
set_param([SysName,'/Mux1'],'Inputs',num2str(y));
set_param([SysName,'/Mux2'],'Inputs',num2str(u));
set_param([SysName,'/Demux1'],'Outputs',num2str(u));
set_param([SysName,'/PIDController/In1'],'Name','e');
set_param([SysName,'/PIDController/Out1'],'Name','u');

p = get_param([SysName,'/',SysName],'Position');
set_param([SysName,'/PIDController/MatrixP'],'Position',[300   434   330   466]);
set_param([SysName,'/PIDController/MatrixI'],'Position',[300   484   330   516]);
set_param([SysName,'/PIDController/MatrixD'],'Position',[300   529   330   561]);
set_param([SysName,'/PIDController/Integrator'],'Position',[375   484   405   516]);
set_param([SysName,'/PIDController/Derivative'],'Position',[375   529   405   561]);
set_param([SysName,'/PIDController/Add'],'Position',[460   484   490   516]);
set_param([SysName,'/PIDController/e'],'Position',[195 493 225 507]);
set_param([SysName,'/PIDController/u'],'Position',[540 493 570 507]);

p1 = get_param([SysName,'/Mux1'],'Position');
set_param([SysName,'/Mux1'],'Position',[p(3)-p1(3)+p1(1) p(4)+50 p(3) p(4)+50+p1(4)-p1(2)]);
set_param([SysName,'/Mux2'],'Position',[p(1)-300 p(2) p(1)+p1(3)-p1(1)-300 p(4)]);
set_param([SysName,'/Demux1'],'Position',[p(1)-50 p(2) p(1)+p1(3)-p1(1)-50 p(4)]);
p1 = get_param([SysName,'/Sum'],'Position');
set_param([SysName,'/Sum'],'Position',[p(1)-250 (p(2)+p(4)-p1(4)+p1(2))/2 p(1)-250+p1(3)-p1(1) (p(2)+p(4)-p1(4)+p1(2))/2+p1(4)-p1(2)]);
p1 = get_param([SysName,'/PIDController'],'Position');
set_param([SysName,'/PIDController'],'Position',[p(1)-200 (p(2)+p(4)-p1(4)+p1(2))/2 p(1)-200+p1(3)-p1(1) (p(2)+p(4)-p1(4)+p1(2))/2+p1(4)-p1(2)]);

for i=1:u
    % set positions
    p_in = get_param([SysName,'/In_',cell2mat(sys.inputNames(i))],'Position');
    set_param([SysName,'/In_',cell2mat(sys.inputNames(i))],'Position',[p(1)-400 p_in(2) p(1)-400+p_in(3)-p_in(1) p_in(4)]);
    % connect lines
    delete_line(SysName,['In_',cell2mat(sys.inputNames(i)),'/1'],[SysName,'/',num2str(i)]);
    add_line(SysName,['In_',cell2mat(sys.inputNames(i)),'/1'],['Mux2/',num2str(i)],'autorouting','on');
    add_line(SysName,['Demux1/',num2str(i)],[SysName,'/',num2str(i)],'autorouting','on');
    set_param([SysName,'/In_',cell2mat(sys.inputNames(i))],'Name',['Setpoint_',cell2mat(sys.outputNames(i))]);
end

add_line([SysName,'/PIDController'],'MatrixP/1','Add/1','autorouting','on');
add_line([SysName,'/PIDController'],'MatrixI/1','Integrator/1','autorouting','on');
add_line([SysName,'/PIDController'],'MatrixD/1','Derivative/1','autorouting','on');
add_line([SysName,'/PIDController'],'Integrator/1','Add/2','autorouting','on');
add_line([SysName,'/PIDController'],'Derivative/1','Add/3','autorouting','on');
delete_line([SysName,'/PIDController'],'e/1','u/1');
add_line([SysName,'/PIDController'],'e/1','MatrixP/1','autorouting','on');
add_line([SysName,'/PIDController'],'e/1','MatrixI/1','autorouting','on');
add_line([SysName,'/PIDController'],'e/1','MatrixD/1','autorouting','on');
add_line([SysName,'/PIDController'],'Add/1','u/1','autorouting','on');
add_line(SysName,'PIDController/1','Demux1/1','autorouting','on');
add_line(SysName,'Mux1/1','Sum/2','autorouting','on');
add_line(SysName,'Sum/1','PIDController/1','autorouting','on');
add_line(SysName,'Mux2/1','Sum/1','autorouting','on');

for i=1:y
    add_line(SysName,[SysName,'/',num2str(i)],['Mux1/',num2str(i)],'autorouting','on');
end

end