% Interference from SU to PU at a different location from SU
% Okumura-Hata model is used for estimating secondary interference.

function interference = computeInterference(SU_TX, TV_RX_loc)
global_params = getGlobalParams();

ch_id = SU_TX.channel;
tx_loc = [SU_TX.latitude, SU_TX.longitude];
tx_height = SU_TX.height;
tx_eirp = SU_TX.eirp;  % max. EIRP in dBm (including antenna gain)

erp_dBk = tx_eirp - 2.15 - 60;   % dBkW = dBm - 60;

d_m = computeDist(tx_loc(1), tx_loc(2), TV_RX_loc(1), TV_RX_loc(2));
f_MHz = getCenterFreqByChId(ch_id);
rx_height = global_params.TV_RX_HEIGHT;     % 10 meters by dfault
type = 'urban';         % only 'urban' mode is implemented
citySize = 'large';

[~, Aref]= pathLossHata( d_m, f_MHz, tx_height, rx_height, type, citySize );
interference = 106.92 + erp_dBk - 20*log10(d_m/1000) - Aref; % in dBuV
