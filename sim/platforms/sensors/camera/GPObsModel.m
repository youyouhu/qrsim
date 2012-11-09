classdef GPObsModel<handle
    % modelling the image classifier observation by means of two GPs
    
    properties (Constant)
        % GP model P( score | target is present)
        % x = [px,py,r,tclass,d,sigma,inc,sazi,cazi]  if person is visible
        meanfuncP = {@meanSum, {@meanLinear, @meanConst}};
        %meanfuncP = {@meanConst};        
        hypPmean = [0; 0; 0; 0; 0; 0; 0; 0; 0; 1];
        %hypPmean = [1];
        %covfuncP = {@covSEard};
        covfuncP = {@covSEiso};
        %hypPcov = log([1; 1; 1; 3; 100; 10000; 2*pi; 1; 1; 0.2]);
        %hypPcov = log([1; 1; 1; 1; 1; 1; 1; 1; 1; 0.2]);
        hypPcov = log([0.2;0.2]);
        snP = 0.1; % Gaussian likelihood sd
        
        % GP model P( score | target is not present)
        % x = [px,py,r,tclass]  if person is not visible
        meanfuncN = {@meanSum, {@meanLinear, @meanConst}};
        %meanfuncN = {@meanConst};        
        %hypNmean = [0; 0; 1/100; -1/3; 1];
        hypNmean = [0; 0; 1; 1; 1];
        %hypNmean = [1];        
        %covfuncN = {@covSEard};
        covfuncN = {@covSEiso};        
        %hypNcov = log([1; 1; 1; 3; 0.2]);
        %hypNcov = log([1; 1; 1; 1; 0.2]);        
        hypNcov = log([0.2; 0.2]);        
        snN = 0.1; % Gaussian likelihood sd
    end
    
    properties (Access=private)
        gpp;
        gpn;
        simState;
        prngId;
    end
    
    methods
        function obj = GPObsModel(simState, prngId)
            % initialize the GPs
            obj.simState = simState;
            obj.prngId = prngId;
            obj.gpp = GPwrapper(obj.meanfuncP,obj.hypPmean,obj.covfuncP,obj.hypPcov,obj.snP);
            obj.gpn = GPwrapper(obj.meanfuncN,obj.hypNmean,obj.covfuncN,obj.hypNcov,obj.snN);
        end
        
        function reset(obj)
            % cleanup
            obj.gpp.reset();
            obj.gpn.reset();
        end
        
        function ystar = sample(obj, which, xstar)
            % given a set of row inputs, we compute the
            % predictive distribution and sample from it
            
            lx = size(xstar,1);
            ystar = zeros(lx,1);
            which = logical(which);
            lp = sum(which);
            ln = lx - lp;
            rndsample = randn(obj.simState.rStreams{obj.prngId},lx,1);
            
            % generate samples from gpp
            if(lp>0)
                tmp = obj.gpp.sample(cell2mat(xstar(which)),rndsample(1:lp));
                ystar(which) = tmp;
            end
            
            % generate samples from gpn
            if(ln>0)
                tmp = obj.gpn.sample(cell2mat(xstar(~which)),rndsample(lp+1:end));
                ystar(~which) = tmp;
            end
        end
        
        function likr = computeLikelihoodRatio(obj, xqueryp, xqueryn, ystar)
            % compute the likelihood ratio for the locations
            % xstars and the measurements ystar
            n = size(ystar,1);
            likr = zeros(n,1);
            
            for i=1:n
                llikp = obj.gpp.computeLogLikelihood(xqueryp(i,:),ystar(i,:));
                llikn = obj.gpn.computeLogLikelihood(xqueryn(i,:),ystar(i,:));
                
                likr(i)=  exp(llikp-llikn);
            end
        end
        
        function obj = updatePosterior(obj)
            % update the posterior of the two GPs based
            % on the data stored at sampling time
            obj.gpp.updatePosterior();
            obj.gpn.updatePosterior();
        end
    end
end
