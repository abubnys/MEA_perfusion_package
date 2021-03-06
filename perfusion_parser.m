%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       perfusion parser
%
%   this script takes raw multi-electrode array data from .txt files
%   generated by MCRack, merges the files together, parses the data
%   according to the recording electrodes it came from, and detects spikes
%   generated by one or more neurons adjacent to the electrode from
%   user-defined thresholds
%
%   the result output structure, electrode_traces contains the following
%   fields:
%   1. electrode: the name of the electrode
%   2. data: raw data from that electrode
%   3. spike times: time (s) when each detected spike happened, this will
%   be a double if only one neuron was detected on the traces, or a cell
%   array with the number of cells equal to the number of neurons detected
%   in the recording
%   4. spike amplitudes: maximum amplitude (uV) of each spike, organized in
%   the same manner as spike times
%   5. spk_thresh: threshold for spike detection. If only one neuron was
%   detected this is a single value and all periods during which the raw
%   trace dropped below this value count as a spike. If multiple neurons
%   were detected, this is an n-by-4 vector in which each row
%   corresponds to the set of thresholds for a given neuron. Columns 1 and
%   2 are the x and y values for the upper threshold, and columnes 3 and 4
%   are the x and y values for the lower threshold. A spike for a given
%   neuron is registered if the raw trace intersects with the line defined
%   by these two coordinates.
%   6. spike rates: the binned spike rate (Hz) for each recorded neuron.
%   Each bin corresponds to the instantaneous spike rate over 100 ms. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% specify the paths for inputs and outputs:
% location of the .txt data
fpath = '/users/abubnys/Desktop/';
% names of the .txt files
fnoms = {'cnqx_perfusion','cnqx_perfusion0001'};
% location to put outputs
outpt_path = '/users/abubnys/Desktop/';
% names of the parsed data files
onoms = {'cnqx1','cnqx2'};
% name of the merged data file
merge_nom = 'cnqx_perfusion';
% name of final output file
output_name = [outpt_path 'cnqx_spikes'];

% generate full paths for parsed .txt files
input_noms = cell(1,length(fnoms));
for c = 1:length(fnoms)
    input_noms{c} = [outpt_path onoms{c}];
end
%%
% import and parse each .txt file
for c = 1:length(fnoms)
    import_txt([fpath fnoms{c}],[outpt_path onoms{c}])
end
%%
% merge parsed data together
merge_imported_data(input_noms,[outpt_path merge_nom])
%%
% detect spikes
load([outpt_path merge_nom])
[electrode_traces,x_time] = detect_spike_rates(electrode_traces);
save(output_name,'electrode_traces','x_time','-v7.3')



