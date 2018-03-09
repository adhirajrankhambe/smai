namespace :import do

  desc "Import Companies"
  task :companies => :environment do
    Company.import!
  end

end