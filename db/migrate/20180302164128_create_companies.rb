class CreateCompanies < ActiveRecord::Migration[5.1]
  def change
    create_table :companies do |t|
      t.string :symbol
      t.string :name
      t.decimal :market_cap, precision: 15, scale: 4
      t.integer :ipo_year
      t.string :sector
      t.string :industry
      t.string :summary_quote

      t.timestamps
    end
  end
end
