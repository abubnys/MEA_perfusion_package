%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                  merge imported data
%
%   this function takes the raw multi-electrode array data imported using
%   import_txt.m and merges the multiple consecutive recordings together 
%   into a single data set, if applicable and saves the result
%
%   input_paths: a cell array listing all paths for the files generated
%   from import_txt.m
%   output_name: the name of the destination file for the merged data
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function merge_imported_data(input_paths,output_name)

op = length(input_paths);
elec_lists = {};
data_lists = {};
electrode_traces = struct;

% import all data
for e = 1:op
    input_nom = input_paths{e};
    load(input_nom);
    elec_lists{e} = electrodes;
    data_lists{e} = data.data(:,2:end);
end

% merge data for matched electrodes
reference_electrode_names = elec_lists{1};
for e = 1:length(reference_electrode_names)
    ref_nom = reference_electrode_names{e};
    this_data = data_lists{1}(:,e);
    for f = 2:op
        comp_electrode_names = elec_lists{f};
        for g = 1:length(comp_electrode_names)
            e_comp = comp_electrode_names{g};
            if strcmp(ref_nom,e_comp) == 1
                data_to_merge = data_lists{f}(:,g);
                this_data = [this_data;data_to_merge];
            end
        end
    end
    electrode_traces(e).electrode = ref_nom;
    electrode_traces(e).data = this_data;
end

save(output_name,'electrode_traces','-v7.3')
disp('merging complete')
end



