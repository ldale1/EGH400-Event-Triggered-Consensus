% Setup
clc; close all; import ConsensusMAS.*;

% Load the model
ts = 1/1e3;
run('+ConsensusMAS/Models/Linear/Simple')

% Run the simulation;
wind_model = WindModelEnum.None;
network = Network( ...
            Implementations.GlobalEventTrigger,  ... % Which type of agent
            states,  ... % States function
            numstates,  ... % number of states
            numinputs,  ... % number of inputs
            K,  ... % Gain function 
            X0,  ... % Matrix of initial states (len(x) * N)
            ref,  ...  % Relative setpoint funtion
            set,  ... % Fixed setpoint function
            ts, ... % Time step
            states_vz, ... % Wind disturbance matrix
            wind_model ... % enumerated wind model
        );


    
% Simulate with switching toplogies
network.ADJ = RandAdjacency(SIZE, 'directed', 0, 'weighted', 0, 'strong', 1);
for i = 1:1
    network.Simulate('Fixed', 'time', 25);
end


%network.PlotGraph;
network.PlotStates;
network.PlotInputs;
%network.PlotTriggers;
%network.PlotTriggersStates;
%network.PlotTriggersInputs;
%network.Plot3("state1", 1, "state2", 3);
%network.PlotErrors;
%network.Animate("title", "tester", "state1", 1, "state2", 3);

