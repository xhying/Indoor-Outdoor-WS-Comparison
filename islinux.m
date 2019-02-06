function [ output_args ] = islinux()

if( ~isempty( strfind( computer, 'PCWIN' ) ) )
    output_args = false;
elseif ( ~isempty( strfind( computer, 'GLNX' ) ) )
    output_args = true;
elseif ( ~isempty( strfind( computer, 'MACI64' ) ) )
    output_args = true;
else
    error('Unknown host (neither linux nor windows)');
end

