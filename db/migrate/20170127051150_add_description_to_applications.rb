class AddDescriptionToApplications < ActiveRecord::Migration
  def change
    add_column :applications, :description, :string
  end
end
