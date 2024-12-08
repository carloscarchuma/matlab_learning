% Example Problem 2
clc, clearvars, close all

x = linspace(-10,10,101);

y1 = (-(x-3).^2) + 10;
y2 = (-(x-3).^2) + 15;
y3 = (-(x-5).^2) + 10;

figure(1)
plot(x,y1,'ms')
xlabel('x')
ylabel('y')
title("Y vs X for differing functions")
grid on

hold on
plot(x,y2,'bv')
hold on
plot(x,y3,'g+')

legend('y1','y2','y3')
% Can use xlim and ylim to set the limits of the plot
% xlim([0,2])
% ylim([0,20])
