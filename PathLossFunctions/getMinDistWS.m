% Compute minimum separation distance in the direction of SU Tx given its 
% trasnmitted power in WS sharing.
% The maximum allowable interference at border PU Rx is Delta-gamma.
% Since Hata model is used, we only need SU Tx EIRP and antenna height.

function d_WS = getMinDistWS(tower, su_tx_eirp, su_tx_height, wall_loss)

if ~exist('wall_loss', 'var')
   wall_loss = 0; 
end

debug = false;
global_params = getGlobalParams();

eirp_dbm = su_tx_eirp;      % Transmitted power of SU Tx
f_mhz = getCenterFreqByChId(tower.channel);
ht_m = su_tx_height;        % Here SU Tx is the transmitter
hr_m = global_params.TV_RX_HEIGHT;  % TV Rx is the receiver

Delta = getThreshold(tower.channel, tower.service);
gamma = getThresholdInterference(tower.service, 0);
maxInt = Delta - gamma + wall_loss;     % maximum allowable interfernce

% Since Hata model does not require locations, we do NOT need border location.
d_lower = 50;  % in m
d_upper = 20000; % in m
tolerance = 5;    % in m
while ( (d_upper-d_lower) > tolerance )
    d_m = (d_lower + d_upper)/2;
    int = compIntHata(eirp_dbm, f_mhz, d_m, ht_m, hr_m);
     
    if debug
        fprintf('d_lower = %.2f, d_upper = %.2f, d_m = %.2f, maxInt = %.2f, int = %.2f\n', ...
            d_lower, d_upper, d_m, maxInt, int);
    end
    
    if ( int >= maxInt )
        d_lower = d_m;
    else
        d_upper = d_m;
    end
end

d_WS = (d_lower + d_upper)/2;


