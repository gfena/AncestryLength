require 'optparse'
require 'csv'
require 'fileutils'

def main(input_file, output_dir)
  # Read the CSV file
  df = CSV.read(input_file, headers: true)

  # Check if 'chm' column exists
  unless df.headers.include?('chm')
    puts "Error: 'chm' column not found in the input CSV file."
    puts "Column names found in the input CSV file:"
    puts df.headers
    return
  end

  # Group by 'chm' column and iterate over groups
  df.group_by { |row| row['chm'] }.each do |chm, group|
    # Write each group to a separate CSV file with header
    output_file = File.join(output_dir, "chm_#{chm}.csv")
    CSV.open(output_file, 'wb') do |csv|
      csv << df.headers
      group.each { |row| csv << row }
    end
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby script.rb -i INPUT_FILE -o OUTPUT_DIR"

  opts.on("-iINPUT_FILE", "--input=INPUT_FILE", "Input CSV file path") do |input|
    options[:input] = input
  end

  opts.on("-oOUTPUT_DIR", "--output=OUTPUT_DIR", "Output directory to store split files") do |output|
    options[:output] = output
  end
end.parse!

# Check if input and output directory are provided
if options[:input].nil? || options[:output].nil?
  puts "Please provide both input CSV file path and output directory."
else
  # Ensure output directory exists, create it if it doesn't
  FileUtils.mkdir_p(options[:output])
  # Call main function
  main(options[:input], options[:output])
end
