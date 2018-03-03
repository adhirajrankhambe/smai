require 'open-uri'
require 'csv'

module CompanyImporter
  COMPANIES_DOWNLOAD_URL = 'https://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nyse&render=download'
  CURRENCY_REGEX = /\d*\.?\d{1,4}/
  UNIT_REGEX = /[BM]/

  def download_csv
    print "Downloading data..."
    companies_csv = CSV.parse(open(COMPANIES_DOWNLOAD_URL), headers: true, header_converters: :symbol, encoding: 'UTF-8')
    puts "Download complete"
    return companies_csv
  end

  def import!(companies_csv)
    print "Importing"
    counter = 0
    companies_csv.each do |row|
      company_data = { symbol: row[:symbol],
                       name: row[:name],
                       market_cap: get_market_cap(row[:marketcap]),
                       ipo_year: row[:ipoyear],
                       sector: row[:sector],
                       industry: row[:industry],
                       summary_quote: row[:summary_quote] }
      company = create(company_data)
      if company.persisted?
        counter += 1
        print '.'
      else
        puts "\n#{company_data[:symbol]} - #{company.errors.full_messages.join(",")}" if company.errors.any?
      end
    end

    puts "\nImported #{counter} companies"
  end

  private

    def get_market_cap(market_cap_value)
      return nil if market_cap_value == 'n/a'
      number = BigDecimal.new(market_cap_value.match(CURRENCY_REGEX).to_a.first, 4)
      unit = market_cap_value.match(UNIT_REGEX).to_a.first
      if unit == 'B'
        return number * 1000000000
      elsif unit == 'M'
        return number * 1000000
      else
        return nil
      end
    end
end