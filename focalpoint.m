classdef focalpoint < handle
    % FOCALPOINT Simulates heat distribution from a single-point sun beam
    
    properties
        gridSize = [50, 50]      % Size of the simulation grid
        surfaceTemp              % Temperature matrix
        ambientTemp = 25         % Ambient temperature (Celsius)
        sunBeamTemp = 500        % Temperature of sun beam (Celsius)
        diffusionRate = 0.1      % Heat diffusion rate
        coolingRate = 0.02       % Heat loss to environment
        sunPosition = [25, 25]   % Current position of sun beam
        timeStep = 0.1           % Simulation time step (seconds)
        dissipationThreshold = 1 % Temperature difference threshold for measuring dissipation (°C)
        maxDistanceHistory = []  % Store history of maximum heat distance
        timeHistory = []         % Store time points for plotting
    end
    
    methods
        function obj = focalpoint()
            % Constructor: Initialize the surface temperature grid
            obj.surfaceTemp = ones(obj.gridSize) * obj.ambientTemp;
            obj.maxDistanceHistory = [];
            obj.timeHistory = [];
        end
        
        function updateSunPosition(obj, x, y)
            % Update the position of the sun beam
            % Round to nearest integer to ensure we hit exactly one grid point
            obj.sunPosition = [round(x), round(y)];
        end
        
        function simulateStep(obj)
            % Perform one step of the thermal simulation
            
            % Create temporary matrix for new temperatures
            newTemp = obj.surfaceTemp;
            
            % Apply sun beam heat to single point
            newTemp(obj.sunPosition(1), obj.sunPosition(2)) = ...
                newTemp(obj.sunPosition(1), obj.sunPosition(2)) + ...
                (obj.sunBeamTemp - newTemp(obj.sunPosition(1), obj.sunPosition(2))) * obj.timeStep;
            
            % Calculate heat diffusion
            for i = 2:obj.gridSize(1)-1
                for j = 2:obj.gridSize(2)-1
                    % Heat diffusion from neighboring cells
                    diffusion = obj.diffusionRate * ...
                        (obj.surfaceTemp(i-1,j) + obj.surfaceTemp(i+1,j) + ...
                        obj.surfaceTemp(i,j-1) + obj.surfaceTemp(i,j+1) - ...
                        4 * obj.surfaceTemp(i,j));
                    newTemp(i,j) = newTemp(i,j) + diffusion * obj.timeStep;
                end
            end
            
            % Apply cooling to ambient temperature
            cooling = (obj.ambientTemp - obj.surfaceTemp) * obj.coolingRate;
            newTemp = newTemp + cooling * obj.timeStep;
            
            % Update the temperature matrix
            obj.surfaceTemp = newTemp;
        end
        
        function maxDistance = calculateHeatDistance(obj)
            % Calculate the maximum distance that heat has traveled
            tempDiff = obj.surfaceTemp - obj.ambientTemp;
            [X, Y] = meshgrid(1:obj.gridSize(2), 1:obj.gridSize(1));
            
            % Lower threshold to detect heat spread earlier
            significantThreshold = 45;  % Decreased from 50°C to 30°C
            heatedPoints = tempDiff > significantThreshold;
            
            if any(heatedPoints(:))
                % Calculate distances from current sun position
                distances = sqrt((X - obj.sunPosition(2)).^2 + (Y - obj.sunPosition(1)).^2);
                maxDistance = max(distances(heatedPoints));
                
                % More gradual smoothing for better tracking from the start
                if ~isempty(obj.maxDistanceHistory)
                    prevDistance = obj.maxDistanceHistory(end);
                    % Smoother transition (70% new, 30% previous)
                    maxDistance = 0.7 * maxDistance + 0.3 * prevDistance;
                end
            else
                % Start with a small non-zero distance when heating begins
                maxDistance = 1;  % Start with 1 pixel radius
            end
        end
        
        function visualize(obj)
            % Create single figure with two subplots
            figure(1);
            clf;  % Clear figure
            
            % Temperature distribution subplot
            subplot(1,2,1);
            imagesc(obj.surfaceTemp);
            colorbar;
            colormap('hot');
            title('Single-Point Heat Source Distribution (°C)');
            xlabel('X Position');
            ylabel('Y Position');
            
            % Mark focal point position
            hold on;
            plot(obj.sunPosition(2), obj.sunPosition(1), 'wo', ...
                'MarkerSize', 5, 'LineWidth', 2);
            
            % Draw circle showing current heat dissipation distance using plot
            maxDist = obj.calculateHeatDistance();
            theta = linspace(0, 2*pi, 100);
            xCircle = obj.sunPosition(2) + maxDist * cos(theta);
            yCircle = obj.sunPosition(1) + maxDist * sin(theta);
            plot(xCircle, yCircle, 'w--', 'LineWidth', 1);
            hold off;
            
            % Heat dissipation distance over time subplot
            subplot(1,2,2);
            plot(obj.timeHistory, obj.maxDistanceHistory, 'b-', 'LineWidth', 1.5);
            title('Heat Dissipation Distance Over Time');
            xlabel('Time (seconds)');
            ylabel('Maximum Heat Distance (pixels)');
            grid on;
            
            % Adjust figure layout
            set(gcf, 'Position', [100, 100, 1200, 500]);  % Make figure window wider
            drawnow;
        end
        
        function runSimulation(obj, duration, pattern)
            % Run the simulation for a specified duration
            % duration: simulation time in seconds
            % pattern: string specifying movement pattern ('circle' or 'x')
            
            steps = round(duration / obj.timeStep);
            
            for step = 1:steps
                switch pattern
                    case 'circle'
                        % Circular pattern
                        t = step * obj.timeStep;
                        centerX = obj.gridSize(1)/2;
                        centerY = obj.gridSize(2)/2;
                        radius = 15;
                        x = centerX + radius * cos(t);
                        y = centerY + radius * sin(t);
                        
                    case 'x'
                        % X pattern movement
                        t = mod(step * obj.timeStep, 4);
                        centerX = obj.gridSize(1)/2;
                        centerY = obj.gridSize(2)/2;
                        maxRadius = 20;
                        
                        if t < 1  % Top-left to bottom-right
                            progress = t;
                            x = centerX - maxRadius + 2 * maxRadius * progress;
                            y = centerX - maxRadius + 2 * maxRadius * progress;
                        elseif t < 2  % Bottom-right to top-left
                            progress = t - 1;
                            x = centerX + maxRadius - 2 * maxRadius * progress;
                            y = centerX + maxRadius - 2 * maxRadius * progress;
                        elseif t < 3  % Top-right to bottom-left
                            progress = t - 2;
                            x = centerX + maxRadius - 2 * maxRadius * progress;
                            y = centerX - maxRadius + 2 * maxRadius * progress;
                        else  % Bottom-left to top-right
                            progress = t - 3;
                            x = centerX - maxRadius + 2 * maxRadius * progress;
                            y = centerX + maxRadius - 2 * maxRadius * progress;
                        end
                end
                
                obj.updateSunPosition(x, y);
                obj.simulateStep();
                
                % Record maximum heat distance
                currentTime = step * obj.timeStep;
                obj.timeHistory = [obj.timeHistory, currentTime];
                obj.maxDistanceHistory = [obj.maxDistanceHistory, obj.calculateHeatDistance()];
                
                obj.visualize();
                pause(0.01);
            end
        end
    end
end
