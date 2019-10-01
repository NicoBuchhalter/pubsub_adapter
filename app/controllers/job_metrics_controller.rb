class JobMetricsController < ApplicationController

	def index
		render json: JobMetric.get_metrics, status: :ok
	end
end