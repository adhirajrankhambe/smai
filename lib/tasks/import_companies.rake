namespace :import do

  desc "Import Companies"
  task :companies => :environment do
    companies_csv = Company.download_csv
    Company.import!(companies_csv)
  end

end