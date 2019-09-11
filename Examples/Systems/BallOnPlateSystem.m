%% Parameters

BOP_comp = OCLib_BallOnPlate('myBallOnPlate');

BOP_comp.setParam('m',0.046);
BOP_comp.setParam('d',0.04267);
BOP_comp.setParam('g',9.81);
BOP_comp.setParam('l_m',0.1405);
BOP_comp.setParam('a',0.1012);
BOP_comp.setParam('Tnx',0.25);
BOP_comp.setParam('Tny',0.2);
BOP_comp.setParam('Pixel',36.5/720);

BOP_sys = ODESCA_System('myBallOnPlateSystem',BOP_comp);

%% Tasks

% create a steadystate
ss = BOP_sys.createSteadyState(zeros(6,1),[0 0] ,'mySteadyState');
% linearize
BOP_sys_lin = ss.linearize();

% create Luenberger Observer
% BOP_sys_lin.createLuenbergerObserver();

% create Kalman Filter
% BOP_sys_lin.createKalmanFilter(eye(6),eye(2));
