class Altertimetodatecolumn < ActiveRecord::Migration
  def change
  	change_table :pressuredata do |t|
  		t.change :time, :datetime
  	end
  end
end
