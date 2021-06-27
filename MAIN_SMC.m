%% Model
clc; 
import ConsensusMAS.Scenarios.*;


scenario = "Report_VConsensusAlgorithmExploration";
scenario = "smc_ex";
scenario = "random";
scenario = "current";

dynamic = 0;

switch scenario
    case "random"
        % Fresh Scenario+
        model = "HoverCraft_8";
        model= "LinearTest";
        model = "HoverCraft";
        model = "QuadrotorTest";
        model= "Linear2D";
        model= "Linear1D";
        
        run(path_model(model)); 
        
        % Get the vars
        SIZE = 3;
        X0 = X_generator(SIZE);
        ADJ = RandAdjacency(SIZE, 'directed', 0, 'weighted', 0, 'strong', 1);
        ts = 1/1e2;
        runtime = 10;
        
        % Save for later
        scenario_save("current", model, X0, ADJ, ts, runtime);
        
    otherwise
        % Load preserved
        load(path_save(scenario + ".mat"), '*')
        ts = 0.001;
        runtime = 4*pi;
        %ts = ts/10;
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

% Wind
wind_type = WindModelEnum.Constant;
wind_type = WindModelEnum.None;
wind_type = WindModelEnum.Sinusoid;







%% Run the simulation
clc; 
import ConsensusMAS.*;

global eta;
eta = 0;

global seta;
seta = 2;

for controller_type = [ControllersEnum.Smc] % ControllersEnum.GainScheduled,  
    
    
    switch (controller_type)
        case ControllersEnum.Smc
            trigger_type = ImplementationsEnum.GlobalEventTrigger_Aug;


        otherwise
            trigger_type = ImplementationsEnum.GlobalEventTrigger;
        
    end

    key = sprintf("%s-%s", string(trigger_type), string(controller_type));
    if ~exist('network_map', 'var')
        network_map = containers.Map;
    end

    % Wind model
    global wind;
    wind = Wind( ...
        wind_type,  ...    % Which model we using.. ?
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
   
    
    
    if ~dynamic
        % Simulate with switching toplogies
        for i = 1:1
            network.Simulate('Fixed', 'time', runtime);
        end
    else
        % Simulate with switching toplogies
        network.SimulateDynamic('Fixed', 'time', runtime);
    end

    % Save fo   r later
    network_map(key) = network;

    
    network.PlotTriggersStates('disturbance', 1);
    
    network.PlotCompact('disturbance', 1);
    
    
     
    %{
    subplot(2,2,[2,4])
    
    

    switch (controller_type)
        case ControllersEnum.Smc
            hold on;
            plot([-1, 5], [1, -5], '--', ...
                'DisplayName', 'Hyperplane')
            plot(network.agents(1).X(1,:), network.agents(1).X(2,:),...
                'LineWidth', 2, 'DisplayName', 'State Trajectories'); 
            legend('AutoUpdate','off')

            grid on;

            title('Phase Portrait')
            xlabel('x_1','fontweight','bold')
            ylabel('x_2','fontweight','bold')
            ax = gca;
            ax.XAxisLocation = 'origin';
            ax.YAxisLocation = 'origin';
            
            figure()
            plot(network.T(1:end-1), network.agents(1).SLIDE)
            grid on
            xlabel('Time (s)')
            ylabel('Value')
            title('Sliding Variable')

        otherwise
            % Custom plot
            hold on;
            plot(network.agents(1).X(1,:), network.agents(1).X(2,:),...
                'LineWidth', 2, 'DisplayName', 'State Trajectories'); 

            grid on;

            title('Phase Portrait')
            xlabel('x_1','fontweight','bold')
            ylabel('x_2','fontweight','bold')
            ax = gca;
            ax.XAxisLocation = 'origin';
            ax.YAxisLocation = 'origin';  
    
        
    end
    %}
    
    for agent = network.agents
        agent.ERROR(:,1) = zeros(2,1);
    end
    
    network.PlotErrors
    network.PlotTriggersStates
    
end