classdef TestGPSTask<Task
    % Simple task used to do sensor testing
    %
    % KeepSpot methods:
    %   init()   - loads and returns all the parameters for the various simulator objects
    %   reward() - returns 0
    %
    
    methods (Sealed,Access=public)
        
        function taskparams=init(obj)
            % loads and returns all the parameters for the various simulator objects
            %
            % Example:
            %   params = obj.init();
            %          params - all the task parameters
            %
            
            % Simulator step time in second this should not be changed...
            taskparams.DT = 0.02;
            
            taskparams.seed = 0; %set to zero to have a seed that depends on the system time
            
            %%%%% visualization %%%%%
            % 3D display parameters
            taskparams.display3d.on = 0;
            taskparams.display3d.width = 1000;
            taskparams.display3d.height = 600;            
            
            %%%%% environment %%%%%
            % these need to follow the conventions of axis(), they are in m, Z down
            taskparams.environment.area.limits = [-10 20 -7 7 -20 0];
            taskparams.environment.area.type = 'BoxArea';
            % location of our usual flying site
            [E N zone h] = lla2utm([51.71190;-0.21052;0]);
            taskparams.environment.area.originutmcoords.E = E;
            taskparams.environment.area.originutmcoords.N = N;
            taskparams.environment.area.originutmcoords.h = h;
            taskparams.environment.area.originutmcoords.zone =  zone;
            taskparams.environment.area.graphics.on = taskparams.display3d.on;
            taskparams.environment.area.graphics.type = 'AreaGraphics';
            
            % GPS
            % The
            taskparams.environment.gpsspacesegment.on = 1; % if off the gps returns the noiseless position
            taskparams.environment.gpsspacesegment.dt = 0.2;
            % specific setting due to the use of the ngs15992_16to17.sp3 file
            taskparams.environment.gpsspacesegment.orbitfile = 'ngs15992_16to17.sp3';
            taskparams.environment.gpsspacesegment.tStart = 0;%Orbits.parseTime(2010,8,31,16,0,0); %0 to init randomly
            % a typical flight day had the following svs visible:
            %03G 05G 06G 07G 13G 16G 18G 19G 20G 22G 24G 29G 31G
            taskparams.environment.gpsspacesegment.svs = [3,5,6,7,13,16,18,19,20,22,24,29,31];
%             taskparams.environment.gpsspacesegment.type = 'GPSSpaceSegmentGM';
%             taskparams.environment.gpsspacesegment.PR_BETA = 2000;     % process time constant (from [2])
%             taskparams.environment.gpsspacesegment.PR_SIGMA = 0.1746;  % process standard deviation (from [2])
%             taskparams.environment.gpsspacesegment.DT = taskparams.DT;
            taskparams.environment.gpsspacesegment.type = 'GPSSpaceSegmentGM2';            
            taskparams.environment.gpsspacesegment.PR_BETA2 = 4;               % process time constant
            taskparams.environment.gpsspacesegment.PR_BETA1 =  1.005;          % process time constant   
            taskparams.environment.gpsspacesegment.PR_SIGMA = 0.003;           % process standard deviation            
            taskparams.environment.gpsspacesegment.DT = taskparams.DT;
            
            % Wind
            % i.e. a steady omogeneous wind with a direction and magnitude
            % this is common to all helicopters
            taskparams.environment.wind.on = 0;
            taskparams.environment.wind.type = 'WindConstMean';
            taskparams.environment.wind.direction = [1;0;0]; %mean wind direction, set to 0 to initilise randomly
            taskparams.environment.wind.W6 = 0.1;  %velocity at 6m from ground in m/s
            taskparams.environment.wind.dt = 1;    %not actually used since the model is constant
            taskparams.environment.wind.DT = taskparams.DT;
            
            %%%%% platforms %%%%%
            % Configuration and initial state for each of the platforms
            taskparams.platforms(1).configfile = 'pelican_test_gps_config';
            taskparams.platforms(1).X = [0;0;-20;0;0;0];
            
        end
        
        function r=reward(obj) 
            % returns the instantateous reward for this task
            %
            % Example:
            %   r = obj.reward();
            %          r - the reward
            %
            r = 0; 
        end
    end
    
end