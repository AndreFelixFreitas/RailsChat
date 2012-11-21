class User < ActiveRecord::Base
  attr_accessible :name
  validates :presence

  has_many :messages
end
