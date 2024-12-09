for j=1:200

    % ********************************
    % Parameters
    % ********************************

    r = 0.05;
    sigma = 0.2;
    T = 1;
    K = 100;
    S_0 = 100;

    N_sim = 1e5;

    % ********************************
    % Simulation
    % ********************************

    epsilon = randn(N_sim,1);
    S_T = S_0 * exp( (r-sigma^2/2)*T + sigma*sqrt(T) * epsilon);
    C_T = max(0,S_T - K);

    C_0 = mean( exp(-r*T) * C_T );

    [C_0_BS, P_0_BS] = blsprice(S_0, K, r, T, sigma, 0);

    if j==1
        display(['Estimated Price:   '  num2str(C_0)]);
        display(['Theoretical Price: ', num2str(C_0_BS)]);
    end
    
    C(j) = C_0;
    
end

figure(1)
hold off
[freq,bins] = hist(C,20);
bar(bins, freq./length(C),'FaceColor','y','BarWidth',1);
xlabel('Price');
ylabel('Frequency');
hold on
plot([C_0_BS; C_0_BS], [0; max(freq./length(C))],'b-','LineW',4)
axis('tight');
axis('square');
box off
