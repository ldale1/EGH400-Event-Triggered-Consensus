%% Model
clear all; clc; 
import ConsensusMAS.Scenarios.*;

scenario = "random";
%scenario = "currentx";
scenario = "Report_VConsensusAlgorithmExploration";


switch scenario
    case "random"
        % Fresh Scenario
        model = "QuadrotorTest";
        run(path_model(model));
        
        % Get the vars
        X0 = X_generator(SIZE);
        ADJ = RandAdjacency(SIZE, 'directed', 0, 'weighted', 0, 'strong', 1);
        ts = 1/1e2;
        runtime = 20;

        % Save for later
        scenario_save("current", model, X0, ADJ, ts, runtime);
        
    otherwise
        % Load preserved
        load(path_save(scenario + ".mat"), '*')
        
        % Go it
        run(path_model(model));
end


%% Operating Regime 
import ConsensusMAS.ImplementationsEnum;
import ConsensusMAS.ControllersEnum; 

% Trigger Type
%trigger_type = ImplementationsEnum.FixedTrigger;
trigger_type = ImplementationsEnum.GlobalEventTrigger;

% Controller
controller_type = ControllersEnum.Smc;
%controller_type = ControllersEnum.GainScheduled;


%% Run the simulation
clc; import ConsensusMAS.*;
key = sprintf("%s-%s", string(trigger_type), string(controller_type));
if ~exist('network_map', 'var')
    network_map = containers.Map;
end

% Wind model
global wind;
wind = Wind( ...
    WindModelEnum.None,  ...    % Which model we using.. ?
    27.47, 153.02, 1000, ...    % Lat, long, altitude (brisbane)
    0, ts ...                   % Start time and step
);

% Run the simulation;
network = Network( ...
            trigger_type,  ...      % Trigger type struct
            model_struct, ...       % Model data
            controller_type, ...    % Controller type enum
            controller_struct, ...  % Controller data
            X0,  ...                % Matrix of initial states (len(x) * N)
            ref,  ...               % Relative setpoint funtion
            set,  ...               % Fixed setpoint function
            ts ...                  % Time step
        );

% Simulate with switching toplogies
network.ADJ = ADJ;   

%{
vl_states = @(x, u) [1; 0; 1; 0; 0; 0];
vl_numstates = 6;
vl_x0 = [1; 0; 0; 0; 0; 0];
    
RandAdjacency(SIZE, 'directed', 0, 'weighted', 0, 'strong', 1)
network.ADJ = [0 0 0 0 0 1;
               0 0 0 0 0 1;
               0 0 0 0 0 1;
               0 0 0 0 0 1;
               0 0 0 0 0 1;
               0 0 0 0 0 0];
network.add_leader(vl_states, vl_numstates, vl_x0);
%}

for i = 1:1
    network.Simulate('Fixed', 'time', runtime);
end

% Save for later
network_map(key) = network;


%figure, hold on, grid on;
%plot(network.virtual_agents.X(1,:))
%plot(network.virtual_agents.X(3,:))

%network.NetworkCompare(network_map)

%keys = network_map.keys
%network = network_map('GlobalEventTrigger-Smc')

%network.PlotGraph; 
%network.PlotInputs;
network.PlotStates;
network.PlotTriggers;
%network.PlotTriggersStates;
%network.PlotTriggersInputs;
%network.Plot3("state1", 1, "state2", 3);
%network.PlotErrors;
%network.PlotErrorsNorm("subplots", "none");
%network.PlotErrorsNorm("subplots", "states");
%network.Animate("title", "tester", "states", [1, 3]);