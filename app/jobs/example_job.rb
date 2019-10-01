class ExampleJob < ApplicationJob

	def perform(name1, name2)
		e = Example.create!(name: name1)
		e.update!(name: name2)
	end
end