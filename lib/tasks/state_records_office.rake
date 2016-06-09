require "find"

namespace :state_records_office do
  desc "Load State Records images to database"
  task :load_images => :environment do

    # CSV schema of sro_images.csv: "id","filename","format","mode","filesize","width","height","info","exif","md5hash","photohash","cons_folder"
    # Process first 10 only for testing purposes 
    csv_file = ENV['CSV_FILE'] || "sro_images.csv"

    puts "This imports a batch of map image metadata from a csv file."
    puts "USAGE rake state_records_office:load_images CSV_FILE=/home/me/sro_images.csv"
    puts "WARNING: This may cause system instability or disaster!"
    puts "Using File #{csv_file}"
    print "Are you sure you want to continue ? [y/N] "
    break unless STDIN.gets.match(/^y$/i)

    unless User.exists?(1) 
	    puts "No user found with id 1" 
      break 
    else 
      @user = User.find_by_id(1) 
      puts "Maps will be uploaded by user " + @user.login.to_s
    end 

    # Create new Layer to store the imported maps 
    @layer = Layer.new(:name => "StateRecordsOffice")
    @layer.user @user 
    @layer.save

    data = open(csv_file)
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
            @map = Map.new(:title => [image[:cons_folder], image[:filename], "[IMPORTED]"].join(" "), 
			   :description => "Imported from batch script", 
			   :publisher => "geogeeks-au", 
			   :authors => "Western Australia State Records Office",
			   :scale => 25000)

            @map.owner = @user
            @map.users << @user 
	    if @layer
		@map.layers << @layer
	    end
	    File.open(path) { |photo_file| @map.upload = photo_file } 

            @count += 1 if @map.save 
	    if @map.errors.get(:filename) 
		puts ""
		puts "Map has same name, wasn't imported: " + @filename.to_s
	    end
          end 
        rescue 
          puts "Error processing " + @filename 
        end 
      end
    end
    p "Processing complete: #{@count} images added."
  end

  desc "Remove State Records images from database"
  task :remove_images => :environment do
    Rails.logger.debug "remove_images"
  end
end

