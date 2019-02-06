function [ thrdB ]= getThresholdInterference( service_type, chan_diff )

% This function returns required threshold for each type of TV stations
% thrdB = threshold in dB

if( strcmpi(service_type, 'TV') || strcmpi(service_type, 'CA') || ...
        strcmpi(service_type, 'LPTV') || strcmpi(service_type, 'TX') || ...
        strcmpi(service_type, 'TB') )
    thrdB = (chan_diff==0)*34 + (chan_diff==-1)*(-14) + (chan_diff==1)*(-17);
    
elseif( strcmpi(service_type, 'DT') || strcmpi(service_type, 'DC') || ...
        strcmpi(service_type, 'LD') || strcmpi(service_type, 'DX') || ...
        strcmpi(service_type, 'DD') )
    thrdB = (chan_diff==0)*23 + (chan_diff==-1)*(-28) + (chan_diff==1)*(-26);
    
else
    error(' unaccepted service type' );
end    
