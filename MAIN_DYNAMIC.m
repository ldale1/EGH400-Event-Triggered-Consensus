%% Model
clc; 
import ConsensusMAS.Scenarios.*;


scenario = "Report_VConsensusAlgorithmExploration";
scenario = "random";
scenario = "current";
scenario = "quadplot";

dynamic = 0;

switch scenario
    case "random"
        % Fresh Scenario+
        model = "HoverCraft_8";
        model= "LinearTest";
        model= "Linear2D";
        model= "Linear1D";
        model= "NonlinearTest";
        model = "QuadrotorTest";
        model = "HoverCraft";
        
        run(path_model(model)); 
        
        % Get the vars
        SIZE = 3;
        X0 = X_generator(SIZE);
        ADJ = RandAdjacency(SIZE, 'directed', 0, 'weighted', 0, 'strong', 1);
        
        %ADJ = [0 1 1 1; 1 0 1 1; 1 1 0 1; 0 0 0 0];
           
        ts = 1/1e2;
        runtime = 15  * 1;
        
        % Save for later
        scenario_save("current", model, X0, ADJ, ts, runtime);
        
    otherwise
        % Load preserved
        load(path_save(scenario + ".mat"), '*')
        %ts = 1/1e2;
        %runtime = 10;
        %ts = ts;
        %runtime = runtime + 20;
        %{
        ADJ = [0 1 0 0 0;
               0 0 1 0 0;
               0 0 0 1 0;
               0 0 0 0 1;
               0 0 0 0 0];
        %}
        
        % Go it
        run(path_model(model));
end


%% Operating Regime 
import ConsensusMAS.ImplementationsEnum;
import ConsensusMAS.ControllersEnum; 
import ConsensusMAS.WindModelEnum;

% Trigger Type
trigger_type = ImplementationsEnum.GlobalEventTrigger_Base;
trigger_type = ImplementationsEnum.LocalEventTrigger;
trigger_type = ImplementationsEnum.FixedTrigger;
trigger_type = ImplementationsEnum.GlobalEventTrigger;
trigger_type = ImplementationsEnum.GlobalEventTrigger_Aug;

% Controller
controller_type = ControllersEnum.PolePlacement;
controller_type = ControllersEnum.GainScheduled;
controller_type = ControllersEnum.Smc;

% Wind
wind_type = WindModelEnum.Constant;
wind_type = WindModelEnum.Sinusoid;
wind_type = WindModelEnum.Basic;
wind_type = WindModelEnum.None;

%% Run the simulation
clc; import ConsensusMAS.*;
key = sprintf("%s-%s", string(trigger_type), string(controller_type));
if ~exist('network_map', 'var')
    network_map = containers.Map;
end

% Wind model
global wind;
wind = Wind( ...
    wind_type,  ...             % Which model we using.. ?
    27.47, 153.02, 1000, ...    % Lat, long, altitude (brisbane)
    0, ts ...                   % Start time and step
);

% Run the simulation;
network = Network( ...
            trigger_type,  ...      % Trigger type struct
            model_struct, ...       % Model data
            controller_type, ...    % Controller type enum
            controller_struct, ...  % Controller data
            sim_struct, ...         % simulation
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

if ~dynamic
    % Simulate with switching toplogies
    for i = 1:1
        network.Simulate('Fixed', 'time', runtime);
    end
else
    % Simulate with switching toplogies
    network.SimulateDynamic('Fixed', 'time', runtime);
end

% Save fo later
network_map(key) = network;

    
%figure, hold on, grid on;
%plot(network.virtual_agents.X(1,:))
%plot(network.virtual_agents.X(3,:))

%network.NetworkCompareError(network_map)
%network.NetworkCompareAgents(network_map, 'plottype', 'reuse')

%network.NetworkCompareAgents(network_map)

%keys = network_map.keys
%network = network_map('GlobalEventTrigger-Smc')

%network.PlotGraph; 
%
%
%network.PlotStates('disturbance', 0);

%tops = length(network.TOPS);
%network.TOPS = network.TOPS(max(1, tops-9):end);
%network.PlotGraph

network.PlotInputs;
network.PlotTriggers;
%network.PlotTriggersStates;
network.PlotStates('disturbance', 1);


%network.PlotErrors;



%network.PlotTriggersInputs; 
%network.Plot3("state1", 1, "state2", 3);
%
%network.PlotErrorsNorm("subplots", "none");
%network.PlotErrorsNorm("subplots", "states");
%network.Animate("title", "tester", "states", [1, 3]);

%figure
%plot(network.T(1:end-1), network.agents(1).SLIDE)


band = ts*controller_struct.k/(1-ts*controller_struct.tau);
band * 1e3

figure
plot(network.T(1:end-1), network.agents(1).SLIDE)
grid on;