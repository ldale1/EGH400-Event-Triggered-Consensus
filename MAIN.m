% Cleanup
clc; close all; clear all;

%%
SIZE = 4;
A = [0 1 1 1; 1 0 0 0; 1 0 0 0; 1 0 0 0];
X0 = 1:4;

%% RAND
SIZE = 3;
A = max(((randi(2, SIZE, SIZE) - 1) - eye(SIZE)), zeros(SIZE, SIZE));
X0 = randi(SIZE*2, 1, SIZE) - SIZE*2/2;

%% TOY
SIZE = 6;
A = [0 1.5 0 0 0 0; 2 0 0 0 0 0; 0.9 0 0 0 1.9 0;
        0 1.2 0 0 0 1.3; 0 0 1.4 1.8 0 0; 0 0 0 0 0.7 0];
X0 = 0.2*(1:SIZE) - 0.1;

%% Simulation
import ConsensusMAS.*;

% Create the finite time network
network = NetworkFT(A, X0);
network.Simulate('timestep', 0.1, 'mintime', 10);
network.PlotGraph;
network.PlotEigs;
network.PlotStates("plottype", "plot");
network.PlotInputs("plottype", "plot");