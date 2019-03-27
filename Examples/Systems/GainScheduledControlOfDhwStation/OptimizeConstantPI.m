%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This example calculates PI control parameter 
% for the example system of a domestic hot water station.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% YALMIP and MOSEK is required to be installed!

% Trucated matrices are used in accordance to the paper:
% "Gain Scheduled Control of Bounded Multilinear Discrete Time Systems
% with Uncertanties: An Iterative LMI Approach" - submitted to 2019 
% IEEE Conference on Descision and Control (CDC)

% load system matrices given in paper
LoadTruncatedSystemMatrices;
% start measureing the time
tic

% Define size of system
n = length(A_0);

%% Define decision variables
% Control parameters
Kp = sdpvar(1,1);

Ki = sdpvar(1);

% lyapunov function
P = sdpvar(n+1);

%% Initialize algorithm

% lyapunov function of last/initial iteration
PBest = eye(n+1);
InvP = inv(PBest);
% best alpha found for the last feasible solution
alphaBest = 0;
deltaAlpha = 1;
alpha = 0;
% define MOSEK to be used as optimizer!
ops = sdpsettings('solver','mosek','verbose',0);

EpsDeltaAlpha = 1e-9;
maxNumberIterations = 3000;

% run optimization until maximum number of iterations or deltaAlpha < EpsDeltaAlpha reached
for PI_i = 2:maxNumberIterations   
    % define constraint for the lyapunov function
    Constr = [P >= 0];
    % setup the 2^p constraints (min and max for one disturbance in each for loop)
    for d1 = d1_min:(d1_max-d1_min):d1_max
          for d3 = d3_min:(d3_max-d3_min):d3_max
                for d4 = d4_min:(d4_max-d4_min):d4_max
                    % multilinear structure of controller
                    Kp_ml = Kp;
                    Ki_ml = Ki;
                    % multilinear structure of input matrix
                    B_ml = B_0;
                    % multilinear structure of system matrix
                    A_ml = A_0 + d1*A_1 + d3*A_3+ d4*A_4;

                    % With integrator state augmented closed loop system        
                    Ages = [    A_ml - B_ml*(Kp_ml)*C,   B_ml*Ki_ml; ...
                                        -C,                1];
                    % Setup as LMI 
                    Constr = Constr +  [ [(2*InvP-InvP*P*InvP),   alpha*Ages; alpha*Ages', P]     >=  0]; 

                end
          end
    end
    % search for feasible solution of the problem
    diagnostics = optimize(Constr,[],ops)
    
    if (diagnostics.problem ~=0 )
    % Problem was not feasible
        deltaAlpha = deltaAlpha*0.5;
        alpha = alpha - deltaAlpha;% --> this is different from Algorithm 1 presented in the paper (will be corrected)
        if (deltaAlpha < EpsDeltaAlpha )
            % stop optimization due to minumum deltaAlpha
            break;     
        end
   
    else
        % set new alphaBest 
        alphaBest = alpha;
        % set new corresponding lyapunov function
        PBest = double(P);
        % calculate inverse of lyapunov function matrix
        InvP = inv(PBest);
        % increase delta Alpha
        deltaAlpha = 2*deltaAlpha;
        alpha = alpha + deltaAlpha; % --> this is different from Algorithm 1 presented in the paper (will be corrected)
        % save best result into different variables
        PI_alpha    = alphaBest;
        PI_P        = PBest;
        PI_Kp       = double(Kp);
        PI_Ki       = double(Ki);

   end

%% Diagnosis and statistics
diagnosisLog(PI_i) = diagnostics.problem;
alphaLog(PI_i) = alpha;
display('-------------------------Info--------------------------');
fprintf('Iteration: %1.1f \n', PI_i);
fprintf('alpha: %2.10f \n', alpha);
fprintf('alphaBest: %2.10f \n', alphaBest);
fprintf('deltaAlpha: %2.10f \n', deltaAlpha);
display('-------------------------------------------------------');


end

% get the time needed to finish the optimization
PI_time = toc;
% save the results into a file
save('PI.mat','PI_alpha','PI_P','PI_Kp','PI_Ki','PI_i','PI_time');







