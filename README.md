# MEA_perfusion_package
matlab scripts for parsing and analyzing multi-electrode data

  ###### We recorded the spontaneous activity of a network of neurons cultured on a multi-electrode array (MEA) and then slowly washed in different kinds of drugs to determine whether their presence alters the spontaneous activity of the neuronal culture. The data was initially recorded from the MEA2100 system on MCRack (MultiChannel systems) in 120 or 240 second increments (thus splitting a single 480s recording into 2 or 4 separate files). We then converted the raw data into .txt files using MCDataTool. This package takes the data from those .txt files and parses it using `import_txt`, then merges the consecutive recordings back together using `merge_imported_data`. Then, `detect_spike_rates` finds where neuron spikes occurred based on user defined thresholds and measures the instantaneous spike rate (Hz) of each recorded neuron over the course of the experiment, depositing the results into the sctructure `electrode_traces`.
  
### Running the package

All function calls are made within the script `perfusion_parser`. All you need to do is download the sample data sets `CNQX_perfusion` and `CNQX_perfusion0001` and set the directory where these two files are located and the directory where you would like the program to send its output files.
```
fpath = '/users/abubnys/Desktop/'; % location of the .txt data
outpt_path = '/users/abubnys/Desktop/'; % location to put outputs
```

`perfusion_parser` will produce 3 kinds of files:
1. `onoms`: parsed versions of each .txt file
2. `merge_nom`: a file that merges all of the data from separate .txt files together 
3. `output_name`: the file and directory where the final output will go

### The output

output structure, `electrode_traces` contains the following fields:
1. `electrode`: the name of the electrode
2. `data`: raw data from that electrode
3. `spike times`: time (s) when each detected spike happened, this will be a double if only one neuron was detected on the traces, or a cell array with the number of cells equal to the number of neurons detected in the recording
4. `spike amplitudes`: maximum amplitude (uV) of each spike, organized in the same manner as spike times
5. `spk_thresh`: threshold for spike detection. If only one neuron was detected this is a single value and all periods during which the raw trace dropped below this value count as a spike. If multiple neurons were detected, this is an n-by-4 vector in which each row corresponds to the set of thresholds for a given neuron. Columns 1 and 2 are the x and y values for the upper threshold, and columnes 3 and 4 are the x and y values for the lower threshold. A spike for a given neuron is registered if the raw trace intersects with the line defined by these two coordinates.
6. `spike rates`: the binned spike rate (Hz) for each recorded neuron. Each bin corresponds to the instantaneous spike rate over 100 ms. 

### User inputs

`detect_spike_rates` prompts the user to input decisions and information about spike thresholds at various points throughout the run. This function will iterate through the data for each electrode and determine spike rates from there. A more detailed description of these prompts follows:

First, it will take the 480s of raw data for that electrode and plot it across 4 rows of a figure:

![example of raw electrode data](/e52.png)

The program them prompts the user to identify whether the given raw data contains any spiking activity
```
spiking? (y=1)
```
If there is no apparent activity on this recording, the user selects option 0 and the program continues on to the next recording. However, in this case we observe that there is spiking activity happening in the recording, so we select option 1. 

The program then prompts the user to identify a period within the recording in which said activity is happening.
```
pick a spiking period
```
Because the full recording is so long and therefore the individual spikes may be difficult to distinguish, this allows the program to zoom into a selected 10 second window of representative activity. Here we selected 160s as the start of the representative activity period. So, the program generates a new figure which just shows this time window.


![10 second spiking period](/e52_pre_thresh.png)

Now, the program prompts the user to select a threshold for spikes. This is a simple threshold, so all periods when the recording drops below this number will be counted as spikes.
```
threshold? 
```
We set the threshold to -16 in order to capture the spikes without picking up too much noise.

Now, the program draws a red line where the threshold has been set and prompts the user to say whether this is a suitable threshold.

![simple threshold](/e52_thresh.png)

```
good threshold? (y=1)
```
We are happy with the current threshold, so we selection option 1. However, if the initial threshold setting is too high or too low, you can select option 0 and the program will prompt the user to select a new threshold as before and the process will continue ad inifintum until a suitable threshold is selected.

Now the program takes the spikes it detected within that 10 second time window with the given threshold and plots all of their waveforms in an overlay.

![wavelets](/e52_wavelet.png)

All of the wavelets converge on a single curve in this case, so the spiking activity in this recording is only coming from a single neuron somewhere in the vicinity.
```
multiple neurons? (y=1, n=0)
```
Thus, we select option 0 and the program continues with the analysis to generate a final figure which includes the raw data plot, a raster plot of identified spikes, and a plot of the binned spike rate (calculated from 100ms bins).

![final output](/e52_final.png)

### An example with multiple neurons
      
