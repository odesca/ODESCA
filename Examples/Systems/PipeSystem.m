% Example Application
% 
% This example consists of two components: a simple pipe with two nodes and
% a temperature sensor at the outlet of the pipe. The example shows how to
% create the components, connect them into a system and hot to use some of
% the provided analysis methods.

%% --- Create components:
% First an instance of the component is created. Then, all parameters are
% set with numeric values. 
TSens = OCLib_TSensor('MyTSens');
TSens.setParam('Gain', 1);
TSens.setParam('TimeConst', 2);

Pipe = OCLib_Pipe('MyPipe');
Pipe.setConstructionParam('Nodes',2);
Pipe.setParam('cPipe',500);
Pipe.setParam('mPipe',0.5);
Pipe.setParam('VPipe',0.001);
Pipe.setParam('RhoFluid', 998);
Pipe.setParam('cFluid',4182);

%% --- Create system:
PipeSys = ODESCA_System('MySystem',TSens);
PipeSys.addComponent(Pipe);

PipeSys.connectInput('MyTSens_TempIn','MyPipe_TempOut');

PipeSys.removeOutput('MyPipe_mDotOut');
PipeSys.removeOutput('MyPipe_TempOut');

%% --- Create steady state:
% Input values for steady state: u0 = [Temperatur In, Massflow In]
u0 = [40; 0.1];
% Solve the system equations for the states at the given input values
steadystate = vpasolve(subs(PipeSys.calculateNumericEquations,PipeSys.u,u0),PipeSys.x);
x0(1,1) = steadystate.x1;
x0(2,1) = steadystate.x2;
x0(3,1) = steadystate.x3;
x0 = double(x0);

ss1 = PipeSys.createSteadyState(x0,u0,'ss1');

%% Linear approximation
% Create linear approximation of the system in the steady state ss1
disp('Linear state space system:')
sys_lin = ss1.linearize();
A = sys_lin.A
B = sys_lin.B
C = sys_lin.C
D = sys_lin.D

% Preforme linear analysis
stable = sys_lin.isAsymptoticStable();
obsv = sys_lin.isObservable('hautus');
ctrl = sys_lin.isControllable('hautus');

% Create more steady states and plot a bode plot with all steady
% states of the system:
u0_2 = [40; 0.2];
steadystate = vpasolve(subs(PipeSys.calculateNumericEquations,PipeSys.u,u0_2),PipeSys.x);
x0_2(1,1) = steadystate.x1;
x0_2(2,1) = steadystate.x2;
x0_2(3,1) = steadystate.x3;
x0_2 = double(x0_2);
ss2 = PipeSys.createSteadyState(x0_2,u0_2,'ss2');

u0_3 = [40; 0.25];
steadystate = vpasolve(subs(PipeSys.calculateNumericEquations,PipeSys.u,u0_3),PipeSys.x);
x0_3(1,1) = steadystate.x1;
x0_3(2,1) = steadystate.x2;
x0_3(3,1) = steadystate.x3;
x0_3 = double(x0_3);
ss3 = PipeSys.createSteadyState(x0_3,u0_3,'ss3');

% Linearize all steady states and create a bodeplot
lin = PipeSys.steadyStates.linearize();
lin.bodeplot('from',1,'to',1);

%% Bilinear approximation
sys_bilin = ss1.bilinearize();

%% CASADI Example
[f,g] = PipeSys.createMatlabFunction();

% The rest of the example cited in the paper can be found in the example
% "direct_single_shooting.m" from
%
% J. Andersson, J. kesson, and M. Diehl, “Dynamic optimization with
% CasADi,” in 2012 IEEE 51st IEEE Conference on Decision and
% Control (CDC), Dec 2012, pp. 681–686.

%% Create nonlinear simulink model
PipeSys.createNonlinearSimulinkModel();