require 'csv'
require 'geocoder'
require 'english'
require 'yaml'

ARCHIVE_FILENAME = 'db.csv'
RESP_FILENAME = 'output.csv'

LOCATIONS = File.dirname(__FILE__) + "/" + ARCHIVE_FILENAME
COORDINATE = File.dirname(__FILE__) + "/" + RESP_FILENAME 


puts "File archivio: #{LOCATIONS}"
puts "File risposte: #{COORDINATE}"


#Verifico il numero di righe già scritte sul file di output
#e quelle le salto
num_row = %x{wc -l '#{COORDINATE}'}.to_i 
puts "Numero di righe già processate: #{num_row}"
row_to_skip = num_row


MAX_REQUEST = 2500;
TIMEOUT = 1;

Geocoder.configure({
	lookup: :google
	#http_proxy: "http://proxy.xxxxxxx.it:8080"
})

request_count = 0
File.open(COORDINATE, 'a') { |f|
	
	
	CSV.foreach(LOCATIONS, encoding: "utf-8", :headers => true, :header_converters => :symbol, :col_sep => ";") do |line|
		if (request_count >= MAX_REQUEST)
			puts "Raggiunto limite massimo di quest (#{request_count})"
			break
		end
		
		#Se ho processato x righe, ne devo saltare x+1 perché nel file archivio bisogna contare l'header
		next if $INPUT_LINE_NUMBER <= (row_to_skip + 1)
		
		request_count = request_count + 1
		
		address_string = "#{line[:street]}, #{line[:postalcode]}, #{line[:city]}, #{line[:region]}, #{line[:country]}"
		
		puts "Riga n. #{$INPUT_LINE_NUMBER - 1}, #{address_string}"
		
		result = Geocoder.search(address_string).first
		if (result)
			lat = result.latitude
			lon = result.longitude
			f.puts "Riga n. #{$INPUT_LINE_NUMBER - 1}, #{line[:partner]}, #{line[:address]}, #{address_string},  #{lat}, #{lon}"
			puts "Riga n. #{$INPUT_LINE_NUMBER - 1}, #{line[:partner]}, #{line[:address]}, #{address_string},  #{lat}, #{lon}"
		else
			f.puts "Riga n. #{$INPUT_LINE_NUMBER - 1}, #{line[:partner]}, #{line[:address]}, #{address_string}, nan, nan"
			puts "Riga n. #{$INPUT_LINE_NUMBER - 1}, #{line[:partner]}, #{line[:address]}, #{address_string}, nan, nan"
		end
		sleep(TIMEOUT)
	end

}
