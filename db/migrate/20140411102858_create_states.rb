class CreateStates < ActiveRecord::Migration
  def change
    create_table :states do |t|
      t.string :description
    end
  end
end
