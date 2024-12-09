% Option pricing in a model with stochastic volatility.
% This code also demonstrates use of delta-hedge as a control variate.

% Parameters

clear all

gammavec = [0.1:0.1:0.5];

for n_gamma = 1:length(gammavec)

r = 0.05;
T = 0.5;
S_0 = 50;
K = 55;

v_0 = 0.09;
v_bar = 0.09;
kappa = 2;
gamma = gammavec(n_gamma);
gamma
rho = -0.5;

num_period = 100;
dt = T/num_period;


%%  Naive Monte Carlo simulation

N = 10000;
X = zeros(N,1);

for j=1:N
    S = zeros(num_period+1,1);
    v = zeros(num_period+1,1);
    S(1) = S_0;
    v(1) = v_0;
    
    % simulate stock price and conditional variance under Q
    for i=1:num_period
        e1 = randn;
        e2 = rho*e1 + sqrt(1-rho^2)*randn;
        
        S(i+1) = S(i) + S(i)*(r*dt+sqrt(v(i))*sqrt(dt)*e1); % stock price
        v(i+1) = v(i) - kappa*(v(i)-v_bar)*dt + gamma*sqrt(v(i))*sqrt(dt)*e2; % variance
        v(i+1) = max(v(i+1),0);
    end
    X(j) = exp(-r*T)*max(S(end)-K,0); % discounted option payoff
end

price = mean(X);
std_price = sqrt(mean((X-price).^2));
SE = std_price/sqrt(N);

% construct the confidence interval for the estimate of the price
conf_int = [price - std_price/sqrt(N)*norminv(.975), price + std_price/sqrt(N)*norminv(.975)];

display(price);
display(SE);


%% Variance reduction using delta-hedge gains process as a control variate
N0 = 1000;
N1 = 10000;

% First determine the covariance between X and Y
X0 = zeros(N0,1);
Y0 = zeros(N0,1);

for j=1:N0
    S = zeros(num_period+1,1);
    v = zeros(num_period+1,1);
    G = zeros(num_period+1,1);
    
    S(1) = S_0;
    v(1) = v_0;
    G(1) = 0;
    
    for i=1:num_period
        e1 = randn;
        e2 = rho*e1 + sqrt(1-rho^2)*randn;
        
        S(i+1) = S(i) + S(i)*(r*dt+sqrt(v(i))*sqrt(dt)*e1);
        v(i+1) = v(i) - kappa*(v(i)-v_bar)*dt + gamma*sqrt(v(i))*sqrt(dt)*e2;
        
        d = (log(S(i)/K)+(r+v_bar/2)*((num_period-(i-1))*dt))/(sqrt(v_bar)*sqrt((num_period-(i-1))*dt));
        G(i+1) = G(i) + normcdf(d)*(exp(-r*(i*dt))*S(i+1)-exp(-r*((i-1)*dt))*S(i));
    end
    X0(j) = exp(-r*T)*max(S(end)-K,0);
    Y0(j) = G(end);
end

b_hat = (Y0'*Y0)^(-1)*(Y0'*X0);
temp = corrcoef(X0,Y0); correl = temp(1,2);

% Now calculate the expected value using Y as the control variate
X1 = zeros(N1,1);
Y1 = zeros(N1,1);

for j=1:N1
    S = zeros(num_period+1,1);
    v = zeros(num_period+1,1);
    G = zeros(num_period+1,1);
    
    S(1) = S_0;
    v(1) = v_0;
    G(1) = 0;
    
    for i=1:num_period
        e1 = randn;
        e2 = rho*e1 + sqrt(1-rho^2)*randn;
        
        S(i+1) = S(i) + S(i)*(r*dt+sqrt(v(i))*sqrt(dt)*e1);
        v(i+1) = v(i) - kappa*(v(i)-v_bar)*dt + gamma*sqrt(v(i))*sqrt(dt)*e2;
        
        d = (log(S(i)/K)+(r+v_bar/2)*((num_period-(i-1))*dt))/(sqrt(v_bar)*sqrt((num_period-(i-1))*dt));       
        G(i+1) = G(i) + normcdf(d)*(exp(-r*(i*dt))*S(i+1)-exp(-r*((i-1)*dt))*S(i));
    end
    X1(j) = exp(-r*T)*max(S(end)-K,0);
    Y1(j) = G(end);
end

X1_control = X1 - b_hat*Y1;
price = mean(X1_control);
std_price = sqrt(mean((X1_control-price).^2));
conf_int = [price - std_price/sqrt(N1)*norminv(.975), price + std_price/sqrt(N1)*norminv(.975)];

%display(b_hat);
display(correl);
display(price);
SE = std_price/sqrt(N1);
display(SE);

end