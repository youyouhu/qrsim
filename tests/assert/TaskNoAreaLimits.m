classdef TaskNoAreaLimits<Task
    % Task used to test assertions on DT
    %
    methods (Sealed,Access=public)
                
        function obj = TaskNoAreaLimits(state)
            obj = obj@Task(state);
        end

        function updateReward(obj,U)
            % reward not defined
        end
        
        function taskparams=init(obj)
            % loads and returns all the parameters for the various simulator objects
            
            % Simulator step time in second this should not be changed...
            taskparams.DT = 0.02;
            
            taskparams.seed = 0; %set to zero to have a seed that depends on the system time
            
            %%%%% visualization %%%%%
            % 3D display parameters
            taskparams.display3d.on = 0;
            taskparams.display3d.width = 1000;
            taskparams.display3d.height = 600;            
           
            %%%%% environment %%%%%
            taskparams.environment.area.type = 'BoxArea';
        end

        function reset(obj) 
            % initial state
        end 
        
        function r=reward(obj) 
            % nothing this is just a test task
        end
    end
    
end
