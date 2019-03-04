%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       smoothing and normalization of spike rates from MEA data
%
%   this script takes the spike times calculated from MEA_perfusion_scripts
%   and smooths them, then normalizes such that a value of 1 corresponds to
%   the mean spike rate for the first 100s of the experiment, or baseline
%   conditions.
%
%   the saved variables are as follows:
%       all_rates: the spike rates calculated in MEA_perfusion_scripts
%       smoothed_rates: spike rates with a smoothing spline function
%       applied
%       binned_rates: smoothed rates split into 10s bins
%       norm_rates: binned rates normalized to set the mean spike rate for
%       the first 10 bins (corresponding to the first 100s of recording) to
%       1.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
fpath = '/Users/abubnys/Desktop/Matlab_projects/MEA_perfusion_scripts/'; % set up location of source data
load([fpath 'SampleData_spikes.mat'])

%% set up rate variable
all_rates = [];
elec_rates = [];
f = 1;

%% collect rates
for c = 1:length(electrode_traces)
    if isfield(electrode_traces,'spike_times') == 1
        trc = electrode_traces(c).spike_rates;
    else
        trc = electrode_traces(c).r1_rate;
    end
    elec = electrode_traces(c).electrode;
    if isempty(trc) == 0
        if iscell (trc) == 1
            for g = 1:length(trc)
                all_rates(f,:) = trc{g};
                f = f+1;
            end
        else
            if length(trc) < 4795
                trc = [trc nan(1,4795-length(trc))];
            end
            all_rates(f,:) = trc(1:4795);
            f = f+1;
        end
        elec_rates = [elec_rates;elec];
    end
end

%% smooth rates
smoothed_rates = [];
for c = 1:size(all_rates,1)
    trc = all_rates(c,1:4794);
    sm_trc = fit([1:4794]',trc','SmoothingSpline');
    smoothed_rates(c,:) = sm_trc(1:4794);
end

%% bin the rate data into 10s bins
binned_rates = [];
for t = 1:size(all_rates,1)
    trc = all_rates(t,:);
    bins = 1:100:4790;
    for c = 1:length(bins)-1
        in_bin = trc(bins(c):bins(c+1));
        binned_rates(t,c) = mean(in_bin,'omitnan');
    end
end

%% normalize rates
norm_rates = [];
for t = 1:size(all_rates,1)
    trc = binned_rates(t,:);
    bs = mean(trc(1:10),'omitnan');
    if bs > 0
        norm_trc = trc./bs;
        norm_rates = [norm_rates; norm_trc];
    end
end
m_norm = mean(norm_rates,'omitnan');

% save output variables
save([fpath 'smoothed_spike_rates'],'all_rates', 'smoothed_rates', 'binned_rates', 'norm_rates')
