classdef thermal_simulation < handle
    % THERMAL_SIMULATION Simulates heat distribution from a sun beam on a surface
    
    properties
        gridSize = [50, 50]      % Size of the simulation grid
        surfaceTemp              % Temperature matrix
        ambientTemp = 25         % Ambient temperature (Celsius)
        sunBeamTemp = 100        % Temperature of sun beam (Celsius)
        diffusionRate = 0.1      % Heat diffusion rate
        coolingRate = 0.02       % Heat loss to environment
        sunBeamRadius = 3        % Radius of sun beam (grid cells)
        sunPosition = [25, 25]   % Current position of sun beam
        timeStep = 0.1           % Simulation time step (seconds)
    end
    
    methods
        function obj = thermal_simulation()
            % Constructor: Initialize the surface temperature grid
            obj.surfaceTemp = ones(obj.gridSize) * obj.ambientTemp;
        end
        
        function updateSunPosition(obj, x, y)
            % Update the position of the sun beam
            obj.sunPosition = [x, y];
        end
        
        function simulateStep(obj)
            % Perform one step of the thermal simulation
            
            % Create temporary matrix for new temperatures
            newTemp = obj.surfaceTemp;
            
            % Apply sun beam heat
            [X, Y] = meshgrid(1:obj.gridSize(2), 1:obj.gridSize(1));
            distance = sqrt((X - obj.sunPosition(2)).^2 + (Y - obj.sunPosition(1)).^2);
            sunMask = distance <= obj.sunBeamRadius;
            newTemp(sunMask) = newTemp(sunMask) + ...
                (obj.sunBeamTemp - newTemp(sunMask)) * obj.timeStep;
            
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
        
        function visualize(obj)
            % Visualize the current temperature distribution
            imagesc(obj.surfaceTemp);
            colorbar;
            colormap('hot');
            title('Surface Temperature Distribution (°C)');
            xlabel('X Position');
            ylabel('Y Position');
            
            % Mark sun beam position
            hold on;
            plot(obj.sunPosition(2), obj.sunPosition(1), 'wo', ...
                'MarkerSize', 10, 'LineWidth', 2);
            hold off;
            
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
                        % Original circular pattern
                        t = step * obj.timeStep;
                        centerX = obj.gridSize(1)/2;
                        centerY = obj.gridSize(2)/2;
                        radius = 15;
                        x = centerX + radius * cos(t);
                        y = centerY + radius * sin(t);
                        
                    case 'x'
                        % X pattern movement
                        t = mod(step * obj.timeStep, 4); % Cycle through 4 segments
                        centerX = obj.gridSize(1)/2;
                        centerY = obj.gridSize(2)/2;
                        maxRadius = 20;
                        
                        if t < 1  % Top-left to bottom-right (first half)
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
                obj.visualize();
                pause(0.01); % Small pause for visualization
            end
        end
        
        function visualizeTrail(obj)
            % Visualize the current temperature distribution with trail
            figure(1);
            subplot(1,2,1);
            imagesc(obj.surfaceTemp);
            colorbar;
            colormap('hot');
            title('Surface Temperature Distribution (°C)');
            xlabel('X Position');
            ylabel('Y Position');
            
            % Mark sun beam position
            hold on;
            plot(obj.sunPosition(2), obj.sunPosition(1), 'wo', ...
                'MarkerSize', 10, 'LineWidth', 2);
            hold off;
            
            % Add trail visualization
            subplot(1,2,2);
            plot([obj.gridSize(2)/2-20, obj.gridSize(2)/2+20], ...
                 [obj.gridSize(1)/2-20, obj.gridSize(1)/2+20], 'b--', ...
                 [obj.gridSize(2)/2+20, obj.gridSize(2)/2-20], ...
                 [obj.gridSize(1)/2-20, obj.gridSize(1)/2+20], 'b--');
            hold on;
            plot(obj.sunPosition(2), obj.sunPosition(1), 'ro', ...
                'MarkerSize', 10, 'LineWidth', 2);
            hold off;
            title('Sun Beam Movement Pattern');
            xlabel('X Position');
            ylabel('Y Position');
            axis([0 obj.gridSize(2) 0 obj.gridSize(1)]);
            grid on;
            
            drawnow;
        end
    end
end
