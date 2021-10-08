%==========================================================================
%
% rlocus2  TODO
%
%   rlocus2(L)
%
% See also rlocus.
%
% Copyright © 2021 Tamas Kis
% Last Update: 2021-09-26
% Website: https://tamaskis.github.io
% Contact: tamas.a.kis@outlook.com
%
%--------------------------------------------------------------------------
%
% ------
% INPUT:
% ------
%   L       - (tf) open loop transfer function
%
%==========================================================================
function rlocus2(L)
    
    % --------------------------------
    % Calculations for both root loci.
    % --------------------------------
    
    % poles
    p = pole(L);

    % zeros
    z = zero(L);

    % number of poles and zeros (also determines number of asymptotes)
    m = length(p);
    n = length(z);
    
    % center of asymptotes
    if ((m-n) > 1)
        alpha = (sum(p)-sum(z))/(m-n);
    else
        alpha = NaN;
    end

    % ---------------------------------
    % Calculations for 180° root locus.
    % ---------------------------------
    
    % direction of asymptotes
    if ((m-n) > 1)
        direction = zeros(m-n,1);
        for i = 1:(m-n)
            direction(i) = (180+360*(i-1))/(m-n);
        end
    else
        direction = NaN;
    end

    % determines angle of departure from poles
    if ~isempty(p)
        phi_d = zeros(size(p));
        for i = 1:length(p)
            phi_p = atan2d(imag(p(i))-imag(p),real(p(i))-real(p));
            phi_z = atan2d(imag(p(i))-imag(z),real(p(i))-real(z));
            phi_d(i) = -sum(phi_p)+sum(phi_z)+180;
        end
    else
        phi_d = NaN;
    end
    
    % determines angle of arrival to zeros
    if ~isempty(z)
        phi_a = zeros(size(p));
        for i = 1:length(p)
            phi_p = atan2d(imag(z(i))-imag(p),real(z(i))-real(p));
            phi_z = atan2d(imag(z(i))-imag(z),real(z(i))-real(z));
            phi_a(i) = sum(phi_p)-sum(phi_z)-180;
        end
    else
        phi_a = NaN;
    end
    
	% ---------------
    % Prints results.
    % ---------------
    
    % poles
	fprintf("\nPoles:\n");
    for i = 1:length(p)
        fprintf(p(i)+"\n");
    end
    
    % zeros
    fprintf("\nZeros:\n");
    for i = 1:length(z)
        fprintf(z(i)+"\n");
    end
    
    % number of asymptotes
    fprintf("\nNumber of Asymptotes:\n");
    fprintf("m-n = "+(m-n)+"\n")
    
    % center of asymptotes
    if ~isnan(alpha)
        fprintf("\nCenter of Asymptotes:\n");
        fprintf("alpha = "+alpha+"\n")
    end
    
    % direction of asymptotes
    if ~isnan(direction)
        fprintf("\nDirection of Asymptotes:\n");
        for i = 1:(m-n)
            fprintf(direction(i)+" degrees\n");
        end
    end
    
    % angles of departure from poles
    if ~isnan(phi_d)
        fprintf("\nAngles of Departure (from poles):\n")
        for i = 1:length(p)
            fprintf(p(i)+": "+phi_d(i)+" degrees\n");
        end
    end
    
	% angles of arrival to zeros
    if ~isnan(phi_a)
        fprintf("\nAngles of Arrival (to zeros):\n")
        for i = 1:length(z)
            fprintf(z(i)+": "+phi_a(i)+" degrees\n");
        end
    end

end