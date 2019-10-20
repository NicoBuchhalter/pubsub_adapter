class JobMetric < ApplicationRecord

	def self.get_metrics
		instance = get_instance
		{ total_count: instance.total_count, total_duration: instance.total_duration }
	end

	def self.update_metrics(count_increment, duration_increment)
		instance = get_instance
		instance.with_lock do 
			instance.update!(
				total_count: instance.total_count + count_increment, 
				total_duration: instance.total_duration + duration_increment
			)
		end
	end

	def self.get_instance
		JobMetric.first
	end
end
