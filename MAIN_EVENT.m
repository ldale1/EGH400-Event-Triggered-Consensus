% Cleanup
clc; close all;

   
%% TOY
SIZE = 6;
A = [0 1.5 0 0 0 0; 2 0 0 0 0 0;  0.9 0 0 0 1.9 0; 
    0 1.2 0 0 0 1.3; 0 0 1.4 1.8 0 0; 0 0 0 0 0.7 0];

X0 = 0.2*(1:SIZE) - 0.1;

%% Simulation
import ConsensusMAS.*;
import ConsensusMAS.Utils.*;

% Create the finite time network
network = Network(Implementations.GlobalEventTrigger, A, X0);
network.Simulate('timestep', 10e-3, 'mintime', 20, 'maxsteps', 1e4);
%network.PlotGraph;
%network.PlotEigs;
%network.PlotInputs("plottype", "plot");
%network.PlotStates("plottype", "plot");
%network.PlotTriggers
network.PlotTriggersStates

