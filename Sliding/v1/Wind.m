classdef Wind
    
    properties (Access = private)
        lat % latitude
        long % longitudde
        alt % altitude
        p % air density
        
        time % time
        ts % time step
        
        meridional % east
        zonal % north
    end

    
    methods
        function obj = Wind(lat, long, alt, time, ts)
            obj.lat = lat;
            obj.long = long;
            obj.alt = alt;
            obj.time = time;
            obj.p = 1.225;
            obj.ts = ts;
            
            obj = obj.set_velocities();
        end
        
        function mf = meridional_force(obj, agent_veloc, Cd, S)
            v = obj.meridional - agent_veloc;
            mf = (obj.p * v^2 * Cd * S) / 2;
        end
        
        function zf = zonal_force(obj, agent_veloc, Cd, S)
            v = obj.zonal - agent_veloc;
            zf = (obj.p * v^2 * Cd * S) / 2;
        end
        
        function obj = step(obj)
            obj.time = obj.time + obj.ts;
            
            obj.set_velocities()
        end
    end
    
    methods (Access = private)
        function obj = set_velocities(obj)
            [obj.meridional, obj.zonal] = atmoshwm(...
                obj.lat, ...
                obj.long, ...
                obj.alt, ...
                'seconds', obj.time,  ...
                'version', '14');
        end
    end
    
end