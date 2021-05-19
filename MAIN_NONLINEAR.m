% Setup
clc; close all; import ConsensusMAS.*;

if ~exist('network_map', 'var')
    network_map = containers.Map;
end

% Load the model
ts = 1/1e2;
run('+ConsensusMAS/Models/NonLinear/Copy_of_HoverCraft')

trigger_type = ImplementationsEnum.FixedTrigger;
controller_type = ControllersEnum.GainScheduled;
key = sprintf("%s-%s", string(trigger_type), string(controller_type));

% Run the simulation;
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
            wind_states, ... % Velocity states
            WindModelEnum.Basic ... % enumerated wind model
        );

 
% Simulate with switching toplogies
network.ADJ = RandAdjacency(SIZE, 'directed', 0, 'weighted', 0, 'strong', 1);
for i = 1:1
    network.Simulate('Fixed', 'time', 20);
end

network_map(key) = network;

%network.PlotGraph;
network.PlotStates;
%network.PlotInputs;
%network.PlotTriggers;
%network.PlotTriggersStates;
%network.PlotTriggersInputs;
%network.Plot3("state1", 1, "state2", 3);
network.PlotErrors;
network.PlotErrorsNorm("subplots", "none");
network.PlotErrorsNorm("subplots", "states");
%network.Animate("title", "tester", "state1", 1, "state2", 4);