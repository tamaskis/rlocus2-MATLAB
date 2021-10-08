clear;clc;close all;

s = tf('s');

L = (s+3)/(s^3+3*s^2+5*s+1);
L = 1/(s^3+3*s^2+5*s+1);    % not working perfectly with this one

rlocus(L)
rlocus2(L)
