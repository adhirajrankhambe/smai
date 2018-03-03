class Company < ApplicationRecord
  extend CompanyImporter

  validates :symbol,
            presence: true,
            uniqueness: true

end
