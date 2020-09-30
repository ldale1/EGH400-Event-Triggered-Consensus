% Cleanup
clc; close all;

   
%% TOY
SIZE = 4;
A = [0 1 1 4;
     1 0 1 1;
     2 1 0 1;
     0 0 3 0];

X0 = 0.2*(1:SIZE) - 0.1;

%% Simulation
import ConsensusMAS.*;
import ConsensusMAS.Utils.*;

% Create the finite time network
network = Network(Implementations.GlobalEventTrigger, A, X0);
network.Simulate('timestep', 10e-3, 'mintime', 20, 'maxsteps', 1e4);
%network.PlotGraph;
%network.PlotEigs;
%network.PlotInputs;
network.PlotStates;
network.PlotTriggers
%network.PlotTriggersStates


