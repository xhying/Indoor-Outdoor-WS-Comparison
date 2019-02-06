function [thrdBuV ]= getThreshold( channel, service_type )
% This function returns required threshold for each type of TV stations
% thrdBuV = threshold in dBuV
%
% Definition of TV sevices is found at "DBA Calculation Guideline"
% document.
%

%                      Low(2-6)  HighVHF(7-13)  UHF(14-52)
Analog_dBu_threhold = [47,       56,            64];
Digital_dBu_threhold = [28,      36,            41];

if(2 <= channel && channel <= 6)% Low VHF
    channel_category = 1;
elseif(7 <= channel && channel <= 13) % High VHF
    channel_category = 2;
elseif(14 <= channel && channel <= 69) % UHF
    channel_category = 3;
else
    error('FCC:Param:Error', ['Out of range channel input: ' num2str(channel)]);
end

switch char(service_type)
    case'CA'%analog
        thrdBuV = Analog_dBu_threhold(channel_category);
    case 'TX'%analog
        thrdBuV = Analog_dBu_threhold(channel_category);
    case 'TV'
        error('FCC:Param:ServiceUnknown', 'Unknown threshold for TV, we don''t know it''s analog or digital.');

    case 'DT'%digital
        thrdBuV = Digital_dBu_threhold(channel_category);
    case 'DC'%digital
        thrdBuV = Digital_dBu_threhold(channel_category);
    case 'LD'%digital
        thrdBuV = Digital_dBu_threhold(channel_category);
    case 'DD'%digital
        error( 'FCC:Param:ServiceUnknown', 'DD service is temporarily disabled.' );
    otherwise
        error( 'FCC:Param:ServiceUnknown', ['undefined service type ' service_type] );
end   

%% THIS IS REMOVED IN NEWER FCC RELEASES
% Apply dipole factor correction according to "OET BULLETIN No. 69:
% Longley-Rice Methodology for Evaluating TV Coverage and Interference"
% Table 1 and 2
% if 14 <= channel && channel <= 69
%     thrdBuV = thrdBuV - 20*log10(615/(ChannelToFreq(channel)));
% end