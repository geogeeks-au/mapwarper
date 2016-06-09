require "find"

namespace :state_records_office do
  desc "Load State Records images to database"
  task :load_images => :environment do
  
    # CSV schema of sro_images.csv: "id","filename","format","mode","filesize","width","height","info","exif","md5hash","photohash","cons_folder"
    # Process first 10 only for testing purposes 
    filename = ENV['CSV_FILE'] || "sro_images.csv"

    puts "This imports a batch of map image metadata from a csv file."
    puts "USAGE rake state_records_office:load_images CSV_FILE=/home/me/sro_images.csv"
    puts "WARNING: This may cause system instability or disaster!"
    puts "Using File #{filename}"
    print "Are you sure you want to continue ? [y/N] "
    break unless STDIN.gets.match(/^y$/i)


    data = open(filename)
    sro_images = CSV.parse(data, :headers => true, :header_converters => :symbol, :col_sep => ",")
    sro_images.by_row!
    p "Preparing to insert map image metadata! "
    @count = 0
    sro_images.drop(1).take(10).each do | image |
      if image.size > 0
      	@filename = ["/srv/sro", image[:cons_folder], image[:filename]].join("/")
      	begin 
      		Find.find(@filename) do | path | 
	      		puts "Processing " + path
	      		@count += 1
          end 
	      rescue 
		      puts "Error processing " + @filename 
	      end 
      end
    end
    p "BOOM! Payload delivered! #{@count} images added."
  end
end 

#        map_id = Map.find_by_upload_file_name(point[:filename]).id.to_i
#        gcp_conditions = {:x => point[:x].to_f, :y => point[:y].to_f, :lat => point[:lat].to_f, :lon => point[:lon].to_f, :map_id => map_id}
#        unless Gcp.exists?(gcp_conditions)
#          gcp = Gcp.new(gcp_conditions )
#          gcp.save
#          print '.'
#          count+=1
#        else
#          dup_count+=1
#          print '-'
#          #Gcp.delete_all(gcp_conditions)
#        end
#      end
#    end
#    p "BOOM! Payload delivered! #{count} Points added. (#{dup_count} dups)."
#    data = CSV.read("sro_images.csv")
#    folder_index = data.first().find_index("cons_folder")
#    filename_index = data.first().find_index("filename")

#    data.drop(1).take(10).each do |row|
#      @filename = ["/srv/sro", 
#                   row[folder_index], 
#                   row[filename_index]].join("/")
#      begin  
#        Find.find(@filename) do |path|
#          puts "Processing " + path 
#        end 
#      rescue
#        puts "Error processing " + @filename	
#      end
#    end
    #Rails.logger.debug Map.all.inspect
#  end

#  desc "Remove State Records images from database"
#  task :remove_images => :environment do
#    Rails.logger.debug "remove_images"
#  end
#end

