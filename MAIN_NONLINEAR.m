%% Setup
clc; close all; 

run('+ConsensusMAS/Models/NonLinear/QuadrotorTest')
%run('+ConsensusMAS/Models/NonLinear/HoverCraft')

%% Run the simulation
clc; import ConsensusMAS.*;

if ~exist('network_map', 'var')
    network_map = containers.Map;
end

% Load the model
ts = 1/1e2;
runtime = 20;

trigger_type = ImplementationsEnum.FixedTrigger;
%controller_type = ControllersEnum.Smc;
controller_type = ControllersEnum.GainScheduled;
key = sprintf("%s-%s", string(trigger_type), string(controller_type));

% Wind model
global wind;
wind = Wind( ...
    WindModelEnum.None,  ...
    27.47, ... % lat brisbane
    153.02, ... % long brisbane
    1000, ... %altitude
    0, ... % start time
    ts ...
);

% Run the simulation;
%global network;
network = Network( ...
            trigger_type,  ... % Which type of agent
            states,  ... % States function
            Af, Bf,  ... % Gain function 
            controller_type, ...
            controller_struct, ...
            numstates,  ... % number of states
            numinputs,  ... % number of inputs
            X0,  ... % Matrix of initial states (len(x) * N)
            ref,  ...  % Relative setpoint funtion
            set,  ... % Fixed setpoint function
            ts, ... % Time step
            wind_states ... % Velocity states
        );

    

vl_states = @(x, u) [1; 0; 1; 0; 0; 0];
vl_numstates = 6;
vl_x0 = [1; 0; 0; 0; 0; 0];
    
% Simulate with switching toplogies
network.ADJ = RandAdjacency(SIZE, 'directed', 0, 'weighted', 0, 'strong', 1);
%{
network.ADJ = [0 0 0 0 0 1;
               0 0 0 0 0 1;
               0 0 0 0 0 1;
               0 0 0 0 0 1;
               0 0 0 0 0 1;
               0 0 0 0 0 0];
               %}
%network.add_leader(vl_states, vl_numstates, vl_x0);
for i = 1:1
    network.Simulate('Fixed', 'time', runtime);
end

network_map(key) = network;


%figure, hold on, grid on;
%plot(network.virtual_agents.X(1,:))
%plot(network.virtual_agents.X(3,:))

%network.NetworkCompare(network_map)

%keys = network_map.keys
%network = network_map('GlobalEventTrigger-Smc')

%network.PlotGraph;
network.PlotStates;
network.PlotInputs; 
%network.PlotTriggers;
%network.PlotTriggersStates;
%network.PlotTriggersInputs;
%network.Plot3("state1", 1, "state2", 3);
%network.PlotErrors;
%network.PlotErrorsNorm("subplots", "none");
%network.PlotErrorsNorm("subplots", "states");
%network.Animate("title", "tester", "states", [1, 3]);