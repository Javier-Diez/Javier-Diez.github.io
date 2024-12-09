% Option pricing for PS1Q2, Black-Scholes with a jump

% Parameters

r = 0.05;
sigma = 0.2; 
nu = 0.2;
T = 1;
K_vec = [0.5:0.1:1.5];
S0 = 1;

Nsim = 1e5;

% simulate random shocks

epsilon = randn(Nsim,1);
ksi = -log(rand(Nsim,1));

% simulate stock price
S_unnorm = exp( sigma * sqrt(T) * epsilon - nu * ksi);
S = exp(r*T) * S_unnorm ./ mean(S_unnorm);

% compute implied vols

impvol = zeros(size(K_vec));

for j=1:length(K_vec)

        P = exp(-r*T) * mean( max(0,K_vec(j) - S) );
        impvol(j) = blsimpv(S0, K_vec(j), r, T, P, [], 0, [], {'Put'});
    
end

% compute implied vols

figure(1)
hold off
axis('square');
box off
set(gca,'FontS',14); 
plot(K_vec,impvol,'-o','LineW',3);
hold on
xlabel('Strike Price','FontS',16)
ylabel('Implied Volatility','FontS',16)


