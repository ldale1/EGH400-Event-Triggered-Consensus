% Setup
clc; close all; import ConsensusMAS.*;

if ~exist('network_map', 'var')
    network_map = containers.Map;
end

% Load the model
ts = 2.5/1e2;
run('+ConsensusMAS/Models/NonLinear/Copy_of_HoverCraft')

trigger_type = ImplementationsEnum.GlobalEventTrigger;
controller_type = ControllersEnum.GainScheduled;
key = sprintf("%s-%s", string(trigger_type), string(controller_type));

% Run the simulation;

X0 = X_generator(9);

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
            WindModelEnum.None ... % enumerated wind model
        );

 
% Simulate with switching toplogies
network.SimulateDynamic('Fixed', 'time', 60);

network_map(key) = network;

%network.PlotGraph;
network.PlotStates;
%network.PlotInputs;
%network.PlotTriggers;
%network.PlotTriggersStates;
%network.PlotTriggersInputs;
%network.Plot3("state1", 1, "state2", 3);
%network.PlotErrors;
%network.PlotErrorsNorm("subplots", "none");
%network.PlotErrorsNorm("subplots", "states");
network.Animate("title", key, "states", [1 4]);