class CreateChallenges < ActiveRecord::Migration
  def change
    create_table :challenges do |t|
      t.integer :challenger_id
      t.integer :challenged_id
      t.decimal :value
      t.integer :state_id
      t.text :description

      t.timestamps
    end
  end
end
