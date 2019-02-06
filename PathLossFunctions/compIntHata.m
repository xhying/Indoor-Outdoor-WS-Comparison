% Estimate secondary interference using Hata model.
function int = compIntHata(eirp_dbm, f_mhz, d_m, ht_m, hr_m)
% eirp_dbm: EIRP in dBm (including antenna gain)
% f_mhz: center frequency
% d_m: distance
% ht_m: antenna height of transmitter
% hr_m: antenna height of receiver 

type = 'urban';         % only 'urban' mode is implemented
citySize = 'large';
[~, Aref]= pathLossHata( d_m, f_mhz, ht_m, hr_m, type, citySize );

L_FS = 20*log10(f_mhz) + 20*log10(d_m) - 28;
L_total = L_FS + Aref;

erp_dBk = eirp_dbm - 2.15 - 60;   % dBkW = dBm - 60;
int = 106.92 + erp_dBk - 20*log10(d_m/1000) - Aref; % in dBuV