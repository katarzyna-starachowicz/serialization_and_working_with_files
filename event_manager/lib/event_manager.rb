require 'csv'
require 'sunlight/congress'
require 'erb'
require 'time'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_phone_number(phone_number)
  pn = phone_number.scan(/\d/).join("")
  if (pn.length == 10) || (pn.length == 11  && pn[0] == "1")
    pn[-10..-1]
  else
    "no number"
  end
end

def save_number_phones(name, homephone)
  Dir.mkdir("phones") unless Dir.exists?("phones")

  File.open("phones/phones.txt", 'a') { |file| file.puts "#{name}: #{homephone}" }
end

def registration_hour(time)
  DateTime.strptime(time, '%Y/%d/%m %H:%M').hour
end

def registration_day(time)
  DateTime.strptime(time, '%Y/%d/%m %H:%M').wday
end

def peak_registration_hours_and_days(hours, wdays)
  Dir.mkdir("peak_registration") unless Dir.exists?("peak_registration")

  File.open("peak_registration/peak_hours_and_days.txt", "w") do |file|
    h = {} # hash: hours => how many ragistrations at the time
    hours.each_with_index do |item, index|
      h[item] = h.has_key?(item) ? h[item] + 1 : 1
    end

    h.sort_by{|_,v| v}.reverse.each do |key, value|
      file.puts "At #{key} o'clock there was #{value} registrations."
    end

    hd = {} # hash: wdays => how many ragistrations in the day
    wdays.each_with_index do |item, index|
      hd[item] = hd.has_key?(item) ? hd[item] + 1 : 1
    end

    digit_days = { 0 => "Monday", 1 => "Tuesday", 2 => "Wednesday", 
      3 => "Thursday", 4 => "Friday", 5 => "Saturday", 6 => "Sunday"}

    hd.sort_by{|_,v| v}.reverse.each do |key, value|
      puts "#Key:#{key}, Value: #{value}"
      file.puts "There was #{value} registrations on #{digit_days[key]}."
    end
  end
end

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id,form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts form_letter
  end
end

puts "EventManager initialized."

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

hours = []
wdays = []

File.open("phones/phones.txt", 'w') {} if Dir.exists?("phones") #cleaning a file if there exists

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)
  save_thank_you_letters(id,form_letter)

  homephone = clean_phone_number(row[:homephone])
  save_number_phones(name, homephone)

  hours << registration_hour(row[:regdate])
  wdays << registration_day(row[:regdate])
end

peak_registration_hours_and_days(hours, wdays)