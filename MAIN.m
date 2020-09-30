% Cleanup
clc; close all;

%% TOY
SIZE = 10;
A = (ones(SIZE, SIZE) - eye(SIZE)) .* magic(SIZE)/SIZE;
X0 = randi(2*SIZE, 2, SIZE) - SIZE;

%% Simulation
import ConsensusMAS.*;
import ConsensusMAS.Utils.*;

% Create the finite time network
network = Network(Implementations.GlobalEventTrigger, A, X0);
network.Simulate('timestep', 10e-3, 'mintime', 3, 'maxsteps', 3e3);
network.PlotGraph;
network.PlotStates;

network.PlotTriggers
network.Animate;

