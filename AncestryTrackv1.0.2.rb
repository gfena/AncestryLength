def detect_switch_points(input_file, switch_output_file, tract_output_file, divide_by_million, remove_hap_suffix)
  switch_points = {}
  tract_lengths = {}
  total_rows = `wc -l "#{input_file}"`.to_i  # Count total number of rows in the CSV file

  start_time = Time.now  # Record the start time

  max_memory = 0  # Initialize max_memory variable

  Parallel.each(CSV.foreach(input_file, headers: true, col_sep: ','), in_threads: 8) do |row|
    # Check for missing values
    if row.to_hash.values.any?(&:nil?)
      puts "Warning: Input file '#{input_file}' contains missing values. Please check the input."
      next
    end

    process_row(row, switch_points, divide_by_million)

    current_memory = GetProcessMem.new.mb
    max_memory = current_memory if current_memory > max_memory
  end

  # Write switch points to switch output file
  File.open(switch_output_file, 'w') do |f|
    f.puts "Individual SwitchPoints\tSpos\tEpos"  # Adjusted formatting for headers
    switch_points.each do |individual, points|
      points.each { |point| f.puts "#{individual}\t#{point[1]}\t#{point[2]}" }  # Adjusted formatting for data
    end
  end

  # Write version information to the log file
  File.open(tract_output_file, 'a') do |f|  # Append mode to preserve existing content
    f.puts "AncestryTrack Version 1.0.2"
    f.puts "Max memory used: #{max_memory.round(2)} MB"
    f.puts "Elapsed time: #{elapsed_time} seconds"
    f.puts "Computation is complete."
  end

  end_time = Time.now  # Record the end time
  elapsed_time = end_time - start_time  # Calculate elapsed time

  # Print max_memory
  puts "\nMax memory used: #{max_memory.round(2)} MB"

  puts "Elapsed time: #{elapsed_time} seconds"  # Print elapsed time
  puts "Computation is complete."
end

def main(options)
  input_file = options[:input]
  output_file = options[:output]
  divide_by_million = options[:divide_by_million]
  remove_hap_suffix = options[:remove_hap_suffix]
  show_help = options[:help]

  if show_help
    puts "Usage: ruby AncestryTrackv1.0.2.rb -i input_file -o output_file [--MB] [--nohap]"
    puts "Options:"
    puts "-i, --input INPUT_FILE\t\tInput RFMix output file"
    puts "-o, --output OUTPUT_FILE\tOutput file with switch points and tract lengths"
    puts "--MB\t\t\t\tConvert tract length from base to megabase"
    puts "--nohap\t\t\t\tRemove haplotype information from the tract length output"
    exit(0)
  end

  if input_file.nil?
    puts "Usage: ruby AncestryTrackv1.0.2.rb -i input_file -o output_file [--MB] [--nohap]"
    puts "Please provide the input file path"
    exit(1)
  end

  # Check if input file is CSV formatted with comma separator
  if File.extname(input_file) != '.csv' || !File.foreach(input_file).first.include?(',')
    puts "Warning: Input file '#{input_file}' is not formatted as CSV with comma separator. This program only accepts CSV files with comma separator."
    exit(1)
  end

  switch_output_file = output_file.sub(/\.csv\z/i, '.switch.log')  # Change file extension to .switch.log
  tract_output_file = output_file

  detect_switch_points(input_file, switch_output_file, tract_output_file, divide_by_million, remove_hap_suffix, '1.0.2')
end
