#http://tutorials.jumpstartlab.com/projects/eventmanager.html
require "csv"

  # if the zip code has not been specified, create a "00000" pseudo-zipcode
  # if the zip code is exactly five digits, assume that it is ok
  # if the zip code is more than 5 digits, truncate it to the first 5 digits
  # if the zip code is less than 5 digits, add zeros to the front until it becomes five digits
def clean_zipcode(zipcode)  
  zipcode.to_s.rjust(5, "0")[0..4]
end

puts "EventManager Initialized!"

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol
contents.each do |row|
  name = row[:first_name]
  zipcode = row[:zipcode]

  zipcode = clean_zipcode(row[:zipcode])

  puts "#{name} #{zipcode}"
end