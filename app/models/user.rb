class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :challenger_challenges , class_name: "Challenge", :foreign_key => 'challenger_id'
  has_many :challenged_challenges , class_name: "Challenge", :foreign_key => 'challenged_id'

end
