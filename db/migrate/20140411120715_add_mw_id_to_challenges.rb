class AddMwIdToChallenges < ActiveRecord::Migration
  def change
    add_column :challenges, :mw_id, :string
  end
end
