class MoreFeatures < ActiveRecord::Migration
  def change
  	add_column :users, :profile_image, :string, :default => "https://i.imgur.com/rjwIair.jpg"
  	add_column :tweets, :picture, :string, :default => ""
  end
end
