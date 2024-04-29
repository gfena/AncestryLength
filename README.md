The **AncestryTrack** program measures the length of local ancestry tracts obtained from Local Ancestry Inference (LAI). The AncestryTrack program can analyse data sets with thousands of samples and multiple ancestries, iterating by chromosome. It can be used for any model of LAI analysis, starting from the 2-way admixture model up to any number.

If you use **AncestryTrack** in a published analysis, please report the program version printed in the first line of the output log file and please cite the article that describes the AncestryTrack method:

  *G.F. Ena, M. Araujo-Castro, A. Giménez, A. Carballo-Mesa, D. Comas. Exploring the Iberian Roma Trail: A Journey on Europe Edge.*

Giacomo F. Ena

Last updated: May 01, 2024

# Installation

You can download the latest file, AncestryTrackv1.0.2, with the command:

 ```wget https://github.com/gfena/AncestryTrack/main/AncestryTrackv1.0.2.rb```

or you can directly download the source files.

```git clone https://github.com/gfena/AncestryTrack.git```

# Running AncestryTrack

The AncestryTrack program requires Ruby version 3.3.1 (or a later version). Use of an earlier Ruby version could still work but it has not been tested, therefore support for older versions won't be provided.

The command:

```ruby AncestryTrackv1.0.0.rb```

prints a summary of the command line arguments.

```
Usage: ruby AncestryTrackv1.0.2.rb -i input_file -o output_file [--MB] [--nohap] [--parallel]
       Please provide the input file path
```

where [arguments] is a space-separated list of parameter values, each expressed as --parameter.

The shell script run.AncestryTrack.test.sh will run a test AncestryTrack analysis.
To iterate the program over the 22 chromosomes, run in this form:

```
for chr in {1..22}
do
rubyAncestryTrackv1.0.0.rb -i prefix.$chr.csv -o prefix.$chr.ancestrylength [argument]
done
```

# Required Parameters

The AncestryTrack program has two required parameters.

   -i/--input [file] where [file] is a .msp.tsv file which contains the most likely ancestral assignment for all variants in each individual in the cohort. 
   
   The msp.tsv files are created as output files by RFMix2 or G-Nomix local ancestry estimation softwares.
   All tsv files must be edited prior to the analysis to remove the first line and the '#' character that is printed by RFMix at the beginning of the header, and converted to comma separated values (CSV).
   Each chromosome must be run independently to perform the correct estimation. If RFMix results were previously merged in a single file, this can be split in chromosome by using the provided script: _SplitByChromosomes.rb_

   -o/--output=[string] where [string] is the output filename prefix.

# Optional Parameters

    --MB Converts tract length from Base to MegaBase. If unspecified, the program will automatically print the values in bases.
    
    --nohap  Removes haplotype information from the output file, printing only the [individual] names. If unspecified, the haplotype names will be printed i.e. each individual will have [individual]_0 and [individual]_1.
    
    --parallel Use multithreading for the computation. Usually slower than the standard, to use only if having issues with the standard computation.

# Output files

The AncestryTrack program produces two output files: a log file and a csv file.

The CSV (.csv) is the main output which contains the length of measured local ancestry tracts and the relative haplotype (or individual if --[nohap] was selected).
   
The log file (.log.txt) contains a summary of the analysis, which includes the analysis parameters, the number of markers, the number of samples, the 'switch' information by individual.

Each line of the csv output files represents one local ancestry segment and contains 3 tab-delimited fields:

    Sample Identifier
    Ancestry Identifier
    Tract Length

Results of the different chromosomes can be merged in a single output after the computation by using the provided script: _ConcatenateATresults.rb_

# Errors
If your input file has missing data i.e. missing ancestry in a random haplotype, the program will detect it and automatically stop.

# License

The AncestryTrack program is licensed under the Apache License, Version 2.0 (the License). You may obtain a copy of the License from http://www.apache.org/licenses/LICENSE-2.0
