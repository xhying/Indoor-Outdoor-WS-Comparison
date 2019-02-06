eirp_dbm = 36;
f_mhz = 755;
ht_m = 15;
hr_m = 10;

d_m_vec = 100:100:1000;
rss_vec = zeros(2, length(d_m_vec));


for i=1:length(d_m_vec)
    d_m = d_m_vec(i);
    
    erp_dbk = eirp_dbm - 2.15 - 60;
    rss_vec(1,i) = 106.92 + erp_dbk - 20*log10(d_m/1000); % in dBuV
    
    rss_vec(2,i) = compIntHata(eirp_dbm, f_mhz, d_m, ht_m, hr_m);
end

%%
figure;
plot(d_m_vec, rss_vec(1,:), 'r');
hold on;
plot(d_m_vec, rss_vec(2,:));
