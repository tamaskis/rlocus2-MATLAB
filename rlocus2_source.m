%-------------------------------------------------------------------------%

% TAMAS KIS

% Root Locus Tool

%-------------------------------------------------------------------------%



%% SCRIPT SETUP

% clears variables and command window, closes all figures
clear;
clc;
close all;

% plot parameters
plot_position = [225,300,1200,500];



%% TRANSFER FUNCTION SETUP

% Laplace variable
s = tf('s');

% transfer function
L = (s+1)*(s+2)/(s*(s^2+4*s+20));
L = (4-2*s)/(s^2+s+9);



%% 180-DEGREE ROOT LOCUS

fprintf("********************180 DEGREE ROOT LOCUS********************\n");

% poles
p = pole(L);
fprintf("\nPoles:\n");
for i = 1:length(p)
    fprintf(p(i) + "\n");
end

% zeros
z = zero(L);
fprintf("\nZeros:\n");
for i = 1:length(z)
    fprintf(z(i) + "\n");
end

% number of asymptotes
m = length(p);
n = length(z);
fprintf("\nNumber of Asymptotes:\n");
fprintf("m-n = " + (m-n) + "\n")

% center of asymptotes
if ((m-n) > 1)
    alpha = (sum(p)-sum(z))/(m-n);
    fprintf("\nCenter of Asymptotes:\n");
    fprintf("alpha = " + alpha + "\n")
end

% direction of asymptotes
if ((m-n) > 1)
    fprintf("\nDirection of Asymptotes:\n");
    for i = 1:(m-n)
        direction = (180+360*(i-1))/(m-n);
        fprintf(direction + " degrees\n");
    end
end

% determines angle of departure from poles
if ~isempty(p)
    fprintf("\nAngles of Departure (from poles):\n")
    for i = 1:length(p)
        phi_p = atan2d(imag(p(i))-imag(p),real(p(i))-real(p));
        phi_z = atan2d(imag(p(i))-imag(z),real(p(i))-real(z));
        phi_d = -sum(phi_p)+sum(phi_z)+180;
        fprintf(p(i) + ": " + phi_d + " degrees\n");
    end
end

% determines angle of arrival to zeros;
if ~isempty(z)
    fprintf("\nAngles of Arrival (to zeros):\n")
    for i = 1:length(z)
        phi_p = atan2d(imag(z(i))-imag(p),real(z(i))-real(p));
        phi_z = atan2d(imag(z(i))-imag(z),real(z(i))-real(z));
        phi_a = sum(phi_p)-sum(phi_z)-180;
        fprintf(z(i) + ": " + phi_a + " degrees\n");
    end
end



%% 0-DEGREE ROOT LOCUS

fprintf("\n\n\n");
fprintf("*********************0 DEGREE ROOT LOCUS*********************\n");

% poles
fprintf("\nPoles:\n");
for i = 1:length(p)
    fprintf(p(i) + "\n");
end

% zeros
fprintf("\nZeros:\n");
for i = 1:length(z)
    fprintf(z(i) + "\n");
end

% number of asymptotes
fprintf("\nNumber of Asymptotes:\n");
fprintf("m-n = " + (m-n) + "\n")

% center of asymptotes
if ((m-n) > 1)
    fprintf("\nCenter of Asymptotes:\n");
    fprintf("alpha = " + alpha + "\n")
end

% direction of asymptotes
if ((m-n) > 1)
    fprintf("\nDirection of Asymptotes:\n");
    for i = 1:(m-n)
        direction = (360*(i-1))/(m-n);
        fprintf(direction + " degrees\n");
    end
end

% determines angle of departure from poles
if ~isempty(p)
    fprintf("\nAngles of Departure (from poles):\n")
    for i = 1:length(p)
        phi_p = atan2d(imag(p(i))-imag(p),real(p(i))-real(p));
        phi_z = atan2d(imag(p(i))-imag(z),real(p(i))-real(z));
        phi_d = -sum(phi_p)+sum(phi_z);
        fprintf(p(i) + ": " + phi_d + " degrees\n");
    end
end

% determines angle of arrival to zeros;
if ~isempty(z)
    fprintf("\nAngles of Arrival (to zeros):\n")
    for i = 1:length(z)
        phi_p = atan2d(imag(z(i))-imag(p),real(z(i))-real(p));
        phi_z = atan2d(imag(z(i))-imag(z),real(z(i))-real(z));
        phi_a = sum(phi_p)-sum(phi_z);
        fprintf(z(i) + ": " + phi_a + " degrees\n");
    end
end



%% ROOT LOCI PLOTS

% 180 and 0 degree root loci plots
figure('Position',plot_position);
subplot(1,2,1);rlocusplot(L);title('180 Degree Root Locus');
subplot(1,2,2);rlocusplot(L,-100:0.01:0);title('0 Degree Root Locus');