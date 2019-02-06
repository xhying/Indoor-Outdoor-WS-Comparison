function set_path(base_directory)
% This function adds other folders which includes helping functions for our
% simulation
%
% base_directory: must be the directory in which following sub-directories
% are placed.
if(exist('base_directory', 'var') && ~isempty(base_directory))
    d = base_directory;
else
    %d = cd;
    d = '~/TVWSSimulatorEngine/';
end

if( ~isdeployed() && ~islinux() )
    addpath([ d '\HelpingFunctions\']);
    addpath([ d '\HelpingFunctions\averaging\']);
    addpath([ d '\HelpingFunctions\lat-long-azi-dist\']);
    addpath([ d '\HelpingFunctions\miscellaneous\']);
    addpath([ d '\HelpingFunctions\pathloss\']);
    addpath([ d '\HelpingFunctions\plotting\']);
    addpath([ d '\HelpingFunctions\population-zipcode\']);
    addpath([ d '\HelpingFunctions\terrain-db\']);
    addpath([ d '\HelpingFunctions\unit-conversion\']);    
    addpath([ d '\MajorFunction\'])
    addpath([ d '\DataFiles\']);
    addpath([ d '\FCCRegulation']);
    addpath([ d '\dataStructures']);
    addpath([ d '\UpdateServer']);
    addpath([ d '\TestScripts\']);
%elseif ( ~isdeployed() && islinux() )
elseif ( ~isdeployed() && ~isempty( strfind( computer, 'GLNX' ) )  )  % Server
    addpath([ d '/HelpingFunctions/']);
    addpath([ d '/HelpingFunctions/averaging/']);
    addpath([ d '/HelpingFunctions/lat-long-azi-dist/']);
    addpath([ d '/HelpingFunctions/miscellaneous/']);
    addpath([ d '/HelpingFunctions/pathloss/']);
    addpath([ d '/HelpingFunctions/plotting/']);
    addpath([ d '/HelpingFunctions/population-zipcode/']);
    addpath([ d '/HelpingFunctions/terrain-db/']);
    addpath([ d '/HelpingFunctions/unit-conversion/']);
    addpath([ d '/MajorFunction/'])
    addpath([ d '/DataFiles/']);
    addpath([ d '/FCCRegulation']);   
    addpath([ d '/dataStructures']);
    addpath([ d '/TestScripts/']);
    
    addpath('./PlottingFunctions');
    addpath('./PathLossFunctions');
    addpath('./UtilityFunctions');
    addpath('./Simulations');
    
elseif (~isdeployed() && ( ~isempty( strfind( computer, 'MACI64' ) ) ))
    addpath('./PlottingFunctions');
    addpath('./PathLossFunctions');
    addpath('./UtilityFunctions');
    addpath('./Simulations');
end