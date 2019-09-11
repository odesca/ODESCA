%% Parameters

Pendulum_comp = OCLib_Pendulum('myPendulum');

Pendulum_comp.setParam('M0',4);
Pendulum_comp.setParam('M1',.36);
Pendulum_comp.setParam('l_s',.451);
Pendulum_comp.setParam('theta',.08433);
Pendulum_comp.setParam('Fr',10);
Pendulum_comp.setParam('C',.00145);
Pendulum_comp.setParam('g',9.81);

Pendulum_sys = ODESCA_System('MyPendulumSystem',Pendulum_comp);

%% Tasks

% find all steadyStates
Pendulum_sys.calculateValidSteadyStates();

% create a steadystate
ss = Pendulum_sys.createSteadyState([0,0,0,0],0,'mySteadyState');
% linearize
Pendulum_sys_lin = ss.linearize(); 

% create a PID controller
% Pendulum_sys.removeOutput('myPendulum_Position');
% Pendulum_sys.createPIDController();
          
% create foll state feedback controller
% Pendulum_sys_lin.createFSF();

% create optimal controller (standard method, maxval method, manually method)
% Pendulum_sys_lin.createLQR();
% Pendulum_sys_lin.createLQR('method','max','maxinputs',20,'maxstates',[.6 5 .174533 5]);
% Pendulum_sys_lin.createLQR('method','man','R',1,'Q',[5000 0 0 0; 0 0 0 0; 0 0 100 0; 0 0 0 0]);

