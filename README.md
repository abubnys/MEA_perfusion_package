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


      
