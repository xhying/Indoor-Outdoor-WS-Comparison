function [loss Aref]= pathLossHata( d_m, f_MHz, ht, hr, type, citySize )
% function [loss Aref]= pathLossHata( d_m, f_MHz, ht, hr, type, citySize )
% f_MHz = frequency in (MHz)
% d_m = distance in (m).
% ht = transmitter heigtht in (m).
% hr = receiver hieght (m).
% type = environment type, could be {'urban', 'suburban', 'rural'}: only
% 'urban' is implemented for time being.

% loss = total path loss in dB
% Aref = path loss with respect to free space path loss, in dB

% range values: 
%               f = 150-1500MHz
%               ht = 30-200m
%               d = 1-20km

d_km = d_m/1000;
wrn_msg = [];

if f_MHz<150 || f_MHz>1500  
    error('HATA:ParamError', 'Frequency must be in the following range: 150 - 1500 MHz');
end

% Shaun: ignored 
% if ht<30 || ht>200
%     error('HATA:ParamError', 'Transmitter antenna height must be in the following range: 30 - 200 meters');
% end

if hr < 1.0 || hr>10
    error('HATA:ParamError', 'Receiver height should be in the following range: 0.1 - 10 meters.');
end

% if d_km<1 || d_km>20
%    error('HATA:ParamError', 'Distance should be in the following range: 1 - 20 km.');
% end

if d_km>20
	error('HATA:ParamError', 'Distance should be in the following range: 1 - 20 km.');
end

switch ( type )
    case 'urban'
        [a1 msg]= a(hr,f_MHz,citySize,type);
        wrn_msg = [wrn_msg; msg];
        loss = 69.55+26.16*log10(f_MHz)-13.82*log10(ht)-a1+(44.9-6.55*log10(ht))*log10(d_km);
    otherwise
        error(['HATA model: no supported type ' type ]);
end

lambda = 3e8/(f_MHz*1e6);
freeSpaceLoss = 20*log10(4*pi*d_m/lambda);
Aref = loss - freeSpaceLoss;

function [corrfactor, wmsg] = a( hr, f_MHz, citySize, type )
    wmsg = [];
    if (strcmpi( type, 'urban' ))
        
        if strcmpi(citySize,'small') || strcmpi(citySize,'medium')
            corrfactor = (1.1*log10(f_MHz)-0.7)*hr - (1.56*log10(f_MHz) - 0.8);
            
        elseif strcmpi(citySize,'large') % large city where height average is more than 15m
            if f_MHz >= 300     % Shaun: changed from 400 to 300; see Antenns and Propagation for Wireless Comm Sys.
                corrfactor = 3.2*(log10(11.75*hr))^2 - 4.97; % dB
            elseif f_MHz<300    % Shaun: changed from 400 to 300; see Antenns and Propagation for Wireless Comm Sys.
                corrfactor = 8.29*(log10(1.54*hr))^2 - 1.1; % dB
                if(f_MHz>200)
                    wmsg = [wmsg; 3, f_MHz];
%                     warning(['HATA - Correction factor: no supported frequency ', num2str(f_MHz), ...
%                         ' for ' citySize, ' cities.']);
                end
            else
                error(['HATA - Correction factor: no supported frequency ', num2str(f_MHz)]);
            end
        else
            error(['HATA - Correction Factor: no supported sity size ' citySize]);
        end
        
    else 
        error(['HATA model - Correction Factor: no supported type' type])
    end
    
    
    