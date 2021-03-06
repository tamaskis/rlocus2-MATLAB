%==========================================================================
%
% rlocus2  TODO
%
%   rlocus2(L)
%
% See also rlocus.
%
% Copyright © 2021 Tamas Kis
% Last Update: 2021-10-08
% Website: https://tamaskis.github.io
% Contact: tamas.a.kis@outlook.com
%
%--------------------------------------------------------------------------
%
% ------
% INPUT:
% ------
%   L       - (tf) open loop transfer function
%   print   - (OPTIONAL) (char) prints manual drawing instructions if input
%             as 'print'
%
%==========================================================================
function rlocus2(L,print,opts)
    
    % ------------------------------------
    % Sets (or defaults) plotting options.
    % ------------------------------------
    
    % sets axis font size (defaults to 18)
    if (nargin < 3) || ~isfield(opts,'axis_font_size')
        axis_font_size = 14;
    else
        axis_font_size = opts.axis_font_size;
    end
    
    % sets title font size (defaults to 18)
    if (nargin < 3) || ~isfield(opts,'title_font_size')
        title_font_size = 14;
    else
        title_font_size = opts.title_font_size;
    end
    
    % ----------------------------------------------------
    % Sets unspecified parameters to their default values.
    % ----------------------------------------------------
    
    % defaults "print" to 'do not print'
    if (nargin < 2) || isempty(print)
        print = 'do not print';
    end
    
    % ---------------------
    % Calculate root locus.
    % ---------------------
    
    % gets numerator and denominator coefficients
    [num,den] = tfdata(L);

    % unwraps cell arrays
    num = num{1};
    den = den{1};

    % determines degree of numerator and denominator
    m = get_poly_degree(num);
    n = get_poly_degree(den);

    % b and a vectors
    b = fliplr(num((length(num)-m):length(num)));
    a = fliplr(den((length(den)-n):length(den)));

    % characteristic equation
    s = sym('s');
    k = sym('k');
    ch = 0;
    for i = 1:(m+1)
        ch = ch+(a(i)+k*b(i))*s^(i-1);
    end
    for i = (m+2):n
        ch = ch+a(i)*s^(i-1);
    end
    ch = ch+s^n;

    % coefficients of the characteristic equation (symbolic function)
    C = fliplr(coeffs(ch,s));
    
    % coefficients of the characteristic equation (MATLAB function)
    C = matlabFunction(C);
    
    % gain array
    k = 0:0.1:220;
    
    % preallocates arrays to store root locus
    x = zeros(length(k),n);
    y = zeros(length(k),n);

    % evaluates root locus
    for i = 1:length(k)
       Ci = C(k(i));
       r = roots(Ci)';
       x(i,:) = real(r);
       y(i,:) = imag(r);
    end
    
    % reorders points on root locus --> see "reorder_locus" subfunction
    % (located near bottom of overall function) for explanation
    [x,y] = reorder_locus(x,y);

    % ----------------
    % Plot root locus.
    % ----------------
    
    % initialize figure;
    figure;
    hold on;
    
    % determines the poles and zeros
    p = pole(L);
    z = zero(L);
    
    % minimum and maximum locus locations
    lx_min = min(x,[],'all');
    lx_max = max(x,[],'all');
    ly_min = min(y,[],'all');
    ly_max = max(y,[],'all');
    
    % minimum and maximum zero location
    if isempty(z)
        zx_min = NaN;
        zx_max = NaN;
        zy_min = NaN;
        zy_max = NaN;
    else
        zx_min = min(real(z),[],'all');
        zx_max = max(real(z),[],'all');
        zy_min = min(imag(z),[],'all');
        zy_max = max(imag(z),[],'all');
    end
    
    % minimum and maximum pole location
    if isempty(p)
        px_min = NaN;
        px_max = NaN;
        py_min = NaN;
        py_max = NaN;
    else
        px_min = min(real(p),[],'all');
        px_max = max(real(p),[],'all');
        py_min = min(imag(p),[],'all');
        py_max = max(imag(p),[],'all');
    end
    
    % determines initial axis limits
    xmin = min([zx_min,px_min,lx_min]);
    xmax = max([zx_max,px_max,lx_max]);
    ymin = min([zy_min,py_min,ly_min]);
    ymax = max([zy_max,py_max,ly_max]);
    
    % determines axis width defined by initial axis limits
    dx = xmax-xmin;
    dy = ymax-ymin;
    
    % adds padding to axis limits if maximum location is a pole or zero
    if (xmin == px_min) || (xmin == zx_min), xmin = xmin-0.1*dx; end
    if (xmax == px_max) || (xmax == zx_max), xmax = xmax+0.1*dx; end
    if (ymin == py_min) || (ymin == zy_min), ymin = ymin-0.1*dy; end
    if (ymax == py_max) || (ymax == zy_max), ymax = ymax+0.1*dy; end
    
    % shifts xmax if all of the root locus is in the LHP
    if xmax < 0, xmax = -0.1*xmin; end
    
    % sets axis limits
    xlim([xmin,xmax]);
    ylim([ymin,ymax]);
    
    % plots imaginary and real axes
    plot([0,0],[ymin,ymax],'k:','linewidth',1);
    plot([xmin,xmax],[0,0],'k:','linewidth',1);
    
    % plots poles (x) and zeros (o)
    plot(real(p),imag(p),'kx','linewidth',1.5,'markersize',10);
    plot(real(z),imag(z),'ko','linewidth',1.5,'markersize',10);
    
    % plots locus
    plot(x,y,'linewidth',1.5);
    
    % axis labels
    xlabel('Real Axis $[\mathrm{s}^{-1}]$','interpreter','latex',...
        'fontsize',axis_font_size);
    ylabel('Imaginary Axis $[\mathrm{s}^{-1}]$','interpreter','latex',...
        'fontsize',axis_font_size);
    
    % title
    title('\textbf{180 Degree Root Locus}','interpreter','latex',...
        'fontsize',title_font_size);

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
        phi_a = zeros(size(z));
        for i = 1:length(z)
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
    
    if strcmp(print,'print')
        
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
    
    %----------------------------------------------------------------------
    % get_poly_degree
    %
    % TODO
    %----------------------------------------------------------------------
    %
    % INPUT:
    %   p       - (TODO double) TODO
    %
    % OUTPUT:
    %   n   	- (1×1 double) degree of polynomial
    %
    %----------------------------------------------------------------------
    function n = get_poly_degree(p)
        n_comp = 0;
        while n_comp < length(p) && p(n_comp+1) == 0
            n_comp = n_comp+1;
        end
        n = length(p)-n_comp-1;
    end    

    %----------------------------------------------------------------------
    % reorder_locus 
    %
    % Subfunction to reorder the points on the root locus. A root locus for
    % an nth order system consists of n individual lines, but the roots
    % returned by the "root" function may not be consistent in their
    % ordering, so we have to fix this to avoid jumps in the plot.
    %----------------------------------------------------------------------
    %
    % INPUT:
    %   x       - (Nk×Nl double) original real coordinates on root locus
    %  	y       - (Nk×Nl double) original imag. coordinates on root locus
    %
    % OUTPUT:
    %   x_new   - (Nk×Nl double) updated real coordinates on root locus
    %  	y_new   - (Nk×Nl double) updated real coordinates on root locus
    %
    % NOTE:
    %   --> Nk = number of gains used to draw root locus
    %   --> Nl = number of individual lines on root locus
    %          = order of the system
    %
    %----------------------------------------------------------------------
    function [x_new,y_new] = reorder_locus(x,y)
       
        % number of lines (Nl) and number of gains used for locus (Nk)
        Nl = size(x,2);
        Nk = size(x,1);
        
        % array preallocation
        link = zeros(1,Nl);
        distance = zeros(1,Nl);
        x_new = zeros(size(x));
        y_new = zeros(size(y));
        
        % initializes new arrays at first index
        x_new(1,:) = x(1,:);
        y_new(1,:) = y(1,:);
        
        % loops over all the gains
        for ii = 1:(Nk-1)
            
            % loops over all the points
            for jj = 1:Nl
                
                % determines distances to each of the possible successive
                % points
                for kk = 1:Nl
                    distance(kk) = norm([x(ii+1,jj)-x(ii,kk),y(ii+1,jj)-...
                        y(ii,kk)]);
                end
                
                % stores the index of the point for the (ii+1)th gain that
                % is closest to the jjth point for the iith gain
                [~,link(jj)] = min(distance);
                
            end
            
            % reorders the points
            for jj = 1:Nl
                x_new(ii+1,link(jj)) = x(ii+1,jj);
                y_new(ii+1,link(jj)) = y(ii+1,jj);
            end
            
            % updates original points for next iteration
            x(ii+1,:) = x_new(ii+1,:);
            y(ii+1,:) = y_new(ii+1,:);
            
        end
        
    end

end