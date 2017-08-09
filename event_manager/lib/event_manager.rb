#08.30 .2013  - Basil Haddad
#Modified code from http://tutorials.jumpstartlab.com/projects/eventmanager.html to include the 
#following iterations:  Clean Phone Numbers, Time Targetting and Day of the week targetting
#Assumptions:
#  Bad phone numbers will be denoted as "0000000000"
#  Phone numbers will be formatted as such ddd.ddd.dddd
#Also note that the name variable was modified to first_name and this was reflected in the form_letter.erb template.  

require 'csv'
require 'sunlight/congress'
require 'erb'
require_relative './fixnum_extension'


Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
	zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zipcode)
	Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id, form_letter)
	Dir.mkdir("output") unless Dir.exists?("output")

	filename = "output/thanks_#{id}.html"

	File.open(filename, 'w') do |file|
		file.puts form_letter
	end
end

def clean_phone_number(phone_number)
    phone_number.gsub!(/\D/) {|x| ''}
    if (phone_number.length == 11 and phone_number[0]==1)
      phone_number = phone_number[1..-1]
    elsif phone_number.length == 10;
    else
      phone_number = "".rjust(10,"0")  #bad phone number
    end
    phone_number.insert(6, '.').insert(3, '.')
end

#returns freq hash for registration times (sorted in descending order)
def build_histogram(registration_dttms, &set_time_segment)
  histogram = Hash.new(0)
  registration_dttms.each{|dttm_str| 
    dttm = DateTime.strptime(dttm_str, '%m/%d/%y %H:%M')
    time_seg = set_time_segment.call(dttm)

    histogram[time_seg]+=1
  }
  histogram.sort_by{|time_seg, freq| freq}.reverse
end

#show_registration_times makes it simple to add new registration frequencies
def show_registration_times(registration_dttms, freq_option ={})
  #define lambdas to set new time segments here
  by_hour = lambda {|dttm| dttm.hour}
  by_wday = lambda{|dttm| dttm.wday}

  #define lambdas for formatting here
  format_by_hour = lambda {|time_seg| "#{time_seg.to_s.rjust(2, '0')}h00"}
  format_by_wday = lambda {|time_seg| time_seg.to_wday}

  #wrappers
  announce_histogram = lambda {puts "\nRegistration times by #{freq_option[:by]}:"}
  output_freq = lambda {|freq| ": #{freq} participants registered"}


  announce_histogram.call()
  case freq_option[:by]
  when 'hour'
    build_histogram(registration_dttms, &by_hour).each{|time_seg, freq| puts format_by_hour.call(time_seg) + output_freq.call(freq) }
  when 'weekday'
    build_histogram(registration_dttms, &by_wday).each{|time_seg, freq| puts format_by_wday.call(time_seg) + output_freq.call(freq) }
  end 
end
 




puts "EventManager initialized."

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

registration_dttms = []

contents.each do |row|
	id = row[0]
	first_name = row[:first_name]
    last_name = row[:last_name]
	zipcode = clean_zipcode(row[:zipcode])
	legislators = legislators_by_zipcode(zipcode)

	phone_number = clean_phone_number(row[:homephone])
	printf("%-30s %s", "#{first_name.strip} #{last_name.strip}", "#{phone_number}\n")

	registration_dttms << row[:regdate]

	form_letter = erb_template.result(binding)

	save_thank_you_letters(id, form_letter)
end



show_registration_times(registration_dttms, by:'hour')
show_registration_times(registration_dttms, by:'weekday')
