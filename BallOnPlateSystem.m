%% Parameters

myBOP = OCLib_BallOnPlate('myBallOnPlate');

myBOP.setParam('m',0.046);
myBOP.setParam('d',0.04267);
myBOP.setParam('g',9.81);
myBOP.setParam('l_m',0.1405);
myBOP.setParam('a',0.1012);
myBOP.setParam('Tnx',0.25);
myBOP.setParam('Tny',0.2);
myBOP.setParam('Pixel',36.5/720);

BOPSys = ODESCA_System('BallOnPlateSys',myBOP);

%% Tasks

% create a steadystate
ss1 = BOPSys.createSteadyState(zeros(6,1),[0 0] ,'ss1');
% linearize
sys_lin = ss1.linearize();

% create Luenberger Observer
% sys_lin.createLuenbergerObserver();

% create Kalman Filter
% sys_lin.createKalmanFilter();
% sys_lin.createKalmanFilter(eye(6),eye(2));
