% Code for the DP solution of the portfolio optimization 
% problem with return predictability and margin constraints
%
% L. Kogan, 05/10/2010


clear all

% Parameters

alpha = 4;
lambda = 0.25;
dt = 1/12;
rho = exp(-0.5 * dt);
sigma = 0.10*sqrt(dt);
T = 5;

% grid 

dx = sigma/3;
sigmass = sqrt(sigma^2/(1 - rho^2)); % steady-state volatility
xmax = 4*sigmass;
Nx = 2*ceil( xmax/ dx) + 1;

Wmax = 4;
NW = 81;
Wgrid = linspace(0,Wmax,NW);
dW = Wgrid(2) - Wgrid(1);

xgrid = linspace(-xmax,xmax,Nx);
dx = 2*xmax / (Nx);

Ntheta = 81;
thetagrid = linspace(-1/lambda,1/lambda,Ntheta);
dtheta = thetagrid(2) - thetagrid(1);

% Utility function

U = -exp(-alpha*Wgrid);

% Transition matrix for x_t

TrM_x = zeros(Nx,Nx); % transition matrix from xgrid(i) to xgrid(j)

 
for i=1:Nx

    p = zeros(1,Nx);
    p(2:end-1) = dx * (1 / sqrt(2*pi*sigma^2)) *...
        exp( -1/(2*sigma^2) .* (xgrid(2:end-1) - rho*xgrid(i)).^2 );
    p(1) = normcdf((xgrid(1) + dx/2 - rho*xgrid(i))/sigma);
    p(end) = 1 - normcdf((xgrid(end) - dx/2 - rho*xgrid(i))/sigma);
    
    p = p ./ sum(p);    % normalize p to add up to 1
    TrM_x(i,:) = p;
    
end

% Bellman iterations

J_next = ones(Nx,1)*U;   % initiate the value function at T
theta_opt = zeros([ceil(T/dt) size(J_next)]); % optimal strategy
t = T;  % time
j=0;    % counter

while t > 1e-12
    
    J = J_next;

    t = t - dt
    j = j+1;
    tic 
    for ix = 1:Nx

        x = xgrid(ix);  % current x   
        p = TrM_x(ix,:); % x transition probs
        
        for iW = 1:NW  

            W = Wgrid(iW);  % current W
            % compute the expected next-period value function for all
            % possible values of control (theta) and maximize
            
            V = zeros(size(thetagrid));
            
            for ntheta=1:Ntheta
                
                theta = W*thetagrid(ntheta);  % current control
               
                W_next = W + theta*(xgrid - x);
                    % compute W next period
                % focus on the region of positive W_next separately    
                W_next = min(W_next,Wmax); % implement interpolation at the
                            % boundaries of W grid
                            
                arg = (W_next > Wgrid(1)); 
                
                J1 = zeros(size(xgrid));
                
                J1(arg) = interp2(Wgrid,xgrid',J_next,...
                             W_next(arg),xgrid(arg),'*linear');
                J1((W_next <= Wgrid(1))) = ...
                    -exp(-alpha*W_next((W_next <= Wgrid(1))));
                
                V(ntheta) = TrM_x(ix,:) * J1';        
                 
            end
            
            [J(ix,iW),n] = max(V);
            theta_opt(j,ix,iW) = thetagrid(n);
            
        end
        
    end
    
    J_next = J;  % update the value function
    
    toc
    
end

 
nW = 21;

figure(1)
hold off
 C = squeeze(theta_opt(1,:,:));
 plot(xgrid,smooth(C(:,nW),9),'b-','LineW',2 );
hold on
 C = squeeze(theta_opt(12,:,:));
 plot(xgrid,smooth(C(:,nW),9),'r-.','LineW',2 );
 C = squeeze(theta_opt(36,:,:));
 plot(xgrid,smooth(C(:,nW),9),'g-<','LineW',2,'MarkerS',2 );
 C = squeeze(theta_opt(60,:,:));
 plot(xgrid,smooth(C(:,nW),9),'m--','LineW',2 );
 axis('square');
 box off
 axis([-.5 .5 -5 5]);
 legend('T=1 ','T=12','T=36','T=60');
 xlabel('Price Spread (X)','FontS',16);
 ylabel('Optimal Policy (\theta^*)','FontS',16);
 
 tmp = num2str(Wgrid(nW));
 title('W = 1','FontS',16); 
 
 
 
figure(3)
surf(Wgrid(1:40),xgrid(1:3:end), J_next(1:3:end,1:40),'LineW',1.5);
axis('square');
box off
ylabel('Price Spread (X)','FontS',14);
xlabel('Portfolio Value (W)','FontS',14);
zlabel('Value Function (J)','FontS',14);
axis([ 0 2 -.5 .5 -1 0]);
 
 
 