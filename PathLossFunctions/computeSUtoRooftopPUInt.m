% Interference from SU to PU at the rooftop

function signalStrength = computeSUtoRooftopPUInt(dist, channel, eirp)
% Key reference: ITU-R P.1238-7
% Assume the PU Rx is on the rooftop and the SU Tx is inside the building.
% Assume the number of floors between SU Tx and PU Rx is no less than 3.
% Use the site-general models
%       L_total = 20*log10(f) + N*log10(d) + L_f(n) - 28
% where f is in MHz, N the PL exponent, L_f the floor penetration loss.
%
% Parameters:
%   N = 33 -- office
%   L_f(3) = 24 dB 
%
% Note: It should be noted that there may be a limit on the isolation 
% expected through multiple floors. The signal may find other external 
% paths to complete the link with less total loss than that due to the 
% penetration loss through many floors.

d = dist;    % distance (in meter) between SU and PU
ch_id = channel;
erp_dBk = eirp - 2.15 - 60;   % dBkW = dBmW - 60;
N = 33;         % for 900-MHz signals in the document
L_floor = 24;       % Floor penetraion loss, 24 dB by default

% CH_ID = 14, freq_center = (470+476)/2 = 473 MHz
if (ch_id >=2) && (ch_id <= 4)
    f = 57 + (ch_id - 1)*6;  % in MHz
elseif (ch_id >=5) && (ch_id <= 6)
    f = 79 + (ch_id - 1)*6;  % in MHz
elseif (ch_id >= 7)&&(ch_id <=13)
    f = 177 + (ch_id - 1)*6;  % in MHz
elseif (ch_id >=14)&&(ch_id <= 51)
    f = 473 + (ch_id - 1)*6;  % in MHz
else
    error(sprintf('CH ID = %d is out of range', ch_id)); %#ok<SPERR>
end

L_FS = 20*log10(f) + 20*log10(d) - 28;
L_total = 20*log10(f) + N*log10(d) + L_floor - 28;

Aref = L_total - L_FS;
signalStrength = 106.92 + erp_dBk - 20*log10(d/1000) - Aref;

