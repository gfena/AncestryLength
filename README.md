The **AncestryTrack** program measures the length of local ancestry tracts obtained from Local Ancestry Inference (LAI). The AncestryTrack program can analyse data sets with thousands of samples and multiple ancestries, iterating by chromosome.

If you use **AncestryTrack** in a published analysis, please report the program version printed in the first line of the output log file and please cite the article that describes the AncestryTrack method:

  *G.F. Ena, M. Araujo-Castro, A. Giménez, A. Carballo-Mesa, D. Comas. Exploring the Iberian Roma Trail: A Journey on Europe Edge.*

Giacomo F. Ena

Last updated: May 01, 2024

# Installation

You can download the latest file, AncestryTrackv1.0.2, with the command:

   _wget https://github.com/gfena/AncestryTrack/main/AncestryTrackv1.0.2.rb_

or you can directly download the source files.

   _git clone https://github.com/gfena/AncestryTrack.git_

# Running AncestryTrack

The AncestryTrack program requires Ruby version 3.3.1 (or a later version). Use of an earlier Ruby version could still work but it has not been tested, therefore it's not officially supported.

The command:

   _ruby AncestryTrackv1.0.0.rb_

prints a summary of the command line arguments.

   _Usage: ruby AncestryTrackv1.0.2.rb -i input_file -o output_file [--MB] [--nohap] [--parallel]
       Please provide the input file path_

where [arguments] is a space-separated list of parameter values, each expressed as --parameter.

The shell script run.AncestryTrack.test.sh will run a test AncestryTrack analysis.

# Required Parameters

The AncestryTrack program has two required parameters.

   -i/--input [file] where [file] is a Variant Call Format (VCF) file. All VCF records must include a GT FORMAT subfield, all genotypes must be phased, and there can be no missing alleles. If your data is unphased, you can phase your data using the Beagle program. A VCF record may have multiple ALT alleles. A VCF file with a name ending in ".gz" is assumed to be gzip-compressed.

   -o/--output=[string] where [string] is the output filename prefix.

# Optional Parameters

    --MB Converts tract length from Base to MegaBase. If unspecified, the program will automatically print the values in bases.
    
    --nohap  Removes haplotype information from the output file.
    
    --parallel Use multithreading for the computation. Usually slower than the standard, to use only if having issues with the standard computation.

# Output files

The hap-ibd program produces three output files: a log file, an ibd file, and an hbd file.

The log file (.log) contains a summary of the analysis, which includes the analysis parameters, the number of markers, the number of samples, the number of output HBD and IBD segments, and the mean number of HBD and IBD segments per sample.

The gzip-compressed ibd file (.ibd.gz) contains IBD segments shared between individuals. The gzip-compressed hbd file (.hbd.gz) contains HBD segments within within individuals. Each line of the ibd and hbd output files represents one IBD or HBD segment and contains 8 tab-delimited fields:

    First sample identifier
    First sample haplotype index (1 or 2)
    Second sample identifier
    Second sample haplotype index (1 or 2)
    Chromosome
    Base coordinate of first marker in segment
    Base coordinate of last marker in segment
    cM length of IBD segment

# License

The AncestryTrack program is licensed under the Apache License, Version 2.0 (the License). You may obtain a copy of the License from http://www.apache.org/licenses/LICENSE-2.0
