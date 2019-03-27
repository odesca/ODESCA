%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This example represents a domestic hot water station:
% Hot water from a central heating water storage is used to heat up
% domestic fresh water with a plate heat exchanger. In this example only
% the pump can be manipulated to control the temperautre of the domestic
% hot water.
%
% "Gain Scheduled Control of Bounded Multilinear Discrete Time Systems
% with Uncertanties: An Iterative LMI Approach" - submitted to 2019 
% IEEE Conference on Descision and Control (CDC)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Use existing components to compose a system representing a DHW-station
% plate heat exchanger
phex = OCLib_PlateHex('phex');
% set construction parameter
phex.setConstructionParam('Nodes',3);
% set all component parameter
phex.setParam('cHex', 500);             
phex.setParam('mHex', 1.154);       
phex.setParam('Volume1', 0.216*10^(-3));
phex.setParam('Volume2', 0.24*10^(-3));
phex.setParam('HexArea', 0.216);
phex.setParam('RhoFluid', 998);
phex.setParam('cFluid', 4182);   

% Datafit for the heat exchange coefficient 
k_phex = OCLib_HeatTransferFit('kPhex');
k_phex.setParam('c1', 6529);
k_phex.setParam('c2', 4029);
k_phex.setParam('c3', 3.29);

% Pump
% the pump is simplified:
% The input signal of the pump equals the static massflow it will serve
pump = OCLib_SimplePump('pump');
pump.setParam('TimeConstant',1);
pump.setParam('MassflowMin',0.15);
pump.setParam('MassflowMax',0.35);
pump.setParam('ModulationSpMin',0.15);
pump.setParam('ModulationSpMax',0.35);

%% Create DHW-station system
dhwStation = ODESCA_System('phexSystemdhwSt',phex);
dhwStation.addComponent(k_phex);
dhwStation.addComponent(pump);

% connect inputs
dhwStation.connectInput('phex_Massflow1In','kPhex_Massflow1Out')
dhwStation.connectInput('phex_Massflow2In','kPhex_Massflow2Out')
dhwStation.connectInput('kPhex_Massflow1In','pump_Massflow');
dhwStation.connectInput('phex_kHex','kPhex_k_Hex')

% remove all unnecessary outputs
dhwStation.removeOutput('phex_Temperature1Out');
dhwStation.removeOutput('phex_Massflow1Out');
dhwStation.removeOutput('phex_Massflow2Out');
dhwStation.removeOutput('kPhex_k_Hex');
dhwStation.removeOutput('kPhex_Massflow1Out');
dhwStation.removeOutput('kPhex_Massflow2Out');
dhwStation.removeOutput('pump_Massflow');

% create continouus nonlinear simulation model
%ODESCA_Util.createNonlinearSimulinkModel(dhwStation);

%% Define a steady state for approximation of the system

% Define inputs for the steady state
theta_h = 70;
theta_c = 10;
mdot_c = 0.1;
pumpcontrol = 0.1;
u_0 = [theta_h; theta_c; mdot_c; pumpcontrol];
% get matlab functions handles of system equations to find x0
[f_temp g_temp] = dhwStation.calculateNumericEquations();

steadystate = vpasolve(subs(f_temp,dhwStation.u,u_0),dhwStation.x);
x_0(1,1) = steadystate.x1;
x_0(2,1) = steadystate.x2;
x_0(3,1) = steadystate.x3;
x_0(4,1) = steadystate.x4;
x_0(5,1) = steadystate.x5;
x_0(6,1) = steadystate.x6;
x_0(7,1) = steadystate.x7;
x_0 = double(x_0);

y_0 = subs(g_temp,dhwStation.x,x_0);
y_0 = double(y_0);

% create steady state in ODESCA
ss1 = dhwStation.createSteadyState(x_0,u_0,'ss1');
% get bilinear representation of system to reformulate it to the
% multilinear representation.
dhwStation_bilin = ss1.bilinearize();


%% setup continuous time multilinear system representation from bilinear representation
% d1: theta_h (Storage-Temperature [°C])
% d2: theta_c (Freshwater-Temperature [°C])
% d3: mdot_c (Freshwater-massflow [kg/s])
% d4: mdot_h / x7 (Massflow served by the pump [kg/s])

% zero matrices are ignored

% input matrix (input is now only the control input)
Bc_0 = dhwStation_bilin.B(:,4);

% disturbance matrices
Gc_1 = dhwStation_bilin.B(:,1);
Gc_2 = dhwStation_bilin.B(:,2);
Gc_3 = dhwStation_bilin.B(:,3);
% Bilinear representation is not unique:
% d2*d3 occurs in G(:,3,2) and G(:,2,3)
Gc_23 = dhwStation_bilin.G(:,2,3) + dhwStation_bilin.G(:,3,2);

Ac_0 = dhwStation_bilin.A;
Ac_1 = dhwStation_bilin.N(:,:,1);
Ac_3 = dhwStation_bilin.N(:,:,3);
% Bilinear representation is not unique M(:,:,1:7) can be represented by
Ac_4 = 2*dhwStation_bilin.M(:,:,7);

Cc = dhwStation_bilin.C;


%% Discretize the system matrices (euler)
dt = 0.1;

B_0 = Bc_0*dt;

G_1 = Gc_1*dt;
G_2 = Gc_2*dt;
G_3 = Gc_3*dt;
G_23 = Gc_23*dt;

A_0 = eye(length(Ac_0)) + Ac_0*dt;
A_1 = Ac_1*dt;
A_3 = Ac_3*dt;
A_4 = Ac_4*dt;

C = Cc;





