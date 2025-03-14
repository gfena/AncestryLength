# AncestryLength

**AncestryLength.rb** is a script designed to measure the length of local ancestry tracts derived from Local Ancestry Inference (LAI) analyses. It efficiently handles large datasets, including thousands of samples and multiple ancestries, by iterating across chromosomes. The script is compatible with various LAI models, ranging from simple 2-way admixture to models involving multiple ancestries.

If you use **AncestryLength** in a published analysis, please ensure to report the program version found in the first line of the output log file. Additionally, kindly cite the article that describes the AncestryLength method:

Ena, G. F., Giménez, A., Carballo-Mesa, A., Lišková, P., Araújo Castro e Silva, M., & Comas, D. (2025). The genetic footprint of the European Roma diaspora: Evidence from the Balkans to the Iberian Peninsula. Human Genetics.

Giacomo F. Ena

Last updated: March 14, 2025

# Installation

You can download the latest file, AncestryLengthv1.0.0, with the command:

 ```wget "https://raw.githubusercontent.com/gfena/AncestryLength/main/AncestryLength.rb"```

or you can directly download the source files.

```git clone https://github.com/gfena/AncestryLength.git```

# Running AncestryLength

AncestryLength requires Ruby version 3.3.1 (or a later version). Use of an earlier Ruby version could still work but it has not been tested, therefore support for older versions will not be provided.

The command:

```ruby AncestryLengthv1.0.0.rb```

prints a summary of the command line arguments.

```
Usage: ruby AncestryLengthv1.0.2.rb -i input_file -o output_file [--MB] [--nohap] [--parallel]
       Please provide the input file path
```

where [arguments] is a space-separated list of parameter values, each expressed as --parameter.

The shell script run.AncestryLength.test.sh will run a test AncestryLength analysis.
To iterate the program over the 22 chromosomes, run in this form:

```
for chr in {1..22}
do
rubyAncestryLengthv1.0.0.rb -i prefix.$chr.csv -o prefix.$chr.ancestrylength [argument]
done
```

# Required Parameters

The AncestryLength program has two required parameters.

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

The AncestryLength program produces two output files: a log file and a csv file.

The CSV (.csv) is the main output which contains the length of measured local ancestry tracts and the relative haplotype (or individual if --[nohap] was selected).
   
The log file (.log.txt) contains a summary of the analysis, which includes the analysis parameters, the number of markers, the number of samples, the 'switch' information by individual.

Each line of the csv output files represents one local ancestry segment and contains 3 tab-delimited fields:

    Sample Identifier
    Ancestry Identifier
    Tract Length

Results of the different chromosomes can be merged in a single output after the computation by using the provided script: _ConcatenateATresults.rb_

# Additional Provided Code
In the repository are included ruby scripts to split LAI input by chromosome and to concatenate AncestryLength results. Additional R scripts provided are used to draw plots and perform Mann U statistical tests. The codes are included as-is, as they were developed for the project and need to be edited with your data in order to be functional. 

# Errors
If your input file has missing data i.e. missing ancestry in a random haplotype, the program will detect it and automatically stop.
Verify that your input data is comma delimited, or the program won't function.

# License

AncestryLength is licensed under the Apache License, Version 2.0 (the License). You may obtain a copy of the License from http://www.apache.org/licenses/LICENSE-2.0
