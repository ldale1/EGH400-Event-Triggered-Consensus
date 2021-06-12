classdef Wind < ConsensusMAS.RefClass
    
    
    properties
        lat % latitude
        long % longitudde
        alt % altitude
        p % air density
        
        time % time
        ts % time step
        
        meridional % east m/s
        zonal % north m/s
        
        model_enum
    end
   
    
    methods
        function obj = Wind(model_enum, lat, long, alt, time, ts)
            obj.model_enum = model_enum;
            obj.lat = lat; % latitude
            obj.long = long; % longitude
            obj.alt = alt; % altitude
            
            obj.p = 1.225; % density of air
            obj.time = time; % sim time
            obj.ts = ts; % time step
            
            obj.set_velocities();
        end
        
        function forces = forces(obj, agent)
            % Cd is drag coefficient
            % S is effective aperture
            import ConsensusMAS.WindModelEnum;
            
            switch (obj.model_enum)
                case WindModelEnum.Basic
                    Cd = agent.Cd;
                    S  = agent.sa;
                    states_vz = agent.x(agent.ss.wind_states);
                    
                    % Do we have the right states
                    switch (length(states_vz))
                        % Syntax ??
                        case 1
                            vx = states_vz(1);
                            vy = 0;
                        case 2
                            vx = states_vz(1);
                            vy = states_vz(2);
                        otherwise
                            vx = 0;
                            vy = 0;
                    end

                    mf = obj.meridional_force(vx, Cd, S);
                    zf = obj.zonal_force(vy, Cd, S);
                    forces = [mf; zf];
                
                case WindModelEnum.Constant
                    forces = [1; 1];
                    
                    
                case WindModelEnum.Sinusoid
                    forces = [0.5*sin(obj.time/2); 0.5*cos(obj.time)];
                
                otherwise
                    forces = [0; 0];     
            end
            
            forces = agent.Dw * forces;
        end
        
        function mf = meridional_force(obj, agent_veloc, Cd, S)
            v = agent_veloc - obj.meridional;
            mf = sign(v) * (obj.p * v^2 * Cd * S) / 2;
        end
        
        function zf = zonal_force(obj, agent_veloc, Cd, S)
            v = agent_veloc - obj.zonal;
            zf = sign(v) * (obj.p * v^2 * Cd * S) / 2;
        end
        
        function step(obj)
            obj.time = obj.time + obj.ts;
            if (obj.model_enum == ConsensusMAS.WindModelEnum.Basic)
                obj.set_velocities();
            end
        end
    end
    
    methods (Access = private)
        function set_velocities(obj)
            [obj.meridional, obj.zonal] = atmoshwm(...
                obj.lat, ...
                obj.long, ...
                obj.alt, ...
                'seconds', obj.time,  ...
                'version', '14');
        end
    end
    
end