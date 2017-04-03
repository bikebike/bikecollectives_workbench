class CreatePageComments < ActiveRecord::Migration
  def change
    create_table :page_comments do |t|
      t.text :comment
      t.string :group
      t.string :page
      t.integer :index
      t.string :variant
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
