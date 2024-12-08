classdef testing
    % TESTING A basic MATLAB class demonstration
    
    properties
        % Class properties (variables)
        Value
        Name
    end
    
    methods
        % Constructor method
        function obj = testing(initialValue, initialName)
            if nargin > 0
                obj.Value = initialValue;
                if nargin > 1
                    obj.Name = initialName;
                end
            end
        end
        
        % Method to display object information
        function displayInfo(obj)
            fprintf('Name: %s\n', obj.Name);
            fprintf('Value: %d\n', obj.Value);
        end
        
        % Method to set a new value
        function obj = setValue(obj, newValue)
            obj.Value = newValue;
        end
        
        % Method to get the current value
        function value = getValue(obj)
            value = obj.Value;
        end
    end
end

