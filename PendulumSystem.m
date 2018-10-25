%% Parameters

MyPendulum = OCLib_Pendulum('Pendulum');

MyPendulum.setParam('M0',4);
MyPendulum.setParam('M1',.36);
MyPendulum.setParam('l_s',.451);
MyPendulum.setParam('theta',.08433);
MyPendulum.setParam('Fr',10);
MyPendulum.setParam('C',.00145);
MyPendulum.setParam('g',9.81);

PendulumSys = ODESCA_System('MyPendulumSys',MyPendulum);

%% Tasks

% find all steadyStates
PendulumSys.calculateValidSteadyStates();

% create a steadystate
ss1 = PendulumSys.createSteadyState([0,0,0,0],0,'ss1');
% linearize
sys_lin = ss1.linearize(); 

% create a PID controller
% PendulumSys.createPIDController();
          
% create pole placement controller
% sys_lin.createPolePlacement();

% create optimal controller (standard method, maxval method, manually method)
% sys_lin.createLQR();
% sys_lin.createLQR('method','maxval','maxinputs',20,'maxstates',[.6 0 .174533 0]);
% sys_lin.createLQR('method','manually','R',1,'Q',[5000 0 100 0]);

