function freq_center = getCenterFreqByChId(ch_id)

% CH_ID = 14, freq_center = (470+476)/2 = 473 MHz
if (ch_id >=2) && (ch_id <= 4)
    freq_center = 57 + (ch_id - 1)*6;  % in MHz
elseif (ch_id >=5) && (ch_id <= 6)
    freq_center = 79 + (ch_id - 1)*6;  % in MHz
elseif (ch_id >= 7)&&(ch_id <=13)
    freq_center = 177 + (ch_id - 1)*6;  % in MHz
elseif (ch_id >=14)&&(ch_id <= 51)
    freq_center = 473 + (ch_id - 1)*6;  % in MHz
else
    error(sprintf('CH ID = %d is out of range', ch_id)); %#ok<SPERR>
end