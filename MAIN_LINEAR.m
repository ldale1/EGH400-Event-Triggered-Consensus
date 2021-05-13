% Setup
clc; close all; 
import ConsensusMAS.*;

% Load the model
ts = 1/1e2;
run('+ConsensusMAS/Models/Linear/Simple')

SIZE = 6;
%X0 = randi(5*SIZE, numstates, SIZE) - 5*SIZE/2;
%X0(2,:) = X0(2,:) + 10

X0 = [5.5 -4.5 12.5 9.5 -0.5; 9.5 -6.5 -0.5 -1.5 2.5];

% Run the simulation;
%implementation = Implementations.ETSMC;
%implementation = Implementations.FiniteC;


%implementation = Implementations.FixedTrigger;
implementation = Implementations.GlobalEventTrigger;
wind_model = WindModelEnum.Basic;
network = Network( ...
            implementation,  ... % Which type of agent
            states,  ... % States function
            numstates,  ... % number of states
            numinputs,  ... % number of inputs
            K,  ... % Gain function 
            X0,  ... % Matrix of initial states (len(x) * N)
            ref,  ...  % Relative setpoint funtion
            set,  ... % Fixed setpoint function
            ts, ... % Time step
            wind_states, ... % Wind disturbance matrix
            wind_model ... % enumerated wind model
        );


    
% Simulate with switching toplogies
network.ADJ = RandAdjacency(SIZE,'directed',0,'weighted',0,'strong',1);
for i = 1:1
    network.Simulate('Fixed', 'time', 15);
end


%network.PlotGraph;
%network.PlotStates;
%network.PlotInputs;
%network.PlotTriggers;
network.PlotTriggersStates;
network.PlotTriggersInputs;

%network.Plot3("state1", 1, "state2", 3);
%network.PlotErrors;
%network.Animate("title", "tester", "state1", 1, "state2", 3);

