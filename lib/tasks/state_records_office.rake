#require 'config/environment'

namespace :state_records_office do
  desc "Load State Records images to database"
  task :load_images => :environment do
	Rails.logger.debug "load_images"
	Rails.logger.debug Map.all.inspect
  end

  desc "Remove State Records images from database"
  task :remove_images => :environment do
	Rails.logger.debug "remove_images"
  end
end
