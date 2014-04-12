class Challenge < ActiveRecord::Base
	belongs_to :challenger, class_name: "User"
	belongs_to :challenged, class_name: "User"
	belongs_to :state

	validates :description, presence: true
  validates :amount, presence: true
  validates :challenged_id, presence: true
  validates :challenger_id, presence: true
end
