require 'open-uri'
require 'csv'
require 'benchmark'

module CompanyImporter

  COMPANIES_DOWNLOAD_URL = 'https://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nyse&render=download'
  CURRENCY_REGEX = /\d*\.?\d{1,4}/
  UNIT_REGEX = /[BM]/

  def import!
    print_memory_usage do
      print_time_spent do
        print "Importing"
        counter = 0
        CSV.foreach(open(COMPANIES_DOWNLOAD_URL), headers: true, header_converters: :symbol, encoding: 'UTF-8') do |row|
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

        puts "done.\nImported #{counter} companies"
      end
    end
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

    def print_memory_usage
      memory_before = `ps -o rss= -p #{Process.pid}`.to_i
      yield
      memory_after = `ps -o rss= -p #{Process.pid}`.to_i

      puts "Memory used: #{((memory_after - memory_before) / 1024.0).round(2)} MB"
    end

    def print_time_spent
      time = Benchmark.realtime do
        yield
      end

      puts "Time taken: #{time.round(2)}"
    end
end