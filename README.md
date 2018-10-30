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

### User inputs
