require 'optparse'
require 'csv'
require 'fileutils'

def concatenate_csv(input_directory, output_file)
  # Initialize an empty array to store data from all CSV files
  data = []

  # Iterate over each file in the directory
  Dir.foreach(input_directory) do |filename|
    if filename.start_with?("Roma.chr") && filename.end_with?(".ancestrylength.csv")
      # Extract the chromosome number from the filename
      chr_number = filename.split('.')[1]
      
      # Read the CSV file into an array of arrays
      CSV.foreach(File.join(input_directory, filename), col_sep: "\t", headers: true) do |row|
        # Add chromosome number to each row
        row['chr'] = chr_number
        data << row
      end
    end
  end

  # Reorder columns
  headers = ['chr', 'TractLengths', 'Ancestry', 'Haplotype']
  
  # Write data to the output CSV file
  CSV.open(output_file, 'wb', col_sep: "\t") do |csv|
    csv << headers
    data.each { |row| csv << row.values_at(*headers) }
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby script.rb -i INPUT_DIRECTORY -o OUTPUT_FILE"

  opts.on("-iINPUT_DIRECTORY", "--input=INPUT_DIRECTORY", "Input directory containing CSV files") do |input_dir|
    options[:input] = input_dir
  end

  opts.on("-oOUTPUT_FILE", "--output=OUTPUT_FILE", "Output file path for concatenated CSV") do |output_file|
    options[:output] = output_file
  end
end.parse!

# Check if input and output file are provided
if options[:input].nil? || options[:output].nil?
  puts "Please provide both input directory (-i) and output file path (-o)"
else
  # Call concatenate_csv function
  concatenate_csv(options[:input], options[:output])
end
