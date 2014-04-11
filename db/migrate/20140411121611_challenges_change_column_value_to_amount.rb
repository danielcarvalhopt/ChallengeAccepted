class ChallengesChangeColumnValueToAmount < ActiveRecord::Migration
  def change
  	rename_column :challenges, :value, :amount
  end
end
