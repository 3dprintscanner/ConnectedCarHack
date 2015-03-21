class Createtableforapp < ActiveRecord::Migration
  def change
  	create_table :pressuredata do |data|
  		data.string :user_id
  		data.integer :vehicle_id
  		data.float :tyre_pressure
  		data.string :time
  	end

  end
end
