classdef TaskGPSSpaceSegmentOff<Task
    % Task used to test assertions on DT
    %
    methods (Sealed,Access=public)
                        
        function obj = TaskGPSSpaceSegmentOff(state)
            obj = obj@Task(state);
        end

        function updateReward(obj,U)
            % reward not defined
        end
        
        function taskparams=init(obj)
            % loads and returns all the parameters for the various simulator objects
            
            taskparams.dt = 0.02; % task timestep i.e. rate at which controls
                               % are supplied and measurements are received
            
            taskparams.seed = 0; %set to zero to have a seed that depends on the system time
            
            %%%%% visualization %%%%%
            % 3D display parameters
            taskparams.display3d.on = 0;
            taskparams.display3d.width = 1000;
            taskparams.display3d.height = 600;            
            
            %%%%% environment %%%%%
            % these need to follow the conventions of axis(), they are in m, Z down
            % note that the lowest Z limit is the refence for the computation of wind shear and turbulence effects
            taskparams.environment.area.limits = [-10 20 -7 7 -20 0];
            taskparams.environment.area.type = 'BoxArea';
            
            % originutmcoords is the location of the RVC (our usual flying site)
            % generally when this is changed gpsspacesegment.orbitfile and 
            % gpsspacesegment.svs need to be changed
            [E N zone h] = llaToUtm([51.71190;-0.21052;0]);
            taskparams.environment.area.originutmcoords.E = E;
            taskparams.environment.area.originutmcoords.N = N;
            taskparams.environment.area.originutmcoords.h = h;
            taskparams.environment.area.originutmcoords.zone = zone;

            taskparams.environment.area.graphics.type = 'AreaGraphics';
            
            % GPS
            % The space segment of the gps system
            taskparams.environment.gpsspacesegment.on = 0; % if off the gps returns the noiseless position
            taskparams.environment.gpsspacesegment.dt = 0.2;          
            
            % Wind
            % i.e. a steady omogeneous wind with a direction and magnitude
            % this is common to all helicopters
            taskparams.environment.wind.on = 0;
            taskparams.environment.wind.W6 = 0.1;  %velocity at 6m from ground in m/s
                        
            %%%%% platforms %%%%%
            % Configuration and initial state for each of the platforms
            taskparams.platforms(1).configfile = 'pelican_config_gpsspacesegment_off';
            
        end

        function reset(obj) 
	    % initial state
	    obj.simState.platforms{1}.setX([0;0;-10;0;0;0]);
        end
        
        function r=reward(obj) 
            % nothing this is just a test task
        end
    end
    
end
