class CreateCsvs < ActiveRecord::Migration
  def change
    create_table :csvs do |t|
      t.string :filename

      t.timestamps null: false
    end
  end
end
