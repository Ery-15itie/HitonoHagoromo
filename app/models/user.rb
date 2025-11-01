class User < ApplicationRecord
  # User (1) は Item (多) を持つ
  # Userが退会した場合、紐づくItemも同時に削除される
  has_many :items, dependent: :destroy

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
