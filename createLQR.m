function createLQR (obj,varargin)
% Creates a linear quadradic controller.
%
% SYNTAX
%   obj.createLQR();
%   obj.createLQR(method);
%
% INPUT ARGUMENTS
%   obj:    Instance of the class ODESCA_Linear
%
% OPTIONAL INPUT ARGUMENTS
%    varargin:   array with the method name and following arguments (see:
%                example)
%
%     Options:
%     =====================================================================
%     method           |  arguments     | type          | description
%     =================|================|===============|==================
%     'auto' (default) | ~              | ~             | generate R and Q
%                      |                |               | automatically
%     -----------------|----------------|---------------|------------------
%     'man'            | R              | nxn matrix    | manually set R
%                      | Q              | mxm matrix    | and Q
%     -----------------|----------------|---------------|------------------
%     'max'            | maxinputs      | n vector      | manually set the
%                      | maxstates      | m vector      | maximum values of
%                      |                |               | inputs and states
%                      |                |               | to generate R and
%                      |                |               | Q automatically
%
%     where n is the size of inputs and m the size of states
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   This function creates a linear quadratic controller with
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
%     sys_lin.createLQR();
%     % or
%     % sys_lin.createLQR('man',1,[10 0 0 0; 0 0 0 0; 0 0 100 0; 0 0 0 0]);
%     % or
%     % sys_lin.createLQR('max',20,[.6 1 .05 1]);

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

%% Set the default arguments for the method
defaultmethod   = 'auto';

%% Check of the conditions

% Check if a nonlinear Simulink Model already exists
if (exist(obj.steadyState.system.name) == 4)
    error('ODESCA_Linear:createLQR:simulinkModelWithSameNameExists','A Sinmulink Model with the same name already exists.');
end

% Check number and data types of inputs and set method
if (nargin == 1) % no other inputs than obj
    method = defaultmethod;
else % other inputs than obj
    % check method data type
    if (~ischar(varargin{1}) || size(varargin{1},1) ~= 1 )
        error('ODESCA_Linear:createLQR:methodNotAString','The method is no string. You can decide between ''auto'',''man'' or ''max''. See description of this function.');
    end
    if (nargin == 2)
        % check if method is correct
        if ~strcmp(varargin{1},'auto')
            error('ODESCA_Linear:createLQR:wrongMethodName',['The method ',varargin{1},' is not available. You can decide between ''auto'',''man'' or ''max''. See description of this function.']);
        else
            method = varargin{1};
        end
    elseif (nargin == 4)
        % check if method is correct
        if ~(strcmp(varargin{1},'man') || strcmp(varargin{1},'max'))
            error('ODESCA_Linear:createLQR:wrongMethodForNumberOfArguments','Wrong method name for the number of input arguments. You can decide between ''auto'',''man'' or ''max''. See description of this function.');
        else
            method = varargin{1};
        end
    else
        error('ODESCA_Linear:createLQR:wrongNumberOfArguments','Wrong number of input arguments.');
    end
end

% Check every method
switch method
    case 'man'
        % check data type of R and Q
        if ~isnumeric(varargin{2}) || ~isnumeric(varargin{3})
            error('ODESCA_Linear:createLQR:argumentsNotNumeric','The user input of R and Q is not numeric.');
        end
        % check size of R
        if ~(size(varargin{2},1) == length(obj.steadyState.system.u) && size(varargin{2},2) == length(obj.steadyState.system.u))
            error('ODESCA_Linear:createLQR:wrongInputNumber','The matrix R has to be nxn with n being the number of inputs of the system.');
        end
        % check size of Q
        if ~(size(varargin{3},1) == length(obj.steadyState.system.x) && size(varargin{3},2) == length(obj.steadyState.system.x))
            error('ODESCA_Linear:createLQR:wrongInputNumber','The matrix Q has to be mxm with m being the number of states of the system.');
        end
        % check Inf or NaN
        if (any(any(isnan(varargin{2}))) || any(any(isinf(varargin{2}))) || any(any(isnan(varargin{3}))) || any(any(isinf(varargin{3}))))
            error('ODESCA_Linear:lqreg:matricesContainInfOrNan','The matrices R and Q must not contain NaN or Inf.')
        end
        % check positive definite
        if (any(real(eig(varargin{2}))<0) || any(real(eig(varargin{3}))<0) || any(any(varargin{2}~=varargin{2}')) || any(any(varargin{3}~=varargin{3}')))
            error('ODESCA_Linear:lqreg:matricesNotSymPosDef','The matrices R and Q have to be symmetric positive definite.')
        end
    case 'max'
        % check data type of maxinputs and maxstates
        if ~isnumeric(varargin{2}) || ~isnumeric(varargin{3})
            error('ODESCA_Linear:createLQR:argumentsNotNumeric','The user input of maxinputs and maxstates is not numeric.');
        end
        % check size of maxinputs
        if ~(length(varargin{2}) == length(obj.steadyState.system.u) && isvector(varargin{2}))
            error('ODESCA_Linear:createLQR:wrongInputNumber','The number of elements in the vector maxinputs has to match the number of inputs of the system.');
        end
        % check size of maxstates
        if ~(length(varargin{3}) == length(obj.steadyState.system.x) && isvector(varargin{3}))
            error('ODESCA_Linear:createLQR:wrongInputNumber','The number of elements in the vector maxstates has to match the number of states of the system.');
        end
        % check Inf or NaN
        if (any(isnan(varargin{2})) || any(isinf(varargin{2})) || any(isnan(varargin{3})) || any(isinf(varargin{3})))
            error('ODESCA_Linear:lqreg:vectorsContainInfOrNan','The vectors maxinputs and maxstates must not contain NaN or Inf.');
        end
        % check positive 
        if (any(varargin{2})<0 || any(varargin{3})<0)
            error('ODESCA_Linear:lqreg:vectorsNegative','The vectors maxinputs and maxstates have to be positive.');
        end
    otherwise % auto
        % do nothing
end

% Check if system is contollable
if ~obj.isControllable
    error('ODESCA_Linear:createLQR:notControllable','The System is not controllable.');
end

%% Warnings
if ~(numel(obj.steadyState.system.u) == numel(obj.steadyState.system.g))
    warning('ODESCA_Linear:createLQR:precompensationNotPossible','Calculating a precompensation matrix is not possible due to different I/O dimensions.');
end

%% Evaluation of the task

switch(method)
    case 'auto'
        Q = obj.C'*obj.C;
        R = eye(numel(obj.steadyState.system.u));
    case 'man'
        R = varargin{2};
        Q = varargin{3};
    case 'max'
        r = 1./(varargin{2}.^2); % weighted by maximum inputs
        R = diag(r);
        q = 1./(varargin{3}.^2); % weighted by maximum states
        Q = diag(q);
end

%create K Matrix
obj.K = lqr(obj.A,obj.B,Q,R);

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