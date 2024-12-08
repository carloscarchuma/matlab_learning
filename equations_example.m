% Example Problem
clc, clearvars, close all


x = linspace(0,5,101);
y = @(x) (-(x-3).^2) + 10;

plot(x,y(x),'*')

% A) Find the maximum value of y
max(y(x))

% B) Find the minimum value of y
min(y(x))

% C) Find the value of x when y is at its maximum
[MaxVal, I] = max(y(x));
x_maxval = x(I)
% can also be done with:
% x_maxval = x(y(x) == max(y(x)))

% D) What is y(20.7)?
y(20.7)
