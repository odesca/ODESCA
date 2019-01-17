function [Ausgabe,MatrixP,MatrixY] = Parameteridentification(sys,dataname,dataarray)
% This function trys to identify a missing parameter with a dataarray of a
% measurement.
%
% WARNING: Just identify one Parameter exactly. More makes the solution 
%          inaccurate.
%
% INPUT ARGUMENTS
%   sys:      Instance of the class ODESCA_System.
%   dataname: String within the name of the data, which should be an array.
%   dataarry: Array need to have the right structure: 
%   timesteps | U1 | ... | Un | Y1 | ... | Yn 
%   ----------|----|-----|----|----|-----|----
%        0s   |    |     |    |    |     |  
%       ...   |    |     |    |    |     |  
%       end   |    |     |    |    |     |  
%    
%
% OUTPUT ARGUMENTS
%   Ausgabe: Gives the missing parameter back in a array
%   MatrixP: Gives measurementdata of the parameter for a optionl plot
%   MatrixY: Gives measurementdata of the Outputs for a optionl plot
% 
% DESCRIPTION
%   This funktion can identify one or more parameter for a stable system. If
%   you use a instable system, whisch is stabled by a controller, it's
%   important to consider the controller in the differential equations of the system. 
%
%
% EXAMPLE
%   Pipe = OCLib_Pipe('MyPipe');
%   Pipe.setParam('Nodes',2);
%   %Pipe.setParam('Nodes2',6);  -> this parameter will be estimate
%   PipeSys = ODESCA_System('MySystem',Pipe);
%   [Ausgabe,MatrixP,MatrixY] =
%   PipeSys.Parameteridentification('Data',Data)
%
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

%% Find missig parameter and ask for startvalue

ParamAnzahl = numel(sys.p);
StellenMatrix = zeros(ParamAnzahl,1);
AnzahlParamLeer = 0;

z=1;
while z < ParamAnzahl+1
    if isempty(sys.getParam{z}) == 1 
        StellenMatrix(z) = 1;
        AnzahlParamLeer = AnzahlParamLeer+1;
    end
    z=z+1;
end

[egal,ParaName] = sys.getParam;
IRegW = zeros(AnzahlParamLeer,1);
z=1;
z1=1;
P=ParamAnzahl;
while z < P+1 
    if StellenMatrix(z) == 1
        fprintf('Parameterwert für %s ist nicht vorhanden.\n',sys.p(z));
        IRegW(z1) = input('Startwert für Parameterschätzung: ');
        z1=z1+1;
    end
    z=z+1;
end
z=1;
while z < ParamAnzahl+1
    if StellenMatrix(z) == 1
        sys.setParamAsInput(cell2mat(ParaName(z)))
    end
    z=z+1;
end

 %% model creation
 
SysName = sys.name;
InputAnzahl = numel(sys.u)-AnzahlParamLeer
OutputAnzahl = numel(sys.g);

