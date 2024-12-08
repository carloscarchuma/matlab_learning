classdef liveweather < handle
    % LIVEWEATHER Simulates live weather data plotting
    
    properties
        historicalData  % Nx1 vector of historical temperature data
        liveData        % Mx1 vector of live temperature data
        timeStamps      % (N+M)x1 vector of datetime stamps
        updateInterval = 1; % Update interval in seconds
        baseTemp = 20;     % Base temperature in Celsius
        amplitude = 5;     % Daily temperature variation amplitude
    end
    
    methods
        function obj = liveweather()
            % Constructor: Initialize with realistic mock historical data
            timePoints = 100; % Number of historical data points
            minutesPerPoint = 1; % Time interval between data points

            % Initialize timestamps for historical data
            startTime = datetime('now') - minutes(timePoints - 1);
            obj.timeStamps = (startTime : minutes(minutesPerPoint) : datetime('now'))';
            
            % Generate historical data with a daily sinusoidal pattern and random noise
            hours = linspace(0, 24, timePoints)';
            dailyPattern = obj.baseTemp + ...
                           obj.amplitude * sin(2*pi*(hours - 6)/24); % Peak at 2PM (hour 14)
            randomVariation = 2 * randn(timePoints, 1); % Random noise
            obj.historicalData = dailyPattern + randomVariation;

            % Initialize live data as empty column vector
            obj.liveData = [];
        end

        function generateLiveData(obj)
            % Generate realistic mock live data based on time of day
            newTime = obj.timeStamps(end) + minutes(1);
            hourOfDay = hour(newTime) + minute(newTime)/60;

            % Calculate new temperature with daily pattern and random variation
            newTemp = obj.baseTemp + ...
                      obj.amplitude * sin(2*pi*(hourOfDay - 6)/24) + ...
                      1 * randn(); % Small random variation

            % Append new data point and timestamp
            obj.liveData = [obj.liveData; newTemp];
            obj.timeStamps = [obj.timeStamps; newTime];
        end

        function plotData(obj)
            % Plot historical and live data
            figure(2);
            clf;
            hold on;

            % Plot historical data
            plot(obj.timeStamps(1:length(obj.historicalData)), obj.historicalData, 'b', 'LineWidth', 1.5);

            % Plot live data if it exists
            if ~isempty(obj.liveData)
                liveIndices = (length(obj.historicalData) + 1):length(obj.timeStamps);
                plot(obj.timeStamps(liveIndices), obj.liveData, 'r', 'LineWidth', 1.5);
            end

            hold off;
            xlabel('Time (HH:MM:SS)', 'FontSize', 12);
            ylabel('Temperature (°C)', 'FontSize', 12);
            title('Simulated Weather Data: Historical vs. Real-Time', 'FontSize', 14);
            legend('Historical Data', 'Live Updates', 'FontSize', 10);
            datetick('x', 'HH:MM:SS', 'keeplimits');
            grid on;

            % Add reference lines for average and temperature ranges
            yline(obj.baseTemp, '--k', 'Average', 'LineWidth', 1);
            yline(obj.baseTemp + obj.amplitude, ':k', 'Max Range', 'LineWidth', 1);
            yline(obj.baseTemp - obj.amplitude, ':k', 'Min Range', 'LineWidth', 1);

            % Set y-axis limits with some padding
            ylim([obj.baseTemp - obj.amplitude*1.5, obj.baseTemp + obj.amplitude*1.5]);

            drawnow;
        end

        function runLivePlot(obj, duration)
            % Run the live plot for a specified duration
            % duration: total time to run the live plot in seconds

            steps = round(duration / obj.updateInterval);

            for step = 1:steps
                obj.generateLiveData();
                obj.plotData();
                pause(obj.updateInterval);
            end
        end
    end
end

% Example usage:
% weatherSim = liveweather();
% weatherSim.runLivePlot(60);  % Run for 60 seconds
