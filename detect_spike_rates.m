%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       detect spike rates
%
%   this function takes the merged raw traces of multi-electrode array
%   data, identifies spikes from a user-defined threshold, separates spikes
%   originating from multiple neurons (if applicable) from a user-defined
%   threshold, and then calculates the instantaneous spike rate across the
%   recording for each electrode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function electrode_traces = detect_spike_rates(merged_data)
%merged_data = '/users/abubnys/Desktop/d10_acsf_final';
load(merged_data)

all_time = 0:1/20000:500;
x_time = all_time(1:length(electrode_traces(1).data));

% indices for plotting the raw data in 2 minute increments
st_indx1 = find(x_time == 1);
fn_indx1 = find(x_time == 120);
st_indx2 = find(x_time == 120);
fn_indx2 = find(x_time == 240);
st_indx3 = find(x_time == 240);
fn_indx3 = find(x_time == 360);
st_indx4 = find(x_time == 360);
fn_indx4 = find(x_time == 479);


for n = 1:length(electrode_traces)
    
    trc = electrode_traces(n).data;
    
    lo = min(trc(st_indx1:fn_indx1));
    hi = max(trc(st_indx1:fn_indx1));
    
    figure
    subplot(4,1,1)
    hold on
    plot(all_time(st_indx1:fn_indx1),trc(st_indx1:fn_indx1),'k')
    title(sprintf('electrode %s', electrode_traces(n).electrode))
    ylim([lo hi])
    subplot(4,1,2)
    hold on
    plot(all_time(st_indx2:fn_indx2),trc(st_indx2:fn_indx2),'k')
    ylim([lo hi])
    subplot(4,1,3)
    hold on
    plot(all_time(st_indx3:fn_indx3),trc(st_indx3:fn_indx3),'k')
    ylim([lo hi])
    subplot(4,1,4)
    hold on
    plot(all_time(st_indx4:fn_indx4),trc(st_indx4:fn_indx4),'k')
    ylim([lo hi])
    
    % tell the program if the electrode recorded spiking activity, (yes = 1, no = 0)
    is_active = input('spiking? (y=1) ');
    wv_found = 0;
    
    % waveform analysis
    if is_active == 1
        is_active = 1;
        st_tim = input('pick a spiking period ');
        figure
        st_indx = find(x_time == st_tim);
        fn_indx = find(x_time == st_tim+10);
        
        % identify negative threshold for spikes, this loop will keep
        % repeating until a good threshold is agreed upon
        t_ok = 0;
        while t_ok == 0
            plot(x_time(st_indx:fn_indx), trc(st_indx:fn_indx),'k')
            hold on
            thresh = input('threshold? ');
            t_line = ones(1,fn_indx-st_indx+1).*thresh;
            plot(x_time(st_indx:fn_indx), t_line,'r')
            hold off
            t_ok = input('good threshold? (y=1) ');
        end
        close all
        
        % plot a subset of the detected spike waveforms
        % if there are multiple active cells, there will be separate
        % waveform amplitudes visible in the overlaid plot
        wavelets = [];
        mini_trc = trc(st_indx:fn_indx);
        for c = 11:length(mini_trc)-10
            if mini_trc(c) > thresh && mini_trc(c+1) <= thresh
                wvlt = mini_trc(c-10:c+9);
                wavelets = [wavelets wvlt];
            end
        end
        figure
        hold on
        x_grid = 0:20;
        y_grid = linspace(min(min(wavelets))-20,max(max(wavelets)),10000);
        for a = 1:length(x_grid)
            plot(ones(1,10000).*x_grid(a),y_grid,'color',[0.9 0.9 0.9])
        end
        
        plot(wavelets,'k')
        wv_found = input('multiple neurons? (y=1, n=0) ');
        
        % identify signals from different neurons
        color_lst = {'r','g','b','c','m','y'};
        if wv_found == 1
            wv_found = 1;
            identify_cell = 1;
            wv_tsh_lst = [];
            found_cell = 1;
            assigned_wvlt = {};
            
            % select the thresholds for the different neurons
            while identify_cell ~= 0
                dcm_obj = datacursormode;
                
                datacursormode on
                
                disp('select upper threshold, then return')
                % Wait while the user does this.
                pause
                c_info = getCursorInfo(dcm_obj);
                up_thresh = c_info.Position;
                dcm_obj.removeAllDataCursors()
                
                disp('selec lower threshold, then return')
                % Wait while the user does this.
                pause
                c_info = getCursorInfo(dcm_obj);
                low_thresh = c_info.Position;
                dcm_obj.removeAllDataCursors()
                
                % color wavelets within threshold
                a_wvlt = [];
                for c = 1:size(wavelets,2)
                    wvlt = wavelets(:,c);
                    for g = 1:length(wvlt)-1
                        if g <= up_thresh(1) && g+1 >= low_thresh(1) && wvlt(g) <= up_thresh(2) && wvlt(g+1) >= low_thresh(2)
                            plot(wvlt,color_lst{found_cell})
                            a_wvlt = [a_wvlt wvlt];
                            break
                        end
                    end
                end
                
                % draw the selected neuron threshold
                line([up_thresh(1) low_thresh(1)],[up_thresh(2) low_thresh(2)],'color','k','LineWidth',2)
  
                % add cell spike threshold to the list
                tsh_ok = input('good threshold? (y=1, n=0) ');
                if tsh_ok == 1
                    wv_tsh_lst = [wv_tsh_lst; up_thresh low_thresh];
                    text(mean([up_thresh(1) low_thresh(1)]),mean([up_thresh(2) low_thresh(2)]),num2str(found_cell),'Color',color_lst{found_cell},'FontSize',14)
                    assigned_wvlt{found_cell} = a_wvlt;
                    found_cell = found_cell+1;
                else
                    children = get(gca, 'children');
                    delete(children(1));
                    close all
                    figure
                    hold on
                    for a = 1:length(x_grid)
                        plot(ones(1,10000).*x_grid(a),y_grid,'color',[0.9 0.9 0.9])
                    end
                    plot(wavelets,'k')
                    if isempty(assigned_wvlt) == 0
                        for a = 1:length(assigned_wvlt)
                            plot(assigned_wvlt{a},color_lst{a})
                        end
                    end
                end
                identify_cell = input('find another cell? (y=1, n=0) ');
            end
  
            % using identified thresholds, find spikes for all neurons
            wavelets = [];
            wavelet_times = [];
            for c = 11:length(trc)-10
                if trc(c) > thresh && trc(c+1) <= thresh
                    wvlt = trc(c-10:c+9);
                    w_time = x_time(c-10:c+9);
                    wavelets = [wavelets wvlt];
                    wavelet_times = [wavelet_times; w_time];
                end
            end
            % find spikes according to whether they intersect with threshold vectors
            all_cell_spike_amp = {};
            all_cell_spike_times = {};
            for e = 1:size(wv_tsh_lst,1)
                up_thresh = wv_tsh_lst(e,1:2);
                low_thresh = wv_tsh_lst(e,3:4);
                spike_amp = [];
                spike_time = [];
                s = 0;
                
                for w = 1:size(wavelets,2)
                    wvlt = wavelets(:,w);
                    w_time = wavelet_times(w,:);
                    xW1 = [];
                    xW2 = [];
                    
                    % find the segment of the wavelet closest to threshold
                    for d = 1:19
                        if d >= up_thresh(1) && d+1 <= low_thresh(1)
                            xW1 = d;
                            xW2 = d+1;
                        end
                    end
                    
                    % calculate slope and intersect for wavelet
                    yW1 = wvlt(xW1);
                    yW2 = wvlt(xW2);
                    mW = (yW2-yW1)/(xW2-xW1);
                    bW = yW1-(mW*xW1);
                    
                    % calculate slope and intersect for threshold
                    xT1 = up_thresh(1);
                    xT2 = low_thresh(1);
                    yT1 = up_thresh(2);
                    yT2 = low_thresh(2);
                    mT = (yT2-yT1)/(xT2-xT1);
                    bT = yT1-(mT*xT1);
                    
                    % intersect between wavelet and threshold, but not if lines
                    % are parallel
                    if mW ~= mT
                        x_int = (bT-bW)/(mW-mT);
                        y_int = (mT*x_int)+bT;
                        % if the intersect falls on threshold line, register it
                        if x_int >= up_thresh(1) && x_int <= low_thresh(1) && y_int <= up_thresh(2) && y_int >= low_thresh(2)
                            spike_amp = [spike_amp min(wvlt)];
                            spike_time = [spike_time w_time(find(wvlt == min(wvlt)))];
                            s = s+1;
                        end
                    end
                end
                
                all_cell_spike_amp{e} = spike_amp;
                all_cell_spike_times{e} = spike_time;
                electrode_traces(n).spike_times = all_cell_spike_times;
                electrode_traces(n).spike_amplitudes = all_cell_spike_amp;
                electrode_traces(n).spk_thresh = wv_tsh_lst;
            end
        end
        
        % if only one neuron present, use simple threshold to find spikes
        if wv_found == 0
            spike_amp = [];
            spike_time = [];
            for c = 11:length(trc)-10
                if trc(c) <= thresh && trc(c-1) > thresh
                    wvlt = trc(c-10:c+9);
                    w_time = x_time(c-10:c+9);
                    spike_amp = [spike_amp min(wvlt)];
                    spike_time = [spike_time w_time(find(wvlt == min(wvlt)))];
                end
            end
            electrode_traces(n).spike_times = spike_time;
            electrode_traces(n).spike_amplitudes = spike_amp;
            electrode_traces(n).spk_thresh = thresh;
        end
        %
        % plot results
        figure
        subplot(3,1,1)
        plot(x_time,trc,'k')
        title(sprintf('electrode %s', electrode_traces(n).electrode))
        ylim([-100 60])
        subplot(3,1,2)
        hold on
        title('raster plot')
        spikes = electrode_traces(n).spike_times;
        if iscell(spikes) == 1
            for c = 1:length(spikes)
                rst = spikes{c};
                for d = 1:length(rst)
                    line([rst(d) rst(d)],[c-1 c],'color','k')
                end
            end
        else
            for c = 1:length(spikes)
                line([spikes(c) spikes(c)],[0 1])
            end
        end
        
        % spike rate (kHz), calculated from 100 ms bins
        bin_lst = 1:2000:length(x_time);
        rates = {};
        spikes = electrode_traces(n).spike_times;
        if iscell(spikes) == 1
            for b = 1:length(spikes)
                rst = spikes{b};
                r1_rates = [];
                for c = 1:length(bin_lst)-1
                    b_st = x_time(bin_lst(c));
                    b_fn = x_time(bin_lst(c+1));
                    r1_rt = sum(rst > b_st & rst < b_fn);
                    r1_rates(c) = r1_rt*10;
                end
                rates{b} = r1_rates;
            end
        else
            r1_rates = [];
            for c = 1:length(bin_lst)-1
                b_st = x_time(bin_lst(c));
                b_fn = x_time(bin_lst(c+1));
                r1_rt = sum(spikes > b_st & spikes < b_fn);
                r1_rates(c) = r1_rt*10;
            end
            rates = r1_rates;
        end
        
        % plot spike rates
        subplot(3,1,3)
        hold on
        title('spike rate')
        if iscell(rates) == 1
            for c = 1:length(rates)
                plot(x_time(bin_lst(1:end-1)),rates{c})
            end
        else
            plot(x_time(bin_lst(1:end-1)),rates)
        end
        ylabel('spike rate (Hz)')
        xlabel('time (s)')
        
        electrode_traces(n).spike_rates = rates;
    end
    close all
end

end