try
    
    %sys.createNonlinearSimulinkModel('notopensimulink',1);
    sys.createNonlinearSimulinkModel();
    
    add_block('simulink/Math Operations/Sum',[SysName,'/Sumy']);
    add_block('simulink/Signal Routing/Mux',[SysName,'/MuxY1']);
    add_block('simulink/Signal Routing/Mux',[SysName,'/MuxY2']);
    add_block('simulink/Signal Routing/Mux',[SysName,'/MuxYS']);
    add_block('simulink/Sinks/Scope',[SysName,'/ScopeY']);
    add_block('simulink/Signal Routing/Mux',[SysName,'/MuxU']);
    add_block('simulink/Signal Routing/Demux',[SysName,'/Demux']);
    add_line([SysName],'MuxY2/1','Sumy/2','autorouting','on');
    add_line([SysName],'MuxY1/1','Sumy/1','autorouting','on');  
    add_line([SysName],'MuxY2/1','MuxYS/1','autorouting','on');
    add_line([SysName],'MuxY1/1','MuxYS/2','autorouting','on');
    add_line([SysName],'MuxYS/1','ScopeY/1','autorouting','on');
    set_param([SysName,'/Sumy'],'Inputs','|+-');
    set_param([SysName,'/ScopeY'],'Open','on');
    set_param([SysName,'/ScopeY'],'SaveToWorkspace','on');
    set_param([SysName,'/ScopeY'],'SaveName','ScopeY');
    set_param([SysName,'/ScopeY'],'DataFormat','Array');
    add_line([SysName],'MuxU/1','Demux/1','autorouting','on');
    %% generic adaptation
    
    z=1;
    if OutputAnzahl > 2
        set_param([SysName,'/MuxY1'],'Inputs',num2str(OutputAnzahl)); %noch für U
        set_param([SysName,'/MuxY2'],'Inputs',num2str(OutputAnzahl));
    end
    while z < OutputAnzahl+1
        add_block('simulink/Sources/From Workspace',[SysName,'/InY',num2str(z)]);
        add_line([SysName],[SysName,'/',num2str(z)],['MuxY1/',num2str(z)],'autorouting','on');
        add_line([SysName],['InY',num2str(z),'/1'],['MuxY2/',num2str(z)],'autorouting','on');
        z=z+1;
    end 
    z=1;
    while z < InputAnzahl+1
        delete_line([SysName],['In_',cell2mat(sys.inputNames(z)),'/1'],[SysName,'/',num2str(z)]);
        delete_block([SysName,'/In_',cell2mat(sys.inputNames(z))]);
        add_block('simulink/Sources/From Workspace',[SysName,'/InU',num2str(z)]);
        add_line([SysName],['Demux/',num2str(z)],[SysName,'/',num2str(z)],'autorouting','on');
        add_line([SysName],['InU',num2str(z),'/1'],['MuxU/',num2str(z)],'autorouting','on');
        z=z+1;
    end
    z=1;
    z1= InputAnzahl+1;
    z2=1;
    x=ones(1,OutputAnzahl); 
    add_block('simulink/Sinks/Scope',[SysName,'/ScopeP']);
    set_param([SysName,'/ScopeP'],'SaveToWorkspace','on');
    set_param([SysName,'/ScopeP'],'Open','on');
    set_param([SysName,'/ScopeP'],'SaveName','ScopeP');
    set_param([SysName,'/ScopeP'],'DataFormat','Array');
    add_block('simulink/Signal Routing/Mux',[SysName,'/MuxP']);
    
    if AnzahlParamLeer > 2
        set_param([SysName,'/MuxP'],'Inputs',num2str(AnzahlParamLeer)); 
    end
    
    add_line([SysName],'MuxP/1','ScopeP/1','autorouting','on');
    
    while z < ParamAnzahl+1
        if StellenMatrix(z) == 1
            delete_line([SysName],['In_',cell2mat(ParaName(z)),'/1'],[SysName,'/',num2str(z1)]);
            delete_block([SysName,'/In_',cell2mat(ParaName(z))]);
            add_block('simulink/Math Operations/Gain',[SysName,'/Matrix',num2str(z)],'Gain',mat2str(x));
            set_param([SysName,'/Matrix',num2str(z)],'Multiplication','Matrix(K*u)');
            add_block('simulink/Continuous/Integrator',[SysName,'/Int',num2str(z)]);
            set_param([SysName,'/Int',num2str(z)],'InitialCondition',num2str(IRegW(z2)));
            add_line([SysName],'Sumy/1',['Matrix',num2str(z),'/1'],'autorouting','on');
            add_line([SysName],['Matrix',num2str(z),'/1']',['Int',num2str(z),'/1'],'autorouting','on');
            add_line([SysName],['Int',num2str(z),'/1']',[SysName,'/',num2str(z1)],'autorouting','on');
            add_line([SysName],['Int',num2str(z),'/1']',['MuxP/',num2str(z2)],'autorouting','on');
            z2=z2+1;
            z1=z1+1;
        end
        z=z+1;
    end
    
    z=1;
    while z < InputAnzahl+1
        set_param([SysName,'/InU',num2str(z)],'VariableName',[dataname,'(:,[1,',num2str(z+1),'])']);
        z=z+1;
    end
    
    z=1;
    z1= InputAnzahl+2;
    while z < OutputAnzahl+1
        set_param([SysName,'/InY',num2str(z)],'VariableName',[dataname,'(:,[1,',num2str(z1),'])']);
        z=z+1;
        z1=z1+1;
    end 
    
    [r,c] = size(dataarray);
    set_param([SysName], 'StopTime',[dataname,'(',num2str(r),')']);

catch err
        % Close the model if the model creation failed
        close_system([SysName],0);
        rethrow(err);
end
%% Simulation 

sim(SysName);
[r,ParaAnzahl] = size(ScopeP);
MatrixP=ScopeP;
MatrixY=ScopeY;
Ausgabe = zeros(ParaAnzahl-1,1);
z=2;

while z < ParaAnzahl+1
    Ausgabe(z-1,1)=ScopeP(r,z);
    z=z+1;
end

%close_system([SysName],0);
end
   
 

    
  
