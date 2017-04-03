class AddAppIdToPageComments < ActiveRecord::Migration
  def change
    add_column :page_comments, :application_id, :integer
  end
end
