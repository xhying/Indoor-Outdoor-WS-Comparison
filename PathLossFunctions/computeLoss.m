% This function computes path loss in dB
% Aref = dBLoss - FSLoss;
function [dBLoss, Aref, params] = computeLoss(tx_loc, rx_loc, tx_height, ch_id, rx_height)

if ~exist('rx_height', 'var')
    rx_height = 10; % in meters, by default
end

dist_m = computeDist(tx_loc(1), tx_loc(2), rx_loc(1), rx_loc(2));

freq_center = getCenterFreqByChId(ch_id);

% Sample:
% [dBLoss err dLOS_m Aref propa_param]=LongleyRArea( 10000, 3, 90, 200, 10.0, ...
%     2, 0, [], [], [], ...   % Set them to default
%     400.0, ...  % frequency in MHz; important
%     'continental temperate', 'horizontal', 0.5, 0.5, 0.5 );
[dBLoss, ~, ~, Aref, ~] = LongleyRArea( dist_m, 3, 90, tx_height, rx_height, ...
    2, 0, [], [], [], ...   % Set them to default
    freq_center, ...  % frequency in MHz; important
    'continental temperate', 'horizontal', 0.5, 0.5, 0.5 );

params.dist_m = dist_m;
params.dist_km = dist_m/1000;
params.tx_loc = tx_loc;
params.rx_loc = rx_loc;
params.tx_height = tx_height;
params.rx_height = rx_height;
params.ch_id = ch_id;