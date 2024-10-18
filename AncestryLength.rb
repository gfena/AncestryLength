########### Giacomo F. Ena, April 2024
########### For help and info see Github repository
########### Name: AncestryLength
########### Version: 1.0.0
###########

require 'csv'
require 'optparse'

SCRIPT_NAME = "AncestryLength"
SCRIPT_VERSION = "1.0.0"

def detect_switch_points(input_file, switch_output_file, tract_output_file, divide_by_million, remove_hap_suffix)
  switch_points = {}
  tract_lengths = {}
  total_rows = `wc -l "#{input_file}"`.to_i  

  start_time = Time.now  
  processed_rows = 0

  CSV.foreach(input_file, headers: true, col_sep: ',') do |row|
    # Check for missing values
    if row.to_hash.values.any?(&:nil?)
      puts "Warning: Input file '#{input_file}' contains missing values. Please check the input."
      return
    end

    chrom = row['chm']
    start_pos = row['spos'].to_i
    end_pos = row['epos'].to_i

    row.headers[6..].each do |individual|
      ancestry_assignment = row[individual].to_i

      switch_points[individual] ||= []
      tract_lengths[individual] ||= []

      # Check for switch points
      if switch_points[individual].empty? || ancestry_assignment != switch_points[individual][-1][0]
        switch_points[individual] << [ancestry_assignment, start_pos, end_pos]
      else
        switch_points[individual][-1][2] = end_pos  # Update end position of the last switch point
      end
    end

    processed_rows += 1
    percentage_completion = (processed_rows.to_f / total_rows) * 100
    print "\rProgress: #{percentage_completion.round(2)}%"  # Print percentage of completion
  end

  # Calculate tract lengths
  switch_points.each do |individual, points|
    points.each do |point|
      state, start_pos, end_pos = point
      tract_length = divide_by_million ? ((end_pos - start_pos).abs) / 1_000_000.0 : (end_pos - start_pos).abs
      if tract_length.negative?
        puts "Warning: Negative tract length detected for #{individual}. Skipping this point."
      else
        tract_lengths[individual] << [tract_length, state]
      end
    end
  end

  # Write switch points to switch output file
  File.open(switch_output_file, 'w') do |f|
    switch_points.each do |individual, points|
      f.puts "#{individual}\tSwitchPoints\tSpos\tEpos"  
      points.each { |point| f.puts "\t#{point[0]}\t#{point[1]}\t#{point[2]}" }  
    end
  end

  # Write tract lengths to tract output file
  File.open(tract_output_file, 'w') do |f|
    f.puts "Tract_Length\tAncestry\tHaplotype" 
    tract_lengths.each do |individual, lengths|
      lengths.each do |length, state|
        haplotype = remove_hap_suffix ? individual.gsub(/\.0|\.1/, '') : individual
        f.puts "#{length}\t#{state}\t#{haplotype}"  
      end
    end
  end

  end_time = Time.now 
  elapsed_time = end_time - start_time  
  puts "\nElapsed time: #{elapsed_time} seconds"  
  puts "Computation is complete."
end

def main(options)
  if options[:version]
    puts "#{SCRIPT_NAME} Version #{SCRIPT_VERSION}"
    exit(0)
  end

  input_file = options[:input]
  output_file = options[:output]
  divide_by_million = options[:divide_by_million]
  remove_hap_suffix = options[:remove_hap_suffix]
  show_help = options[:help]

  if show_help
    puts "Usage: ruby AncestryLength.rb -i input_file -o output_file [--MB] [--nohap]"
    puts "Options:"
    puts "-i, --input INPUT_FILE\t\tInput RFMix output file"
    puts "-o, --output OUTPUT_FILE\tOutput file with switch points and tract lengths"
    puts "--MB\t\t\t\tConvert tract length from base to megabase"
    puts "--nohap\t\t\t\tRemove haplotype information from the tract length output"
    puts "--version\t\t\tShow script version"
    exit(0)
  end

  if input_file.nil?
    puts "Usage: ruby AncestryLength.rb -i input_file -o output_file [--MB] [--nohap]"
    puts "Please provide the input file path"
    exit(1)
  end

  # Check if input file is CSV formatted with comma separator
  if File.extname(input_file) != '.csv' || !File.foreach(input_file).first.include?(',')
    puts "Warning: Input file '#{input_file}' is not formatted as CSV with comma separator. This program only accepts CSV files with comma separator."
    exit(1)
  end

  switch_output_file = output_file.sub(/\.csv\z/i, '.switch.log') 
  tract_output_file = output_file

  detect_switch_points(input_file, switch_output_file, tract_output_file, divide_by_million, remove_hap_suffix)
end

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: ruby AncestryLength.rb -i input_file -o output_file [--MB] [--nohap] [--version]'
  opts.on('-i', '--input INPUT_FILE', 'Input *.msp file') do |input_file|
    options[:input] = input_file
  end
  opts.on('-o', '--output OUTPUT_FILE', 'Output file with switch points and tract lengths') do |output_file|
    options[:output] = output_file
  end
  opts.on('--MB', 'Convert to MegaBases') do
    options[:divide_by_million] = true
  end
  opts.on('--nohap', 'Ignore Haplotype Information') do
    options[:remove_hap_suffix] = true
  end
  opts.on_tail('--help', 'Prints this help') do
    options[:help] = true
  end
  opts.on('--version', 'Show script version') do
  options[:version] = true
  end
end.parse!

main(options)
