class CreateApplications < ActiveRecord::Migration
  def change
    create_table :applications do |t|
      t.string :slug
      t.string :name
      t.string :path
      t.string :url

      t.timestamps null: false
    end
  end
end
