class Example < ApplicationRecord
	validates :name, uniqueness: true
end
